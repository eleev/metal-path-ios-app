//
//  Animator.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 12/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import MetalKit

// ToDo: Implement main functionality
// ToDo: Implement proper base animation functions
// NOTE: The following code is in development - it is messy and must not be used in production

class Animator: AnimatorProtocol {
    
    // MARK: - Properties
    
    var speed: Float
    var isAnimating: Bool
    var easing: EasingFunction
    
    // MARK: - Private properties
    
    private(set) var rotation: Float = 0.0
    
    // MARK: - Initializers
    
    init(speed: Float, easing: EasingFunction) {
        self.speed = speed
        self.easing = easing
        self.isAnimating = true
    }
    
    // MARK: - Methods
    
    func rotate(uniformBuffer: MTLBuffer) {
        let scaled = Matrix4f.scaling(from: vector3(simd_float2(0.5, 0.5), 0.5))
        rotation += 1 / speed * Float.pi / 4
        
        let rotatedY = Matrix4f.rotation(from: rotation, axis: float3(0, 1, 0))
        let rotatedX = Matrix4f.rotation(from: Float.pi / 4, axis: float3(1, 0, 0))
        
        let modelMatrix = matrix_multiply(matrix_multiply(rotatedX, rotatedY), scaled)
        let cameraPosition = vector_float3(0, 0, -3)
        
        let viewMatrix = Matrix4f.translation(from: cameraPosition)
        let projMatrix = Matrix4f.project(near: 0, far: 10, aspect: 1, fovy: 1)
        
        let modelViewMatrix = matrix_multiply(modelMatrix, viewMatrix)
        
//        let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modelMatrix))

        let bufferPointer = uniformBuffer.contents()
//        var uniforms = Uniforms(projectionMatrix: modelViewProjectionMatrix)
        
//        var uniforms = Uniforms(projectionMatrix: projMatrix, modelViewMatrix: modelViewMatrix)
        
        var uniforms = Uniforms(projectionMatrix: projMatrix, modelViewMatrix: modelViewMatrix, modelMatrix: modelMatrix)
        
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
    }
    
}
