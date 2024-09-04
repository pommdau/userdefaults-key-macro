import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting // from: swift-macro-testing
import UserDefaultsKeyMacros

class StringifyTests: XCTestCase {
    func testStringify() {
        assertMacro(["stringify": StringifyMacro.self]) {
//        assertMacro(["stringify": StringifyMacro.self], record: true) {  // デバッグ用(expansionが自動で更新される)
            """
            #stringify(a + b)
            """
        } expansion: {
            """
            (a + b, "a + b")
            """
        }
    }
}

class UserDefaultsKeyTests: XCTestCase {
    func testUserDefaultsKey() {
        assertMacro(["UserDefaultsKey": UserDefaultsKeyMacro.self]) {
//        assertMacro(["UserDefaultsKey": UserDefaultsKeyMacro.self], record: true) {  // デバッグ用(expansionが自動で更新される)
            """
            @UserDefaultsKey
            struct Person {
                @AppStorage(UserDefaultsProperty.name.key)
                var name: String = "John"
            
                @AppStorage(UserDefaultsProperty.age.key)
                var age: Int = 0
            
                @AppStorage(UserDefaultsProperty.tax.key)
                var tax: Double = 0.1
            
                var birthday: Date?
            
                var agePlus100: Int {
                    return age + 100
                }
            }
            """
        } expansion: {
            #"""
            struct Person {
                @AppStorage(UserDefaultsProperty.name.key)
                var name: String = "John"

                @AppStorage(UserDefaultsProperty.age.key)
                var age: Int = 0

                @AppStorage(UserDefaultsProperty.tax.key)
                var tax: Double = 0.1

                var birthday: Date?

                var agePlus100: Int {
                    return age + 100
                }

                enum UserDefaultsProperty: String, CaseIterable {
                    case name
                    case age
                    case tax
                    var key: String {
                        return "Person_\(rawValue)"
                    }
                }

                func reset(of key: UserDefaultsProperty) {
                    switch key {
                    case .name:
                        name = "John"
                    case .age:
                        age = 0
                    case .tax:
                        tax = 0.1
                    }
                }
            }
            """#
        }
    }
}
