//
//  CaptionTextView.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-02.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit

class CaptionTextView: UITextView {
    
    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()
        
        let topLine = CGMutablePath()
        topLine.move(to: CGPoint(x: rect.minX, y: rect.minY))
        topLine.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        context?.addPath(topLine)
        context?.setStrokeColor(UIColor.maroon.cgColor)
        context?.setLineWidth(2.0)
        
        context?.strokePath()
        
        let bottomLine = CGMutablePath()
        bottomLine.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        bottomLine.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        context?.addPath(bottomLine)
        context?.setLineWidth(2.0)
        context?.setStrokeColor(UIColor.fadedMaroon.cgColor)
        
        context?.strokePath()

        super.draw(rect)
        layer.borderWidth = 0 
    }
}
