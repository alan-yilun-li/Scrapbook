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
    
    @IBOutlet weak var scrapbookTitleLabel: UILabel!
    
    override func awakeFromNib() {
        print("creating cell")
        let cornerRadius: CGFloat = 10
        layer.cornerRadius = cornerRadius
        coverImageView.layer.cornerRadius = cornerRadius
    }
    
    /// Sets up a cell with the proper image and title given its associated scrapbook data. 
    func setup(withScrapbook scrapbook: Scrapbook) {
        
        coverImageView.image = scrapbook.coverPhoto
        scrapbookTitleLabel.text = scrapbook.title 
    }
    
}
