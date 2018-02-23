//
//  Mesh.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 23/02/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation

protocol Mesh {
    var vertexData: [Float] { get set}
    var dataSize: Int { get }
}
