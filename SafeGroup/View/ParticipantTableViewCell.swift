//
//  ParticipantTableViewCell.swift
//  SafeGroup
//
//  Created by omaestra on 16/12/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit

class ParticipantTableViewCell: UITableViewCell {

    @IBOutlet weak var participantImageView: UIImageView!
    @IBOutlet weak var participantNameLabel: UILabel!
    
    var participant: User!
    
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        participantImageView.layer.cornerRadius = participantImageView.frame.height/2
        participantImageView.backgroundColor = UIColor.lightGray
    }

    func setupView(for user: User) {
//        self.participantNameLabel.text = "\(user.firstName user.lastName)"
        self.participantNameLabel.text = user.email
    }
}
