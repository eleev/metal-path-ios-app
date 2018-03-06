//
//  NodeType.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 06/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import MetalKit

/// NodeType specifies a set of requirements for a Node entity - which is a collection of:
/// - geometry data - position, texture coordinates, normals etc.
/// - transformational data - position, rotation, scaling etc.
/// - material data - it is applied to geometry and describes the visual properties such as textures and texture mapping
/// - child nodes - is a collection of children attached to the current node
/// - parent node - is the parent node that holds current node

/// Node forms scene graph - which is the fundamental structure of any 3D engine or rendering technology. It allows to structure graphical and non graphical elements and perform operations in a hierarchical  fashion.
protocol NodeType {
    
    // MARK: - Properties
    
    var name: String { get set }
    var parentNode: NodeType { get set }
    var childNodes: [NodeType] { get set }
    
    var modelMatrix: Matrix4f { get set }
    var geometry: MTLBuffer { get }
    
    // MARK: - Initializers
    
    init(geometry: MTLBuffer)
    
    // MARK: - Methods
    
    func updateGeometry(buffer: MTLBuffer)
    func remove(child node: NodeType)
    func remove()

}
