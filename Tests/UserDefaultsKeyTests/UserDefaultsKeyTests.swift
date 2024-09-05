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
//        assertMacro(["UserDefaultsKey": UserDefaultsKeyMacro.self]) {
        assertMacro(["UserDefaultsKey": UserDefaultsKeyMacro.self], record: true) {  // デバッグ用(expansionが自動で更新される)
            #"""
            @UserDefaultsKey
            struct Person {
                @AppStorage(UserDefaultsProperty.firstName.key)
                var firstName: String = "Taro"
                
                @AppStorage(UserDefaultsProperty.lastName.key)
                var lastName: String = "Daniel"

                @AppStorage(UserDefaultsProperty.age.key)
                var age: Int = 20

                var birthday: Date?
                
                var fullName: String {
                    return "\(lastName) \(firstName)"
                }
            }
            """#
        } expansion: {
            #"""
            struct Person {
                @AppStorage(UserDefaultsProperty.firstName.key)
                var firstName: String = "Taro"
                
                @AppStorage(UserDefaultsProperty.lastName.key)
                var lastName: String = "Daniel"

                @AppStorage(UserDefaultsProperty.age.key)
                var age: Int = 20

                var birthday: Date?
                
                var fullName: String {
                    return "\(lastName) \(firstName)"
                }

                enum UserDefaultsKey: String, CaseIterable {
                    case firstName = "Person_firstName"
                    case lastName = "Person_lastName"
                    case age = "Person_age"
                }

                func reset(of key: UserDefaultsProperty) {
                    switch key {
                    case .firstName:
                        firstName = "Taro"
                    case .lastName:
                        lastName = "Daniel"
                    case .age:
                        age = 20
                    }
                }
            }
            """#
        }
    }
}
