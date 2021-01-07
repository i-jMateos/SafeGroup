//
//  EventAlertTableViewCell.swift
//  SafeGroup
//
//  Created by jmateos on 28/12/20.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import MapKit

class EventAlertTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var alertMessageLabel: UILabel!
    @IBOutlet weak var alertTimestampLabel: UILabel!
    @IBOutlet weak var navigateToLocationButton: UIButton!
    
    var alert: EventAlert?
    
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func openMapForPlace(alert: EventAlert) {
        guard let latitude = alert.lastUserLocalation?.latitude else { return }
        guard let longitude = alert.lastUserLocalation?.longitude else { return }
        let regionDistance: CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = alert.user?.displayName
        mapItem.openInMaps(launchOptions: options)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func navigateToLocationButtonPressed(_ sender: Any) {
        openMapForPlace(alert: self.alert!)
    }
}
