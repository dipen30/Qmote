//
//  ArtistsTableViewCell.swift
//  KodiRemote
//
//  Created by Quixom Technology on 04/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class ArtistsTableViewCell: UITableViewCell {
    
    @IBOutlet var artistName: UILabel!
    @IBOutlet var artistImage: UIImageView!
    @IBOutlet var artistInitial: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}