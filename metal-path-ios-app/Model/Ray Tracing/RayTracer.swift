//
//  RayTracer.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 08/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import CoreImage
import simd

struct RayTracer {
    
    // MARK: - Typealiases
    
    typealias PixelSet = (pixels: [Pixel], width: Int, height: Int)
    
    // MARK: - Methods
    
    func makePixelSet(width: Int, height: Int) -> PixelSet {
        
        var pixel = Pixel(r: 0, g: 0, b: 0, a: 255)
        var pixels = [Pixel](repeating: pixel, count: width * height)
        
        for x in 0..<width {
            for y in 0..<height {
                let red: UInt8 = 0
                let green = UInt8(Double(x * 255 / width))
                let blue = UInt8(Double(y * 255 / height))
                let alpha: UInt8 = 255
                
                pixel = Pixel(r: red, g: green, b: blue, a: alpha)
                pixels[x + y * width] = pixel
            }
        }
        
        return PixelSet(pixels: pixels, width: width, height: height)
    }
    
    func render(pixelSet: PixelSet) -> CIImage {
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue) // alphha component is the last one
        
        let pixels = pixelSet.pixels
        let width = pixelSet.width
        let height = pixelSet.height
        
        let providerRef = CGDataProvider(data: NSData(bytes: pixels, length: pixels.count * MemoryLayout<Pixel>.size))
        let image = CGImage(width: width,
                            height: height,
                            bitsPerComponent: bitsPerComponent,
                            bitsPerPixel: bitsPerPixel,
                            bytesPerRow: width * MemoryLayout<Pixel>.size,
                            space: rgbColorSpace,
                            bitmapInfo: bitmapInfo,
                            provider: providerRef!,
                            decode: nil,
                            shouldInterpolate: true,
                            intent: CGColorRenderingIntent.defaultIntent)
        
        return CIImage(cgImage: image!)
        
    }
}

