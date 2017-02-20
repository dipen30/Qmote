//
//  MoviesTableViewCell.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 29/12/15.
//  Copyright © 2015 Quixom Technology. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {
    
    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
