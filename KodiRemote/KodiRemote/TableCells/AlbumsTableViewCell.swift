//
//  AlbumsTableViewCell.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 05/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class AlbumsTableViewCell: UITableViewCell {
    
    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var albumName: UILabel!
    @IBOutlet var albumArtists: UILabel!
    @IBOutlet var albumGenre: UILabel!
    @IBOutlet var albumInitial: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
