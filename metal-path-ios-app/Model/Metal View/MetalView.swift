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
        
        let rpd = MTLRenderPassDescriptor()
        let bleenColor = MTLClearColorMake(0, 0.5, 0.5, 1.0)
        rpd.colorAttachments[0].texture = currentDrawable?.texture
        rpd.colorAttachments[0].clearColor = bleenColor
        rpd.colorAttachments[0].loadAction = .clear
        
        let commandQueue = device?.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
        
        guard let drawable = currentDrawable else {
            debugPrint(#function + " drawable was not specified - the renderer will not be able to commit encodding command buffer and command encoder")
            throw iRenderError.missingDrawable
        }
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
}
