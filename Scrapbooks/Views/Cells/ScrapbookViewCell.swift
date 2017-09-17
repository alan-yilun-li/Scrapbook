//
//  ScrapbookViewCell.swift
//  Scrapbook
//
//  Created by Dev User on 2017-07-20.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit

class ScrapbookViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var scrapbookNameLabel: UILabel!
    
    override func awakeFromNib() {
        let cornerRadius: CGFloat = 10
        layer.cornerRadius = cornerRadius
        coverImageView.layer.cornerRadius = cornerRadius
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
    }
    
    func refreshCellView(forScrapbook scrapbook: Scrapbook?) {
        
        if scrapbook == nil || !scrapbook!.isLocked {
            
            ViewCustomizer.removeEffects(fromView: coverImageView)
            ViewCustomizer.removeLockIconOverlay(from: coverImageView)
        } else {

            ViewCustomizer.addBlurEffect(toView: coverImageView)
            ViewCustomizer.addLockOverlay(on: coverImageView)
        }
    }
    
    /// Sets up a cell with the proper image and name given its associated scrapbook data. 
    func setup(withScrapbook scrapbook: Scrapbook) {
        
        scrapbookNameLabel.text = scrapbook.name
        coverImageView.image = scrapbook.coverPhoto
        
        if scrapbook.isLocked {
            ViewCustomizer.addBlurEffect(toView: coverImageView)
            ViewCustomizer.addLockOverlay(on: coverImageView)
        }
    }
    
}
