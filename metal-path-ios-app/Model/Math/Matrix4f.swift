//
//  Matrix4f.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 02/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation



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
    
    
}
