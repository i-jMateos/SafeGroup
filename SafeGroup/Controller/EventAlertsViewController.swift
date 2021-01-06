//
//  EventAlertsViewController.swift
//  SafeGroup
//
//  Created by jmateos on 28/12/20.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import Firebase

class EventAlertsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var event: Event!
    var alerts: [EventAlert] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAlertsForEvent()
    }
    
    
    func getAlertsForEvent() {
        guard let eventDict = event.dictionary else { return }
        var alerts:[EventAlert] = []
        db.collection("alerts")
            .whereField("event", isEqualTo: eventDict)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let dict = document.data()
                        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
                        
                        guard let alert: EventAlert = try? JSONDecoder().decode(EventAlert.self, from: jsonData!) else { return }
                        alerts.append(alert)
                    }
                }
                self.alerts = alerts
                self.alerts.sort { (event1, event2) -> Bool in
                    event1.timestamp > event2.timestamp
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
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

extension EventAlertsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventAlertTableViewCell.reuseIdentifier, for: indexPath) as! EventAlertTableViewCell
        
        let alert = alerts[indexPath.row]
        cell.usernameLabel.text = alert.message
        cell.alertMessageLabel.text =  "\(alert.user?.email ?? "")" //"\(alert.user?.firstname ?? "") \(alert.user?.lastname ?? "")"
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        cell.alertTimestampLabel.text = dateFormatter.string(from: alert.timestamp)
        
        return cell
    }
    
    
}
