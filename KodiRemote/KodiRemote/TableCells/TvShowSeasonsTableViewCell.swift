//
//  TvShowEpisodeTableViewCell.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 31/03/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class TvShowSeasonsTableViewCell: UITableViewCell {

    @IBOutlet weak var seasonTitle: UILabel!
    @IBOutlet weak var seasonImage: UIImageView!
    @IBOutlet weak var totalEpisodes: UILabel!
    @IBOutlet weak var watchedEpisodes: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
