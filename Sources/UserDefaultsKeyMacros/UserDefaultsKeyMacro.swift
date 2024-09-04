import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

// MARK: - UserDefaultsKeyMacro

enum UserDefaultsKeyError: CustomStringConvertible, Error {
    case classIncompatible
    case unknown(String)
    
    var description: String {
        switch self {
        case .classIncompatible:
            return "@AddUserDefaultsProperty can only be applied to Actor/Class/Struct"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }
}

public struct UserDefaultsKeyMacro: MemberMacro {
    
    struct CustomVariableDecl {
        let pattern: IdentifierPatternSyntax
        let typeAnnotation: TypeAnnotationSyntax
        let initializer: InitializerClauseSyntax
    }
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        /*
         Printing description of node:
         AttributeSyntax
         ├─atSign: atSign
         ╰─attributeName: IdentifierTypeSyntax
           ╰─name: identifier("Init")
         */
        
        /*
         Printing description of declaration:
         ClassDeclSyntax
         ├─attributes: AttributeListSyntax
         │ ╰─[0]: AttributeSyntax
         │   ├─atSign: atSign
         │   ╰─attributeName: IdentifierTypeSyntax
         │     ╰─name: identifier("Init")
         ├─modifiers: DeclModifierListSyntax
         ├─classKeyword: keyword(SwiftSyntax.Keyword.class)
         ├─name: identifier("Person")
         ╰─memberBlock: MemberBlockSyntax
           ├─leftBrace: leftBrace
           ├─members: MemberBlockItemListSyntax
           │ ├─[0]: MemberBlockItemSyntax
           │ │ ╰─decl: VariableDeclSyntax
           │ │   ├─attributes: AttributeListSyntax
           │ │   ├─modifiers: DeclModifierListSyntax
           │ │   ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.let)
           │ │   ╰─bindings: PatternBindingListSyntax
           │ │     ╰─[0]: PatternBindingSyntax
           │ │       ├─pattern: IdentifierPatternSyntax
           │ │       │ ╰─identifier: identifier("name")
           │ │       ╰─typeAnnotation: TypeAnnotationSyntax
           │ │         ├─colon: colon
           │ │         ╰─type: IdentifierTypeSyntax
           │ │           ╰─name: identifier("String")
           │ ├─[1]: MemberBlockItemSyntax
           │ │ ╰─decl: VariableDeclSyntax
           │ │   ├─attributes: AttributeListSyntax
           │ │   ├─modifiers: DeclModifierListSyntax
           │ │   ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.let)
           │ │   ╰─bindings: PatternBindingListSyntax
           │ │     ╰─[0]: PatternBindingSyntax
           │ │       ├─pattern: IdentifierPatternSyntax
           │ │       │ ╰─identifier: identifier("age")
           │ │       ╰─typeAnnotation: TypeAnnotationSyntax
           │ │         ├─colon: colon
           │ │         ╰─type: IdentifierTypeSyntax
           │ │           ╰─name: identifier("Int")
           │ ╰─[2]: MemberBlockItemSyntax
           │   ╰─decl: VariableDeclSyntax
           │     ├─attributes: AttributeListSyntax
           │     ├─modifiers: DeclModifierListSyntax
           │     ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.let)
           │     ╰─bindings: PatternBindingListSyntax
           │       ╰─[0]: PatternBindingSyntax
           │         ├─pattern: IdentifierPatternSyntax
           │         │ ╰─identifier: identifier("birthday")
           │         ╰─typeAnnotation: TypeAnnotationSyntax
           │           ├─colon: colon
           │           ╰─type: OptionalTypeSyntax
           │             ├─wrappedType: IdentifierTypeSyntax
           │             │ ╰─name: identifier("Date")
           │             ╰─questionMark: postfixQuestionMark
           ╰─rightBrace: rightBrace
         */
        
        guard
            declaration.is(ActorDeclSyntax.self) ||
                declaration.is(ClassDeclSyntax.self) ||
                declaration.is(StructDeclSyntax.self)
        else {
            throw UserDefaultsKeyError.classIncompatible
        }
        
        // クラス名の取得
        guard let className = [
            declaration.as(ActorDeclSyntax.self)?.name.trimmed.text,
            declaration.as(ClassDeclSyntax.self)?.name.trimmed.text,
            declaration.as(StructDeclSyntax.self)?.name.trimmed.text,
        ].compactMap({ $0 }).first else {
            throw UserDefaultsKeyError.unknown("クラス名の取得に失敗しました")
        }
        
//        let variableDecls: [CustomVariableDecl]
        let variableDecls: [CustomVariableDecl] = declaration.memberBlock.members.compactMap { (member: MemberBlockItemSyntax)  -> CustomVariableDecl? in
            
            /*
             Printing description of member:
             MemberBlockItemSyntax
             ╰─decl: VariableDeclSyntax
               ├─attributes: AttributeListSyntax
               ├─modifiers: DeclModifierListSyntax
               ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.var)
               ╰─bindings: PatternBindingListSyntax
                 ╰─[0]: PatternBindingSyntax
                   ├─pattern: IdentifierPatternSyntax
                   │ ╰─identifier: identifier("name")
                   ├─typeAnnotation: TypeAnnotationSyntax
                   │ ├─colon: colon
                   │ ╰─type: IdentifierTypeSyntax
                   │   ╰─name: identifier("String")
                   ╰─initializer: InitializerClauseSyntax
                     ├─equal: equal
                     ╰─value: StringLiteralExprSyntax
                       ├─openingQuote: stringQuote
                       ├─segments: StringLiteralSegmentListSyntax
                       │ ╰─[0]: StringSegmentSyntax
                       │   ╰─content: stringSegment("hoge")
                       ╰─closingQuote: stringQuote
             */
            
            guard
                let decl = member.decl.as(VariableDeclSyntax.self),
                let binding = decl.bindings.first,
                let pattern = binding.pattern.as(IdentifierPatternSyntax.self), // 変数名
                let typeAnnotation = binding.typeAnnotation, // 型名
                let initializer = binding.initializer
            else {
                return nil
            }
            
            return .init(pattern: pattern, typeAnnotation: typeAnnotation, initializer: initializer)
        }
        
        let enumSyntax = try EnumDeclSyntax("enum UserDefaultsProperty: String, CaseIterable") {
            for variableDecl in variableDecls {
                try EnumCaseDeclSyntax("case \(variableDecl.pattern) ")
            }
            
            try VariableDeclSyntax("var key: String") {
                ReturnStmtSyntax(
                    returnKeyword: .keyword(.return, trailingTrivia: .space),
                    expression: "\"\(raw: className)_\\(rawValue)\"" as ExprSyntax
                )
            }
        }
        
        let resetSyntax = try FunctionDeclSyntax("func reset(of key: UserDefaultsProperty)") {
            try SwitchExprSyntax("switch key") {
                SwitchCaseListSyntax {
                    for element in variableDecls {
                        SwitchCaseSyntax(
                          "case .\(element.pattern): \(element.pattern) \(element.initializer) "
                        )
                    }
                }
            }
        }
                
        return [
            "\(raw: enumSyntax)",
            "\(raw: resetSyntax)",
        ]
    }
}


@main
struct UserDefaultsKeyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        UserDefaultsKeyMacro.self,
    ]
}
