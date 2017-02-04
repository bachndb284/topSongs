//
//  TableViewCell.swift
//  Topsongs
//
//  Created by Nguyen Bach on 2/1/17.
//  Copyright © 2017 Nguyen Bach. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var imageSongs: UIImageView!
    @IBOutlet weak var buttonPrice: UIButton!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var songNames: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
