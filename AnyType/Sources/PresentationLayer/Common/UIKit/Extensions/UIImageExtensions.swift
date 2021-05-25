//
//  UIImageExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 24.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    /// Makes rounded image with given corner radius.
    ///
    /// - Parameter radius: The corner radius.
    /// - Parameter opaque: A Boolean flag indicating whether the bitmap is opaque.
    /// If you know the bitmap is fully opaque, specify YES to ignore the alpha channel and optimize
    /// the bitmap’s storage.
    /// Specifying NO means that the bitmap must include an alpha channel to handle any partially
    /// transparent pixels
    /// - Returns: Rounded image.
    func rounded(radius: CGFloat, opaque: Bool = false, backgroundColor: CGColor? = nil) -> UIImage {
        let rect = CGRect(origin: .zero, size: self.size)

        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, UIScreen.main.scale)

        defer {
            UIGraphicsEndImageContext()
        }

        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }

        if let backgroundColor = backgroundColor {
            context.setFillColor(backgroundColor)
            context.fill(rect)
        }

        context.beginPath()
        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: radius, y: radius)

        let rectWidth = rect.width / radius
        let rectHeight = rect.height / radius

        let path = CGMutablePath()
        path.move(to: CGPoint(x: rectWidth, y: rectHeight / 2))
        path.addArc(tangent1End: CGPoint(x: rectWidth, y: rectHeight), tangent2End: CGPoint(x: rectWidth / 2, y: rectHeight), radius: 1)
        path.addArc(tangent1End: CGPoint(x: 0, y: rectHeight), tangent2End: CGPoint(x: 0, y: rectHeight / 2), radius: 1)
        path.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: rectWidth / 2, y: 0), radius: 1)
        path.addArc(tangent1End: CGPoint(x: rectWidth, y: 0), tangent2End: CGPoint(x: rectWidth, y: rectHeight / 2), radius: 1)
        context.addPath(path)
        context.restoreGState()
        context.closePath()
        context.clip()

        draw(in: rect)

        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()

        return roundedImage ?? self
    }
    
}
