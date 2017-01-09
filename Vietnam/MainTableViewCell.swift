//
//  MainTableViewCell.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 08.01.17.
//  Copyright © 2017 Oleg Kuplin. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var adIMage: UIImageView!
    @IBOutlet weak var adCatSub: UILabel!
    @IBOutlet weak var adDate: UILabel!
    @IBOutlet weak var adHeader: UILabel!
    @IBOutlet weak var adInfo: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
