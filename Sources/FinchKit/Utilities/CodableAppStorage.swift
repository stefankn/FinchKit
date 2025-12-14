//
//  CodableAppStorage.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 08/02/2025.
//

import SwiftUI

@propertyWrapper
public struct CodableAppStorage<Value: Codable & Sendable>: DynamicProperty, Sendable {
    
    // MARK: - Private Properties
    
    @AppStorage private var value: Data
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    
    
    // MARK: - Properties
    
    public var wrappedValue: Value {
        get { try! decoder.decode(Value.self, from: value) }
        nonmutating set { value = try! encoder.encode(newValue) }
    }
    
    public var projectedValue: Binding<Value> {
        Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
    }
    
    
    
    // MARK: - Construction
    
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) {
        _value = .init(wrappedValue: try! encoder.encode(wrappedValue), key, store: store)
    }
}
