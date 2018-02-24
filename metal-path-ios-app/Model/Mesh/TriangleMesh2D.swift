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

/// Specifies data for triangle 2D and conformance to MeshProtocol 
struct TriangleMesh2D: MeshProtocol {

    // MARK: - Properties
    
    /// The used order for verticies is counter clockwise:
    ///             Top Center
    ///     ------------------------
    /// Bottom Left ---------- Botton Right
    /// W component makes the used coordinates homogeneous
    var vertexData: [Float] = [
        -1.0, -1.0, 0.0, 1.0, // Bottom Left
         1.0, -1.0, 0.0, 1.0, // Bottom Right
         0.0,  1.0, 0.0, 1.0  // Top Center
    ]
    
    /// Computes the size of the vertex array by the following scehem:
    /// 12 floats (3 vertices, each containing 4 float components) = float.size * number of vertex array components
    var dataSize: Int {
        return vertexData.count * MemoryLayout<Float>.size
    }
    
    var buffer: MTLBuffer!
    
    // MARK: - Initializers
    
    init?(device: MTLDevice) {
        
        guard let buffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) else {
            fatalError(#function + " could not create Metal buffer object")
            return nil
        }
        self.buffer = buffer
    }
    
}
