//
//  AdsInfoCell.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 28.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit

class AdsInfoCell: UITableViewCell {

    
    @IBOutlet weak var setImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rightArrowImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
