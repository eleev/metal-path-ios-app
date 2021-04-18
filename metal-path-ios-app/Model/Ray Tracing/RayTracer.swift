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
    
    // MARK: - Construction
    
    func makeGradientPixelSet(width: Int, height: Int) -> PixelSet {
        
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
    
    func makeGradientPixelSet(width: Int, height: Int, computePixel: @escaping (_ x: Int, _ y: Int, _ width: Int, _ height: Int)->Pixel) -> PixelSet {
        
        var pixel = Pixel(r: 0, g: 0, b: 0, a: 255)
        var pixels = [Pixel](repeating: pixel, count: width * height)
        
        for x in 0..<width {
            for y in 0..<height {
                let computedPixel = computePixel(x, y, width, height)
                pixel = computedPixel
                pixels[x + y * width] = pixel
            }
        }
        
        return PixelSet(pixels: pixels, width: width, height: height)
    }
    
    func makeSpherePixelSet(width: Int, height: Int) -> PixelSet {
        
        var pixel = Pixel(r: 0, g: 0, b: 0, a: 255)
        var pixels = [Pixel](repeating: pixel, count: width * height)
        
        let lowerLeftCorner = SIMD3<Float>(x: -2.0, y: 1.0, z: -1.0)
        let horizontal = SIMD3<Float>(x: 4.0, y: 0, z: 0)
        let vertical = SIMD3<Float>(x: 0, y: -2.0, z: 0)
        let origin = SIMD3<Float>()
        
        for i in 0..<width {
            for j in 0..<height {
                let u = Float(i) / Float(width)
                let v = Float(j) / Float(height)
                let r = Ray(origin: origin, direction: lowerLeftCorner + u * horizontal + v * vertical)
                let col = color(ray: r)
                pixel = Pixel(r: UInt8(col.x * 255), g: UInt8(col.y * 255), b: UInt8(col.z * 255), a: 255)
                pixels[i + j * width] = pixel
            }
        }
        
        return PixelSet(pixels: pixels, width: width, height: height)
    }
    
    // MARK: - Private utlity methods
    
    private func hitSphere(center: SIMD3<Float>, radius: Double, ray: Ray) -> Double  {
        let origin = ray.origin - center
        let direction = ray.direction
        let a = dot(direction, direction)
        let b = 2.0 * dot(origin, direction)
        let c = dot(origin, origin) - Float(radius * radius)
        let discriminant = b * b - 4 * a * c
        
        if discriminant < 0 {
            return -1.0
        } else {
            return Double((-b - sqrt(discriminant)) / (2.0 * a))
        }
    }
    
    
    private func color(ray: Ray) -> SIMD3<Float> {
        let minusZ = SIMD3<Float>(x: 0, y: 0, z: -1.0)
        var t = hitSphere(center: minusZ, radius: 0.5, ray: ray)
        
        if t > 0.0 {
            let computedRay = ray.compute(Float(t))
            let negated = computedRay - minusZ
            let norm = negated.unit()
            return 0.5 * SIMD3<Float>(x: norm.x + 1.0, y: norm.y + 1.0, z: norm.z + 1.0)
        }
        
        let unitDireciton = ray.direction.unit()
        t = Double(0.5 * (unitDireciton.y + 1.0))
        
        return Float(1.0 - t) * SIMD3<Float>(1.0, 1.0, 1.0) + Float(t) * SIMD3<Float>(0.5, 0.7, 1.0)
    }
    
    
    // MARK: - Rendering
    
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
