//
//  Vertex.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 26/02/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation

/// The structure describes a single vertex using the following properties:
/// - position  - 4 component float (x, y, z, w)
/// - color     - 4 component float (r, g, b, a)
struct Vertex {
    var position: vector_float4
    var color: vector_float4
}
