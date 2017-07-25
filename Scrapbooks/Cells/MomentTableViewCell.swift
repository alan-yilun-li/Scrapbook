//
//  MomentTableViewCell.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-22.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class MomentTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var photoNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
