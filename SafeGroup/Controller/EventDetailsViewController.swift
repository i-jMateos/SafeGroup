//
//  EventDetailsViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 23/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView(with: event)
    }
    
    private func setupView(with event: Event?) {
        titleLabel.text = event?.name
        startDateLabel.text = "\(event?.startDate)"
        endDateLabel.text = "\(event?.endDate)"
        descriptionTextView.text = event?.description
    }
    
    @IBAction func actionButtonDidPress(_ sender: Any) {
    }
    
    @IBAction func closeButtonDidPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
