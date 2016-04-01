//
//  TvShowEpisodesViewCell.swift
//  KodiRemote
//
//  Created by Quixom Technology on 01/04/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class TvShowEpisodesViewCell: UITableViewCell {

    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var episodeNumber: UILabel!
    @IBOutlet weak var runtime: UILabel!
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var episodeAired: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
