//
//  GradientViewController.swift
//  metal-path-ios-app
//
//  Created by Astemir Eleev on 08/03/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import UIKit

class GradientViewController: UIViewController {

    // MARK: - Properties
    
    let rayTracer = RayTracer()
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let image = prepareCustom()
        imageView.image = image
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Utility
    
    func prepareGradient() -> UIImage {
        let pixelSet = rayTracer.makeGradientPixelSet(width: 600, height: 400)
        let image = rayTracer.render(pixelSet: pixelSet)
        
        let uimage = UIImage(ciImage: image)
        return uimage
    }
    
    func prepareCustom() -> UIImage {
        let pixelSet = rayTracer.makeGradientPixelSet(width: 600, height: 800) { (x, y, width, height) -> Pixel in

            let red = UInt8(Double(y * 255 / height))
            let green = UInt8(Double(x * 255 / width))
            let blue = UInt8(Double(y * 255 / height))
            
            let pixel = Pixel(r: red, g: green, b: blue, a: 255)
            return pixel
        }
        let image = rayTracer.render(pixelSet: pixelSet)
        
        let uimage = UIImage(ciImage: image)
        return uimage
    }
    
    
    
}
