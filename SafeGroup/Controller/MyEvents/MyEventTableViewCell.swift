//
//  MyEventTableViewCell.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 30/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit

class MyEventTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        eventImageView.layer.cornerRadius = eventImageView.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
