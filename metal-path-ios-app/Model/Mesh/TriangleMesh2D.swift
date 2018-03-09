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
    var vertexData: [Vertex] = [
        Vertex(position: [-1.0, -1.0, 0.0, 1.0], color: [1, 0, 0, 1]),
        Vertex(position: [ 1.0, -1.0, 0.0, 1.0], color: [0, 1, 0, 1]),
        Vertex(position: [ 0.0,  1.0, 0.0, 1.0], color: [0, 0, 1, 1])
    ]
    
    /// Computes the size of the vertex array by the following scehem:
    var vertexDataSize: Int {
        return vertexData.count * MemoryLayout<Vertex>.size
    }
    
    var vertexBuffer: MTLBuffer!
    
    var indexData: [UInt16] = [
        0, 1, 2
    ]
    
    var indexBuffer: MTLBuffer!
    
    var indexDataSize: Int {
        return indexData.count * MemoryLayout<UInt16>.size
    }
    
    // MARK: - Initializers
    
    init?(device: MTLDevice) {
        
        guard let buffer = device.makeBuffer(bytes: vertexData, length: vertexDataSize, options: []) else {
            fatalError(#function + " could not create Metal buffer object")
            return nil
        }
        self.vertexBuffer = buffer
        
        guard let indexBuffer = device.makeBuffer(bytes: indexData, length: indexDataSize, options: []) else {
            fatalError(#function + " could not create Metal index buffer object")
            return nil
        }
        
        self.indexBuffer = indexBuffer
    }
    
}
