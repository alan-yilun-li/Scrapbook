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
    @IBOutlet weak var momentNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Sets up a cell with the proper image, name, and date given its associated moment data.
    func setup(withMoment moment: Moment){
        momentNameLabel.text = moment.name
        photoImageView.image = moment.photo
        dateLabel.text = String(describing: moment.date).components(separatedBy: " ").first
    }

}
