//
//  ImageTableViewCell.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 10.12.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewStatus: UIImageView!
    @IBOutlet weak var lableFromWhomMessenge: UILabel!
    @IBOutlet weak var imageViewTransferedPic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}