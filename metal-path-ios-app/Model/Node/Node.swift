//
//  Node.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 06/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import MetalKit

class Node: NodeType {
    
    // MARK: - Properties
    
    var name: String
    var parentNode: NodeType
    var childNodes: [NodeType]
    
    var modelMatrix: Matrix4f
    var geometry: MTLBuffer
    
    // MARK: - Initializers
    
    required init(geometry: MTLBuffer) {
        fatalError(#function + " requires implementation")
    }
    
    // MARK: - Methods
    
    func updateGeometry(buffer: MTLBuffer) {
        fatalError(#function + " requires implementation")
    }
    
    func remove(child node: NodeType) {
        fatalError(#function + " requires implementation")
    }
    
    func remove() {
        fatalError(#function + " requires implementation")
    }
    
}
