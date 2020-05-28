//
//  TableViewCell.swift
//  MemeMe
//
//  Created by George Solorio on 5/26/20.
//  Copyright © 2020 George Solorio. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UILabel!
    @IBOutlet weak var memeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
