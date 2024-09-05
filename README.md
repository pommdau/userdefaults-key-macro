# UserDefaultsKey
- Swift Macros creating UserDefaults-Key and reset-func for @AppStorage

## Usage

Source code:

```swift
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
```

Expanded source:

```swift
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
```

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
