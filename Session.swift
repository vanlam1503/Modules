//
//  Session.swift
//  CombinePractice
//
//  Created by MBA0003 on 3/30/20.
//  Copyright © 2020 MBA0003. All rights reserved.
//

import Foundation

let ud = UserDefaults.standard

@propertyWrapper
private struct StringWrapper {
    
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    var wrappedValue: String? {
        set { ud.set(newValue, forKey: key) }
        get { ud.string(forKey: key) }
    }
}

@propertyWrapper
private struct BoolWrapper {
    
    let key: String
    
    init(key: String) {
        self.key = key
    }

    var wrappedValue: Swift.Bool {
        set { ud.set(newValue, forKey: key) }
        get { ud.bool(forKey: key) }
    }
}

@propertyWrapper
private struct IntWrapper {
    
    let key: String
    
    init(key: String) {
        self.key = key
    }

    var wrappedValue: Int {
        set { ud.set(newValue, forKey: key) }
        get { ud.integer(forKey: key) }
    }
}

@propertyWrapper
private struct DataWrapper {
    
    let key: String
    
    init(key: String) {
        self.key = key
    }

    var wrappedValue: Data? {
        set { ud.set(newValue, forKey: key) }
        get { ud.data(forKey: key) }
    }
}

@propertyWrapper
private struct DictionaryWrapper {

    let key: String

    init(key: String) {
        self.key = key
    }

    var wrappedValue: [String: Any]? {
        set { ud.set(newValue, forKey: key) }
        get { ud.dictionary(forKey: key) }
    }
}

@propertyWrapper
private struct CodableWrapper<T> where T: Codable {

    let key: String

    init(key: String) {
        self.key = key
    }

    var wrappedValue: T? {
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                ud.set(data, forKey: key)
            } catch {}
        }
        get {
            guard let data: Data = ud.data(forKey: key),
                let value: T = try? JSONDecoder().decode(T.self, from: data) else { return nil }
            return value
        }
    }
}

final class Session {

    static let shared = Session()
    private init() {}
    @BoolWrapper(key: "boolWrapper") var boolValue
    @IntWrapper(key: "intWrapper") var intValue
    @StringWrapper(key: "intWrapper") var stringValue
    @DictionaryWrapper(key: "stringWrapper") var dictionaryValue
    @CodableWrapper<Student>(key: "codableWrapper") var studentValue
}

final class Student: Codable {
    var name: String = ""
}
