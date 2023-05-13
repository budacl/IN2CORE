//
//  InjectionKey.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import Foundation

protocol InjectionKey {

    /// The associated type representing the type of the dependency injection key's value.
    associatedtype Value

    /// The default value for the dependency injection key.
    static var currentValue: Self.Value { get set }
    
}
