//
//  Pixel.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 08/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation

/// Holds picture element information. Each property describes a single color channel and acceps values in the range [0-255].
struct Pixel {
    
    // MARK: - Properties
    
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}
