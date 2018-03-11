//
//  Matrix4f.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 02/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import simd
import MetalKit

struct Matrix4f: MatrixProtocol {
    
    // MARK: - Properties
    
    var data: [Float]
    
    // TODO - implement subscript
    
    // MARK: - Initializers
    
    init() {
        data = [
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]
    }
    
    // MARK: - Methods
    
    static func translate(matrix: Matrix4f, _ position: float3) -> Matrix4f {
        var matrix = matrix
        
        matrix.data[12] = position.x
        matrix.data[13] = position.x
        matrix.data[14] = position.x
        
        return matrix
    }
    
    static func scale(matrix: Matrix4f, factor: float3) -> Matrix4f {
        var matrix = matrix
        
        matrix.data[0] = factor.x
        matrix.data[5] = factor.y
        matrix.data[10] = factor.z
        
        return matrix
    }
    
    static func rotate(matrix: Matrix4f, rotation: float3) -> Matrix4f {
        var matrix = matrix
        
        matrix.data[0] = cos(rotation.y) * cos(rotation.z)
        matrix.data[4] = cos(rotation.z) * sin(rotation.x) * sin(rotation.y) - cos(rotation.x) * sin(rotation.z)
        matrix.data[8] = cos(rotation.x) * cos(rotation.z) * sin(rotation.y) + sin(rotation.x) * sin(rotation.z)
        matrix.data[1] = cos(rotation.y) * sin(rotation.z)
        matrix.data[5] = cos(rotation.x) * cos(rotation.z) + sin(rotation.x) * sin(rotation.y) * sin(rotation.z)
        matrix.data[9] = -cos(rotation.z) * sin(rotation.x) + cos(rotation.x) * sin(rotation.y) * sin(rotation.z)
        matrix.data[2] = -sin(rotation.y)
        matrix.data[6] = cos(rotation.y) * sin(rotation.x)
        matrix.data[10] = cos(rotation.x) * cos(rotation.y)
        matrix.data[15] = 1.0
        
        return matrix
    }
    
    // MARK: - Transformations
    
    /// Transforms the pixels from camera space to clip space (viewing frustrum). The transformation determines whether verticies are not inside the clip space and cull them or clip to bounds.
    ///
    /// NOTE: The last two transformations are from clip space to normalized device coordinates (NDC) and from NDC to screen space. These two transformations are handled by the Metal framework for us.
    ///
    /// - Parameters:
    ///   - near: is a Float param that describes near clipping plane
    ///   - far: is a Float param that describes far clipping plane
    ///   - aspect: is a Float para that describes relation between width and height of the viewing frustrum
    ///   - fovy: is a Float param that describes filed of view of the frustrum
    /// - Returns: matrix_float4x4 simd type that can futher be used as projection matrix
    static func project(near: Float, far: Float, aspect: Float, fovy: Float) -> matrix_float4x4 {
        
        let scaleY = 2 / tan(fovy * 0.5)
        let scaleX = scaleY / aspect
        let scaleZ = -(far + near) / (far - near)
        let scaleW = -2 * far * near  / (far - near)
        
        let x = vector_float4(scaleX, 0, 0, 0)
        let y = vector_float4(0, scaleY, 0, 0)
        let z = vector_float4(0, 0, scaleZ, 0)
        let w = vector_float4(0, 0, 0, scaleW)
        
        return matrix_float4x4(columns: (x, y, z, w))
    }
    
    
    static func translation(from position: vector_float3) -> matrix_float4x4 {
        let x = vector_float4(1, 0, 0, 0)
        let y = vector_float4(0, 1, 0, 0)
        let z = vector_float4(0, 0, 1, 0)
        let w = vector_float4(position.x, position.y, position.z, 1)
        
        return matrix_float4x4(columns: (x, y, z, w))
    }
    
