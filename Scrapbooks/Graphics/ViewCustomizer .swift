//
//  ViewCustomizer .swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-08-03.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import UIKit

struct ViewCustomizer {
    
    static func customize(navigationBar: UINavigationBar) {
        navigationBar.isTranslucent = true
        Colours.fill(navigationBar: navigationBar)
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: Fonts.titleFont as Any]
    }
    
    static func customizeToolbar(forNavigationController navController: UINavigationController) {
        
        // GRAPHICS SETUP
        let toolBar = navController.toolbar
        toolBar!.barTintColor = Colours.yellow
        toolBar!.tintColor = Colours.brown
    }

    static func customize(nameLabel: UITextField) {
        if let subviews = nameLabel.layer.sublayers?.count,
            subviews > 0 {
            return
        }
        
        print("did run")
        
        nameLabel.borderStyle = .none
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = Colours.brown.cgColor
        border.frame = CGRect(x: 0, y: nameLabel.frame.size.height - width, width:  nameLabel.frame.size.width, height: nameLabel.frame.size.height)
        
        border.borderWidth = width
        nameLabel.layer.addSublayer(border)
        nameLabel.layer.masksToBounds = true
        nameLabel.setNeedsDisplay()
    }
    
    static func addBlurEffect(toView view: UIView) {
        
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        
        // Setting the blur effect's size and location in terms of the view's coordinate system
        blurView.frame = view.bounds
        
        view.insertSubview(blurView, at: 0)
    }
    
    static func removeEffects(fromView view: UIView) {
        
        for subview in view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
    
    static func addLockOverlay(on imageView: UIImageView) {
        
        let lockImageView = UIImageView(image: #imageLiteral(resourceName: "LockIcon"))
        imageView.addSubview(lockImageView)
        lockImageView.center = imageView.center
    }
    
    
    
    static func removeLockIconOverlay(from imageView: UIImageView) {
        
        for subview in imageView.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
    }
}
