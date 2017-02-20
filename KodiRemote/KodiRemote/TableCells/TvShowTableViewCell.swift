//
//  TvShowTableViewCell.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 22/02/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class TvShowTableViewCell: UITableViewCell {

    @IBOutlet var tvshowImage: UIImageView!
    @IBOutlet var tvshowlabel: UILabel!
    @IBOutlet var totalEpisodes: UILabel!
    @IBOutlet var premiered: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
