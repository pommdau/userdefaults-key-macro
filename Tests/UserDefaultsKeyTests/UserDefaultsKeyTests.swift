import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting // from: swift-macro-testing
import UserDefaultsKeyMacros

class UserDefaultsKeyTests: XCTestCase {
    func testUserDefaultsKey() {
        assertMacro(["AddUserDefaultsKey": AddUserDefaultsKeyMacro.self]) {
//        assertMacro(["AddUserDefaultsKey": AddUserDefaultsKeyMacro.self], record: true) {  // デバッグ用(expansionが自動で更新される)
            #"""
            @AddUserDefaultsKey
            struct Person {
                @AppStorage(UserDefaultsKey.firstName.key)
                var firstName: String = "Taro"
                
                @AppStorage(UserDefaultsKey.lastName.key)
                var lastName: String = "Daniel"

                @AppStorage(UserDefaultsKey.age.key)
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
                @AppStorage(UserDefaultsKey.firstName.key)
                var firstName: String = "Taro"
                
                @AppStorage(UserDefaultsKey.lastName.key)
                var lastName: String = "Daniel"

                @AppStorage(UserDefaultsKey.age.key)
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

                func reset(of key: UserDefaultsKey) {
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
    
    func testUserDefaultsKeyWithNoValidProperty() {
        assertMacro(["AddUserDefaultsKey": AddUserDefaultsKeyMacro.self]) {
//        assertMacro(["AddUserDefaultsKeyMacro": AddUserDefaultsKeyMacro.self], record: true) {  // デバッグ用(expansionが自動で更新される)
            #"""
            @AddUserDefaultsKey
            struct Person {
                let name: String
            }
            """#
        } expansion: {
            """
            struct Person {
                let name: String
            }
            """
        }
    }
}
