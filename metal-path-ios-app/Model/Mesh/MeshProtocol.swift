//
//  Mesh.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 23/02/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation

/// The protocol specifies a set of requrements for mesh structures. Typically mesh structures hold a set of verticies, texture coordinates, normals and other mesh related data.
protocol MeshProtocol {
    var vertexData: [Float] { get set}
    var dataSize: Int { get }
}
