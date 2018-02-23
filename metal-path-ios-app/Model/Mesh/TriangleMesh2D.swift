//
//  2DTriangleMesh.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 23/02/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import UIKit
import Metal

struct TriangleMesh2D: Mesh {

    // MARK: - Properties
    
    var vertexData: [Float] = [
        -1.0, -1.0, 0.0, 1.0,
         1.0, -1.0, 0.0, 1.0,
         0.0,  1.0, 0.0, 1.0
    ]
    
    var dataSize: Int {
        get {
            return vertexData.count * MemoryLayout<Float>.size
        }
    }
    
}
