//
//  UserDefaults+Utilities.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 26/01/2025.
//

import Foundation

extension UserDefaults {
    struct Key: RawRepresentable, ExpressibleByStringLiteral {
        
        // MARK: - Properties
        
        // MARK: RawRepresentable Properties
        
        var rawValue: String
        
        
        
        // MARK: - Construction
        
        // MARK: RawRepresentable Construction
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        
        // MARK: ExpressibleByStringLiteral Construction
        
        init(stringLiteral value: StringLiteralType) {
            self.init(rawValue: value)
        }
    }
}

extension UserDefaults {
    
    // MARK: - Functions
    
    func contains(_ key: Key) -> Bool {
        object(forKey: key.rawValue) != nil
    }
    
    func string(for key: Key) -> String? {
        string(forKey: key.rawValue)
    }
    
    func bool(for key: Key) -> Bool {
        bool(forKey: key.rawValue)
    }
    
    func integer(for key: Key) -> Int? {
        if contains(key) {
            return integer(forKey: key.rawValue)
        } else {
            return nil
        }
    }
    
    func data(for key: Key) -> Data? {
        data(forKey: key.rawValue)
    }
    
    func object<T: Codable>(_ type: T.Type, for key: Key) -> T? {
        guard let data = data(for: key) else { return nil }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func set(_ string: String?, for key: Key) {
        if let string {
            set(string, forKey: key.rawValue)
        } else {
            remove(for: key)
        }
    }
    
    func set(_ bool: Bool?, for key: Key) {
        if let bool {
            set(bool, forKey: key.rawValue)
        } else {
            remove(for: key)
        }
    }
    
    func set(_ data: Data?, for key: Key) {
        if let data {
            set(data, forKey: key.rawValue)
        } else {
            remove(for: key)
        }
    }
    
    func set(_ integer: Int?, for key: Key) {
        if let integer {
            set(integer, forKey: key.rawValue)
        } else {
            remove(for: key)
        }
    }
    
    func set<T: Codable>(_ object: T?, for key: Key) {
        if let object {
            set(try? JSONEncoder().encode(object), forKey: key.rawValue)
        } else {
            remove(for: key)
        }
    }
    
    func remove(for key: Key) {
        removeObject(forKey: key.rawValue)
    }
}

