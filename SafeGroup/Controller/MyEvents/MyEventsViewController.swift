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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getMyEvents()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let event = sender as? Event else { return }
        
        let destination = segue.destination as? EventDetailsViewController
        destination?.delegate = self
        destination?.event = event
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
        
        /// Configurar celda
        switch indexPath.section {
        case 0:
            cell.titleLabel.text = self.currentEvent?.name
            if let imageUrl = self.currentEvent?.imageUrl {
                cell.eventImageView?.kf.setImage(with: URL(string: imageUrl))
            }
        case 1:
            cell.titleLabel.text = self.futureEvents?[indexPath.row].name
            if let imageUrl = self.futureEvents?[indexPath.row].imageUrl {
                cell.eventImageView?.kf.setImage(with: URL(string: imageUrl))
            }
        case 2:
            cell.titleLabel.text = self.pastEvents?[indexPath.row].name
            if let imageUrl = self.pastEvents?[indexPath.row].imageUrl {
                cell.eventImageView?.kf.setImage(with: URL(string: imageUrl))
            }
        default:
            break
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
