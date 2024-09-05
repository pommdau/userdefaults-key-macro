import UserDefaultsKey
import SwiftUI

@AddUserDefaultsKey
struct Hoge {
    @AppStorage(UserDefaultsKey.firstName.rawValue)
    var firstName: String = "Taro"
//    var firstName: String
}

@AddUserDefaultsKey
struct Person {
    @AppStorage(UserDefaultsKey.firstName.rawValue)
    var firstName: String = "Taro"
    
    @AppStorage(UserDefaultsKey.lastName.rawValue)
    var lastName: String = "Daniel"

    @AppStorage(UserDefaultsKey.age.rawValue)
    var age: Int = 20

    var birthday: Date?
    
    var fullName: String {
        return "\(lastName) \(firstName)"
    }

}

let person = Person()
print(person.firstName) // Taro
person.firstName = "John"
print(person.firstName) // John
person.reset(of: .firstName)
print(person.firstName) // Taro

// 変更したまま終わった場合はそれが保存される
//person.firstName = "Emily"
//print(person.firstName) // Emily
