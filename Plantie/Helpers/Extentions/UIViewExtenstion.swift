
import Foundation
import UIKit


extension UIView {
    func applyGradient(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    func corener(by value:Int){
        self.layer.cornerRadius = CGFloat(value)
    }
}


