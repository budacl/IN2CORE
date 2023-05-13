//
//  Injection.swift
//  IN2CORE
//
//  Created by Lukas Budac on 11/05/2023.
//

import Foundation

private struct ApiUrlsProviderKey: InjectionKey {
    static var currentValue: ApiUrlsProviding = ApiUrlsProvider()
}

private struct NetworkProviderKey: InjectionKey {
    static var currentValue: NetworkProviding = NetworkProvider()
}

extension InjectedValues {
    
    var apiUrls: ApiUrlsProviding {
        get { Self[ApiUrlsProviderKey.self] }
        set { Self[ApiUrlsProviderKey.self] = newValue }
    }
    
    var network: NetworkProviding {
        get { Self[NetworkProviderKey.self] }
        set { Self[NetworkProviderKey.self] = newValue }
    }
    
}
