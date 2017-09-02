//
//  TopLinedTextView.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-02.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit

class TopLinedTextView: UITextView {
    
    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()
        
        let line = CGMutablePath()
        line.move(to: CGPoint(x: rect.minX, y: rect.minY))
        line.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        context?.addPath(line)
        context?.setStrokeColor(Colours.maroon.cgColor)
        context?.setLineWidth(2.0)
        context?.strokePath()
        
        super.draw(rect)
        layer.borderWidth = 0 
    }


}
