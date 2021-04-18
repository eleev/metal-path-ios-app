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
    
    var origin: SIMD3<Float>
    var direction: SIMD3<Float>
    
    // MARK: - Methods
    
    /// Computes ray tracing equiation
    ///
    /// - Parameter t: is a Float paramenter
    /// - Returns: is a float3 vector describing new direction
    func compute(_ t: Float) -> SIMD3<Float> {
        return origin + t * direction
    }
}
