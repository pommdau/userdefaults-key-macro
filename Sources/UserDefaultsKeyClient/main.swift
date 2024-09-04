import UserDefaultsKey
import UserDefaultsKeyMacros
import SwiftUI
import Foundation

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

let person = Person()
print(person.name) // John
person.name = "Bob"
print(person.name) // Bob
person.reset(of: .name)
print(person.name) // John

// 変更したまま終わった場合はそれが保存される
//person.name = "Emily"
//print(person.name) // Emily
