//
//  Image+.swift
//  WeatherForYou
//
//  Created by Bora Yang on 11/19/23.
//

import UIKit

extension UIImage {
    func makeShadow() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)

        if let context = UIGraphicsGetCurrentContext() {
            let shadowOffset = CGSize(width: 5, height: 5)
            let shadowBlur: CGFloat = 20.0
            let shadowColor = UIColor.darkGray.cgColor

            context.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor)
            self.draw(at: .zero)

            let imageWithShadow = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

            if let imageWithShadow = imageWithShadow {
                return imageWithShadow
            }
        }
        return nil
    }
}
