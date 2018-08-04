//
//  HudView.swift
//  MyLocations
//
//  Created by Ronald Tong on 4/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import Foundation
import UIKit

class HudView: UIView {
    
    var text = ""
    
    // Convenience constructor: always class method (class func).
    // Creates and returns a HudView instance to the caller, also adds the HudView object as a subview over the parent view, and disallows uers to interact with the screen
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        hudView.show(animated: animated)
        return hudView
    }
    
    // draw() is invoked whenever UIKiet needs to redraw the view; if you need a redraw send the setNeedsDisplay() to trigger a draw event
    // Create a filled rectangle with rounded corners in the centre of the screen, then loads the checkmark image to a UI Image object to be centered based off the HUD view center coordinate
    // When working with UIKit or CG use the CGFloat instead of the usual Float or Double
    // Use the round() function so the rectangle doesn't end up on fractional pixel boundaries as this can make the image appear fuzzy
    // Alpha 0.8 fills with an 80% opaque dark grey colour
    
    override func draw(_ rect: CGRect) {
    let boxWidth: CGFloat = 96
    let boxHeight: CGFloat = 96
    
    let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2 ), width: boxWidth, height: boxHeight)
    
    let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint( x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8)
            
            image.draw(at: imagePoint)
        }
        
        // Create a UIFont object, choose a color for the text, and place it into a dictionary named into attribs
        
        let attribs = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white ]
        
        let textSize = text.size(withAttributes: attribs)
        let textPoint = CGPoint( x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    // UIView-based animation
    // 1. Set up initial state of view. Alpha = 0 makes the view fully transparent, scaleX 1.3 transforms the view to be stretched
    // 2. Call UIView.animate and use a closure to describe the animation
    // 3. Set up the new state of view inside the closure; alpha 1 means HudView is opaque and transform identity restores scale back to normal. Use self to refer to HudView as this is inside a closure
    
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}