    static func scaling(from scale: vector_float3) -> matrix_float4x4{
        
        let x = vector_float4(arrayLiteral: scale.x, 0, 0)
        let y = vector_float4(arrayLiteral: 0, scale.y, 0)
        let z = vector_float4(arrayLiteral: 0, 0, scale.z)
        let w = vector_float4(0, 0, 0, 1)
        
        return matrix_float4x4(columns: (x, y, z, w))
        
    }
    
    static func rotation(from angle: Float, axis: vector_float3) -> matrix_float4x4 {
        var x = vector_float4(0, 0, 0, 0)
        x.x = axis.x * axis.x + (1 - axis.x * axis.x) * cos(angle)
        x.y = axis.x * axis.y * (1 - cos(angle)) - axis.z * sin(angle)
        x.z = axis.x * axis.z * (1 - cos(angle)) + axis.y * sin(angle)
        x.w = 0.0
        
        var y = vector_float4(0, 0, 0, 0)
        y.x = axis.x * axis.y * (1 - cos(angle)) + axis.z * sin(angle)
        y.y = axis.y * axis.y + (1 - axis.y * axis.y) * cos(angle)
        y.z = axis.y * axis.z * (1 - cos(angle)) - axis.x * sin(angle)
        y.w = 0.0
        
        var z = vector_float4(0, 0, 0, 0)
        z.x = axis.x * axis.z * (1 - cos(angle)) - axis.y * sin(angle)
        z.y = axis.y * axis.z * (1 - cos(angle)) + axis.x * sin(angle)
        z.z = axis.z * axis.z + (1 - axis.z * axis.z) * cos(angle)
        z.w = 0.0
        
        let w = vector_float4(0, 0, 0, 1)
        
        return matrix_float4x4(columns:(x, y, z, w))
    }
    
    
}

// MARK: - Extension that adds support for matrix project capabilites
extension Matrix4f {
    
    
    // MARK: - Camera and projection methods
    
    /// Computes mode view projection matrix based on a number of inpout parameters
    ///
    /// - Parameters:
    ///   - drawable: is a Core Animation drawable instance that has direct relation to Metal API and is used in rendering
    ///   - vmatrix: is a view matrix represented by matrix_float4x4 simd type
    ///   - mmatrix: is a model matrix represented by matrix_float4x4 simd type
    ///   - nearPlane: is a Float value that represents the nearest plane to the virtual camera - the less the value the closer the camera can be positioned to object
    ///   - farPlane: is a Float value that represents the farest plane from the virual camera - high values are used to render as many objects as possible (however it may cost a lot of GPU resources - be careful or use high value in combination with tesselation, some sort of geometry caching or any other optimization technique)
    ///   - fovy: is a Float value that represents field of view of the virtual camera - this value can be used to simulate fish eye effect for instance. Normal fovy for human is around 90-110 degrees - however in order to find an optimal value you need to conduct experiments
    /// - Returns: a new, model view projection matrix that can be used to render objects with perspective
    static func computeModelViewProjection(for drawable: CAMetalDrawable, view vmatrix: matrix_float4x4, model mmatrix: matrix_float4x4, nearPlane: Float, farPlane: Float, fovy: Float = 1.1) -> matrix_float4x4 {
        
        let drawableTexture = drawable.texture
        let aspect = Float(drawableTexture.width / drawableTexture.height)
        let projectionMatrix = project(near: nearPlane, far: farPlane, aspect: aspect, fovy: fovy)
        let modelView = computeModelView(mmatrix, vmatrix)
        let modelViewProjection = matrix_multiply(projectionMatrix, modelView)
        
        return modelViewProjection
    }
    
    /// Computes model view matrix that transforms model to the view space and is used as part of model view projection transformations
    ///
    /// - Parameters:
    ///   - model: is a model matrix represented by matrix_float4x4 type
    ///   - view: is a view matrix represented by matrix_float4x4 type
    /// - Returns: a new, model view matrix of type matrix_float4x4
    static func computeModelView(_ model: matrix_float4x4, _ view: matrix_float4x4) -> matrix_float4x4 {
        return matrix_multiply(model, view)
    }
}
