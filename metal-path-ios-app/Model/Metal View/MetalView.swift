//
//  iRender.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 22/02/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import Foundation
import Metal
import MetalKit

/// Custon derivative from the MTKView that adds suport for custom renderer and is responsible for shader compilation, attachment, buffers and encoders
class MetalView: MTKView {
    
    // MARK: - Properties
    
    // MARK: - Initilziers
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        self.device = device
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        do {
            try render()
        } catch {
            debugPrint(#function + " thrown the following error: ", error)
        }
    }
    
    // MARK: - Private Methods
    
    /// This function is called every frame by the overriden draw(:CGRect) function. The main responsibility is to provide means that clear screen, specify render pass descriptors (RPDs), textures, buffers and everything related to graphics rendering
    ///
    /// - Throws: may throw missing attachments, such as missing drawable target for instance
    private func render() throws {
        // Create render pass descriptor (RPD)
        let rpd = MTLRenderPassDescriptor()
        let bleenColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        rpd.colorAttachments[0].texture = currentDrawable?.texture
        rpd.colorAttachments[0].clearColor = bleenColor
        rpd.colorAttachments[0].loadAction = .clear
        
        // Create default queues and buffers
        let commandQueue = device?.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
        
        // Make sure that current drawable exsists
        guard let drawable = currentDrawable else {
            debugPrint(#function + " drawable was not specified - the renderer will not be able to commit encodding command buffer and command encoder")
            throw RenderErrorType.missingDrawable
        }
        
        // Finish encoding and comming changes
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    /// Creates metal shader function pair for vertex and fragment shaders from the default Metal library
    ///
    /// - Parameters:
    ///   - vertexShaderName: in-bundle name for vertex metal shader file
    ///   - fragmentShaderName: in-bundle name for fragment metal shader file
    /// - Returns: tuple containing initialized instnaces of MTLFunction class for both vertex and fragment shaders
    /// - Throws: there a couple of possible throws that may occur during the runtime of the function:
    ///     - couldNotCraeteLibrary
    ///     - couldNotMakeShaderFunction
    private func attachShaderPair(vertexShaderName: String, fragmentShaderName: String) throws -> (vertexFunction: MTLFunction, fragmentFunction: MTLFunction){
        // Make sure that library can be obtaned
        guard let lib = device?.makeDefaultLibrary() else {
            debugPrint(#function + " could not make default library object, the method will be thrown")
            throw RenderErrorType.couldNotCreateLibrary
        }
        // Create vertex shader function
        guard let vertexFunction = lib.makeFunction(name: vertexShaderName) else {
            debugPrint(#function + " could not create vertex function")
            throw RenderErrorType.couldNotMakeShaderFunction
        }
        
        // Create fragment shader function
        guard let fragmentFunction = lib.makeFunction(name: fragmentShaderName) else {
            debugPrint(#function + " could not create fragment function")
            throw RenderErrorType.couldNotMakeShaderFunction
        }
        
        return (vertexFunction: vertexFunction, fragmentFunction: fragmentFunction)
    }
    
}
