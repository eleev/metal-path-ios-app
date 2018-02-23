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
enum iRenderError: String, Error {
    case missingDrawable = "Rendering drawable was not specified"
}
