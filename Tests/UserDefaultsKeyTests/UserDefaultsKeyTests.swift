import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting // from: swift-macro-testing
import UserDefaultsKeyMacros

class StringifyTests: XCTestCase {
    func testStringify() {
//        assertMacro(["stringify": StringifyMacro.self]) {
        assertMacro(["stringify": StringifyMacro.self], record: true) {  // デバッグ用(expansionが自動で更新される)
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
