//
//  AlbumDetailsTableViewCell.swift
//  KodiRemote
//
//  Created by Quixom Technology on 06/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class AlbumDetailsTableViewCell: UITableViewCell {

    @IBOutlet var songImage: UIImageView!
    @IBOutlet var songName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
