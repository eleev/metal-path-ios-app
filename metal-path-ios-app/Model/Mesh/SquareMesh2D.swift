//
//  SquareMesh2D.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 09/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import MetalKit
import UIKit

struct SquareMesh2D: MeshProtocol {
    
    // MARK: - Properties
    
    var vertexData: [Vertex] = [
        Vertex(position: [-1.0, -1.0, 0.0,  1.0], color: [1, 0, 0, 1]),
        Vertex(position: [ 1.0, -1.0, 0.0,  1.0], color: [0, 1, 0, 1]),
        Vertex(position: [ 1.0,  1.0, 0.0,  1.0], color: [0, 0, 1, 1]),
        Vertex(position: [-1.0,  1.0, 0.0,  1.0], color: [1, 1, 1, 1])
    ]
    
    var vertexDataSize: Int {
        return vertexData.count * MemoryLayout<Vertex>.size
    }
    
    var vertexBuffer: MTLBuffer!
    
    // Clocksise drawing
    var indexData: [UInt16] = [
        0, 1, 2, 2, 3, 0
    ]
    
    var indexBuffer: MTLBuffer!
    
    var indexDataSize: Int {
        return indexData.count * MemoryLayout<UInt16>.size
    }
    
    // MARK: - Initizliers
    
    init?(device: MTLDevice) {
        
        guard let buffer = device.makeBuffer(bytes: vertexData, length: vertexDataSize, options: []) else {
            fatalError(#function + " could not crate Metal buffer object")
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
