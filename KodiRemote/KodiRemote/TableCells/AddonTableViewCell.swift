//
//  AddonTableViewCell.swift
//  Kodi Remote
//
//  Created by Quixom Technology on 01/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class AddonTableViewCell: UITableViewCell {

    @IBOutlet var addonLabel: UILabel!
    @IBOutlet var summary: UILabel!
    @IBOutlet var addonImage: UIImageView!
    @IBOutlet var addonInitial: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
