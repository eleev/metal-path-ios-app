//
//  QuadMesh3D.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 10/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import MetalKit


/// Abstract: The struct represents geometry for Quad object and conforms to MeshProtocol 
struct QuadMesh3D: MeshProtocol {
    
    // MARK: - Properties
    
    var vertexData: [Vertex] = [
        Vertex(position: [-1.0, -1.0,  1.0, 1.0], color: [1, 0, 0, 1]),
        Vertex(position: [ 1.0, -1.0,  1.0, 1.0], color: [0, 1, 0, 1]),
        Vertex(position: [ 1.0,  1.0,  1.0, 1.0], color: [0, 0, 1, 1]),
        Vertex(position: [-1.0,  1.0,  1.0, 1.0], color: [1, 1, 1, 1]),
        Vertex(position: [-1.0, -1.0, -1.0, 1.0], color: [0, 0, 1, 1]),
        Vertex(position: [ 1.0, -1.0, -1.0, 1.0], color: [1, 1, 1, 1]),
        Vertex(position: [ 1.0,  1.0, -1.0, 1.0], color: [1, 0, 0, 1]),
        Vertex(position: [-1.0,  1.0, -1.0, 1.0], color: [0, 1, 0, 1])
    ]
    
    var vertexDataSize: Int {
        return vertexData.count * MemoryLayout<Vertex>.size
    }
    var vertexBuffer: MTLBuffer!
    
    var indexData: [UInt16] = [
        0, 1, 2, 2, 3, 0,   // front
        1, 5, 6, 6, 2, 1,   // right
        3, 2, 6, 6, 7, 3,   // top
        4, 5, 1, 1, 0, 4,   // bottom
        4, 0, 3, 3, 7, 4,   // left
        7, 6, 5, 5, 4, 7,   // back
    ]
    
    var indexDataSize: Int {
        return indexData.count * MemoryLayout<UInt16>.size
    }
    var indexBuffer: MTLBuffer!
    
    // MARK: - Initializers

    init?(device: MTLDevice) {
        
        guard let vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexDataSize, options: []) else {
            fatalError(#function + " could not create Metal buffer object")
            return nil
        }
        self.vertexBuffer = vertexBuffer
        
        guard let indexBuffer = device.makeBuffer(bytes: indexData, length: indexDataSize, options: []) else {
            fatalError(#function + " could not create Metal index data buffer")
            return nil
        }
        self.indexBuffer = indexBuffer
        
    }
    
    
}
