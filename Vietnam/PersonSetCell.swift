//
//  PersonSetCell.swift
//  Vietnam
//
//  Created by Oleg Kuplin on 28.11.16.
//  Copyright © 2016 Oleg Kuplin. All rights reserved.
//

import UIKit

class PersonSetCell: UITableViewCell {

    
    @IBOutlet weak var cellItem: UILabel!
    @IBOutlet weak var cellValue: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
