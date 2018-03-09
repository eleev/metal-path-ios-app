//
//  float3+utils.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 09/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import simd

extension float3 {
    
    func unit() -> float3 {
        let length = sqrt(dot(self, self))
        return float3(x: self.x / length, y: self.y / length, z: self.z / length)
    }
}
