// The Swift Programming Language
// https://docs.swift.org/swift-book

/// AppStorageで利用するキーを作成するマクロ
/// またデフォルト値にリセットするための関数を追加
@attached(member, names: named(UserDefaultsKey), named(reset))
public macro AddUserDefaultsKey() = #externalMacro(module: "UserDefaultsKeyMacros", type: "AddUserDefaultsKeyMacro")
