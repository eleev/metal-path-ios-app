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
    
    var device: MTLDevice
    
    var name: String = ""
    var parentNode: NodeType?
    var childNodes: [NodeType] = []
    
    var modelMatrix: Matrix4f = Matrix4f()
    var geometry: MeshProtocol?
    
    // MARK: - Private properties
    
    private(set) var modelMatrixBuffer: MTLBuffer?
    
    // MARK: - Initializers
    
    required init(device: MTLDevice) {
        self.device = device
        prepareModelBuffer()
    }
    
    required init(device: MTLDevice, geometry: MeshProtocol) {
        self.device = device
        self.geometry = geometry
        prepareModelBuffer()
    }
    
    // MARK: - Methods
    
    func update(geometry: MeshProtocol) {
        fatalError(#function + " requires implementation")
    }
    
    func remove(child node: NodeType) {
        fatalError(#function + " requires implementation")
    }
    
    func remove() {
        fatalError(#function + " requires implementation")
    }
    
    
    // MARK: - Utility methods
    
    /// Prepares metal buffer data to be sent to the GPU
    func prepareModelBuffer() {
        let memoryLayout = MemoryLayout<Uniforms>.size * 2 // TODO: this line needs to be refactored and "magic" numbers need to be removed. In order to do that, the Uniform bridging hearing should be refactored and migrated from Renderer class to MetalView class
        modelMatrixBuffer = device.makeBuffer(length: memoryLayout, options: [])
        let bufferPointer = modelMatrixBuffer?.contents()
        memcpy(bufferPointer, modelMatrix.data, memoryLayout)
    }
}
