//
//  Ray.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 08/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import simd

struct Ray {
    
    // MARK: - Properties
    
    var origin: float3
    var direction: float3
    
    // MARK: - Methods
    
    /// Computes ray tracing equiation
    ///
    /// - Parameter t: is a Float paramenter
    /// - Returns: is a float3 vector describing new direction
    func compute(_ t: Float) -> float3 {
        return origin + t * direction
    }
}
