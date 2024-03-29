//
//  Mesh.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 23/02/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import MetalKit

/// The protocol specifies a set of requrements for mesh structures. Typically mesh structures hold a set of verticies, texture coordinates, normals and other mesh related data.
protocol MeshProtocol {
    
    // MARK: - Properties
    
    var vertexData: [Vertex] { get set}
    var vertexDataSize: Int { get }
    var vertexBuffer: MTLBuffer! { get }
    
    var indexData: [UInt16] { get set }
    var indexDataSize: Int{ get }
    var indexBuffer: MTLBuffer! { get }
    
    // MARK: - Initializers
    
    init?(device: MTLDevice)
}
