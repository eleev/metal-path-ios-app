//
//  RenderErrorType.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 22/02/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation

/// Error type that specifically describes error cases that may occur while using custom renderer
/// Cases:
/// - missingDrawable
/// - missingDevice
/// - missingCommandQueue
/// - couldNotCreateLibrary
/// - couldNotMakeShaderFunction
enum RenderErrorType: String, Error {
    case missingDrawable = "Rendering drawable was not specified"
    case missingDevice = "Target device is nil or has not been specified"
    case missingComandQueue = "Could not construct Command Queue"
    case couldNotCreateLibrary = "Could not construct Rebderer Library"
    case couldNotMakeShaderFunction = "Shader function could not be made"
}

