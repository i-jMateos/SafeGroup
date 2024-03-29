//
//  MyEventsViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 30/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import MapKit

class MyEventsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                     #selector(MyEventsViewController.handleRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    var currentEvent: Event?
    var futureEvents: [Event]? = [Event]()
    var pastEvents: [Event]? = [Event]()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        let nib = UINib(nibName: MyEventTableViewCell.reuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: MyEventTableViewCell.reuseIdentifier)
        tableView.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getMyEvents()
    }
    
    private func getMyEvents() {
        currentEvent = nil
        self.futureEvents = []
        self.pastEvents = []
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        /// Recuperar eventos en los que el usuario esta inscrito.
        guard let user = User(id: currentUser.uid, email: currentUser.email ?? "").dictionary else { return }
        db.collection("events")
            .whereField("participants", arrayContains: user)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let dict = document.data()
                        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
                        
                        guard let event: Event = try? JSONDecoder().decode(Event.self, from: jsonData!) else { return }
                        
                        /// Eventos pasados
                        if event.endDate <= Date() {
                            self.pastEvents?.append(event)
                            /// Eventos futuros
                        } else if event.startDate > Date() {
                            self.futureEvents?.append(event)
                            /// Evento actual
                        } else if Date().isBetween(startDate: event.startDate, endDate: event.endDate) {
                            self.currentEvent = event
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    }
                }
        }
            
        /// Recuperar eventos creados por el usuario.
        self.db.collection("events")
            .whereField("user", isEqualTo: user)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let dict = document.data()
                        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
                        
                        guard let event: Event = try? JSONDecoder().decode(Event.self, from: jsonData!) else { return }
                        
                        /// Eventos pasados
                        if event.endDate <= Date() {
                            self.pastEvents?.append(event)
                            /// Eventos futuros
                        } else if event.startDate > Date() {
                            self.futureEvents?.append(event)
                            /// Evento actual
                        } else if Date().isBetween(startDate: event.startDate, endDate: event.endDate) {
                            self.currentEvent = event
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    }
                }
                
        }
    }
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemark, error in
            guard let placemark = placemark, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getMyEvents()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let event = sender as? Event else { return }
        
        switch segue.identifier {
        case "activeEventSegue":
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! SegmentedViewController
            destination.event = event
        case "goToEventDetails":
            let destination = segue.destination as? EventDetailsViewController
            destination?.delegate = self
            destination?.event = event
        default:
            break
        }
    }
}

extension MyEventsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.currentEvent != nil ? 1 : 0
        case 1:
            return self.futureEvents?.count ?? 0
        case 2:
            return self.pastEvents?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyEventTableViewCell.reuseIdentifier, for: indexPath) as! MyEventTableViewCell
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:ss"
        
        var event: Event?
        
        /// Configurar celda
        switch indexPath.section {
        case 0:
            event = currentEvent
        case 1:
            event = self.futureEvents?[indexPath.row]
        case 2:
            event = self.self.pastEvents?[indexPath.row]
        default:
            break
        }
        cell.titleLabel.text = event?.name
        cell.dateLabel.text = formatter.string(from: event!.startDate)
        if let imageUrl = event?.imageUrl {
            cell.eventImageView?.kf.setImage(with: URL(string: imageUrl))
        }
        
        if let lat = event?.localitation.latitude, let lon = event?.localitation.longitude {
            geocode(latitude: lat, longitude: lon) { (placemarks, error) in
                if let placemark = placemarks?.first {
                    
                    let address = [placemark.name ?? "",
                                   placemark.locality ?? "",
                                   placemark.postalCode ?? "",
                                   placemark.country ?? ""].joined(separator: ", ")
                    
                    cell.subtitleLabel.text = address
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Evento actual"
        case 1:
            return "Eventos proximos"
        case 2:
            return "Eventos pasados"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var event: Event? = nil
        
        switch indexPath.section {
        case 0:
            event = self.currentEvent
            self.performSegue(withIdentifier: "activeEventSegue", sender: event)
        case 1:
            event = self.futureEvents?[indexPath.row]
            self.performSegue(withIdentifier: "goToEventDetails", sender: event)
        case 2:
            event = self.pastEvents?[indexPath.row]
            self.performSegue(withIdentifier: "goToEventDetails", sender: event)
        default:
            break
        }
    }
}

extension MyEventsViewController: EventDetailsDelegate {
    func eventDetails(didDeleteEvent event: Event) {
        self.futureEvents?.removeAll(where: { $0.id == event.id })
        self.tableView.reloadData()
    }
}
