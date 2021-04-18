//
//  float3+utils.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 09/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import simd

extension SIMD3 where SIMD3.Scalar == Float {
    
    func unit() -> SIMD3<Float> {
        let length = sqrt(dot(self, self))
        return SIMD3<Float>(x: self.x / length, y: self.y / length, z: self.z / length)
    }
}
