# UserDefaultsKey
Swift Macros creating UserDefaults-Key and reset-func for `@AppStorage`

## Usage

Source code:

```swift
import UserDefaultsKey

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
```

Expanded source:

```swift
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
```

## Sample Project

[userdefaults\-key\-macro\-sample](https://github.com/pommdau/userdefaults-key-macro-sample/tree/main)

## Installation

### SPM

```
.package(url: "https://github.com/pommdau/userdefaults-key-macro", branch: "main")
```

### Xcode
Go to File > `Add Package Dependencies...` and paste the repo's URL:

```
https://github.com/pommdau/userdefaults-key-macro
```
## Known Issues
- The type inference is not supported.
- For example, the following code will fail to build

```swift
@AppStorage(UserDefaultsKey.firstName.key)
var firstName = "Taro"
```
