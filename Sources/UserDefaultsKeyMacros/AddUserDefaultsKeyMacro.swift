import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - UserDefaultsKeyMacro

enum UserDefaultsKeyError: CustomStringConvertible, Error {
    case classIncompatible
    case unknown(String)
    
    var description: String {
        switch self {
        case .classIncompatible:
            return "@UserDefaultsKey can only be applied to Actor/Class/Struct"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }
}

public struct AddUserDefaultsKeyMacro: MemberMacro {
    
    struct CustomVariableDecl {
        let pattern: IdentifierPatternSyntax
        let typeAnnotation: TypeAnnotationSyntax
        let initializer: InitializerClauseSyntax
        
        static func makeUserDefaultsKeyEnumDecl(decls: [CustomVariableDecl], className: String) throws -> EnumDeclSyntax {
            let enumSyntax = try EnumDeclSyntax("enum UserDefaultsKey: String, CaseIterable") {
                for decl in decls {
                    try EnumCaseDeclSyntax("case \(decl.pattern) = \"\(raw: className)_\(decl.pattern)\" ")
                }
            }
            return enumSyntax
        }
        
        static func makeResetFunctionDecl(decls: [CustomVariableDecl]) throws -> FunctionDeclSyntax {
            let resetSyntax = try FunctionDeclSyntax("func reset(of key: UserDefaultsKey)") {
                try SwitchExprSyntax("switch key") {
                    SwitchCaseListSyntax {
                        for decl in decls {
                            SwitchCaseSyntax(
                              "case .\(decl.pattern): \(decl.pattern) \(decl.initializer) "
                            )
                        }
                    }
                }
            }
            return resetSyntax
        }
    }
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {            
        // 修飾オブジェクトの型の確認
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
            throw UserDefaultsKeyError.unknown("Failed to load the class name")
        }
        
        // 各パラメーターの取得
        let variableDecls: [CustomVariableDecl] = declaration.memberBlock.members.compactMap { (member: MemberBlockItemSyntax)  -> CustomVariableDecl? in
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
        // 対象のPropertyがない場合は何もしない
        if variableDecls.isEmpty {
            return []
        }
        
        // 実際のコード作成
        guard let userDefaultsKeyEnumDecl = try? CustomVariableDecl.makeUserDefaultsKeyEnumDecl(decls: variableDecls, className: className),
              let resetFunctionDecl = try? CustomVariableDecl.makeResetFunctionDecl(decls: variableDecls) else {
            throw UserDefaultsKeyError.unknown("Failed to make macro codes.")
        }
                
        return [
            "\(raw: userDefaultsKeyEnumDecl)",
            "\(raw: resetFunctionDecl)",
        ]
    }
}

@main
struct UserDefaultsKeyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AddUserDefaultsKeyMacro.self,
    ]
}
