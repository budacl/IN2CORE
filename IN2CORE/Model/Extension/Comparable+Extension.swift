//
//  Comparable+Extension.swift
//  IN2CORE
//
//  Created by Lukas Budac on 13/05/2023.
//

import Foundation

extension Comparable {
 
    func greaterThan(_ min: Self) -> Self {
        return self > min ? self : min
    }
        
    func greaterThanOrEqualTo(_ min: Self) -> Self {
        return self >= min ? self : min
    }
    
    func lessThan(_ max: Self) -> Self {
        return self < max ? self : max
    }
    
    func lessThanOrEqualTo(_ max: Self) -> Self {
        return self <= max ? self : max
    }
    
    func inRange(min: Self, max: Self) -> Self {
        self.greaterThan(min).lessThan(max)
    }
    
    func inRangeOrEqualTo(min: Self, max: Self) -> Self {
        self.greaterThanOrEqualTo(min).lessThanOrEqualTo(max)
    }
    
}
