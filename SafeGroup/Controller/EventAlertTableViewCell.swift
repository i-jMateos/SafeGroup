//
//  EventAlertTableViewCell.swift
//  SafeGroup
//
//  Created by jmateos on 28/12/20.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit

class EventAlertTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var alertMessageLabel: UILabel!
    @IBOutlet weak var alertTimestampLabel: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
