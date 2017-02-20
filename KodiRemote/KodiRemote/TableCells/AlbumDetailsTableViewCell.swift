//
//  AlbumDetailsTableViewCell.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 06/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class AlbumDetailsTableViewCell: UITableViewCell {

    @IBOutlet var songImage: UIImageView!
    @IBOutlet var songName: UILabel!
    @IBOutlet weak var songInitial: UILabel!
    
    @IBOutlet weak var albumArtists: UILabel!
    @IBOutlet weak var otherDetails: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
