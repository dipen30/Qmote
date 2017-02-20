//
//  DiscoveryTableViewCell.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 27/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class DiscoveryTableViewCell: UITableViewCell {

    @IBOutlet var serviceImage: UIImageView!
    @IBOutlet var serviceName: UILabel!
    @IBOutlet var serviceIp: UILabel!
    @IBOutlet var servicePort: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
