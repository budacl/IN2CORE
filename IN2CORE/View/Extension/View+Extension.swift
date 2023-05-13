//
//  Extension.swift
//  IN2CORE
//
//  Created by Lukas Budac on 13/05/2023.
//

import SwiftUI

extension View {
    
    func interactive(isLoading: Bool, error: String?) -> some View {        
        let isInteractive = !isLoading && error == nil
        return disabled(!isInteractive)
            .opacity(isInteractive ? 1 : 0.2)
    }
    
}
