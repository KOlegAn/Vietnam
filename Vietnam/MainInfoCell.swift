//
//  MainInfoCell.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 19.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit

class MainInfoCell: UITableViewCell {

    
    
    
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
