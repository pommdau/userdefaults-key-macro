// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "UserDefaultsKeyMacros", type: "StringifyMacro")

/// AppStorageで利用するキーを作成するマクロ
/// またデフォルト値にリセットするための関数を追加
@attached(member, names: named(UserDefaultsProperty), named(reset))
public macro UserDefaultsKey() = #externalMacro(module: "UserDefaultsKeyMacros", type: "UserDefaultsKeyMacro")
