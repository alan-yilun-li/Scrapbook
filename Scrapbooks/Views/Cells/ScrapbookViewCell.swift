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
    
    private var scrapbookToRep: Scrapbook?
    
    override func awakeFromNib() {
        print("creating cell")
        let cornerRadius: CGFloat = 10
        layer.cornerRadius = cornerRadius
        coverImageView.layer.cornerRadius = cornerRadius
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if scrapbookToRep == nil { return }
        
        if scrapbookToRep!.isLocked {
            
            print("Adding blur effect")
            ViewCustomizer.addBlurEffect(toView: coverImageView)
            ViewCustomizer.addLockOverlay(on: coverImageView)
        } else {
            print("Removing blur effects")
            ViewCustomizer.removeEffects(fromView: coverImageView)
            ViewCustomizer.removeLockIconOverlay(from: coverImageView)
            coverImageView.image = scrapbookToRep!.coverPhoto
        }
    }
    
    /// Sets up a cell with the proper image and name given its associated scrapbook data. 
    func setup(withScrapbook scrapbook: Scrapbook) {
        
        scrapbookNameLabel.text = scrapbook.name
        coverImageView.image = scrapbook.coverPhoto
        scrapbookToRep = scrapbook
        
        if scrapbook.isLocked {
            ViewCustomizer.addBlurEffect(toView: coverImageView)
            ViewCustomizer.addLockOverlay(on: coverImageView)
        }
    }
    
}
