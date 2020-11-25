//
//  EventDetailsViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 23/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import Firebase

class EventDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var event: Event!
    
    let db = Firestore.firestore()
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView(with: event)
    }
    
    private func setupView(with event: Event) {
        titleLabel.text = event.name
        startDateLabel.text = dateFormatter.string(from: event.startDate)
        endDateLabel.text = dateFormatter.string(from: event.endDate)
        
        let participants = event.participants?.compactMap({ $0.email }).joined(separator: " : ") ?? ""
        
        descriptionTextView.text = event.description + participants
        
        guard let user = Auth.auth().currentUser else { return }
        if user.email == event.user.email {
            actionButton.setTitle("Eliminar evento", for: .normal)
            actionButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        } else {
            if event.participants?.contains(where: { $0.email == user.email }) ?? false {
                actionButton.setTitle("Anular registro", for: .normal)
                actionButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            } else {
                actionButton.setTitle("Registrarme", for: .normal)
                actionButton.backgroundColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
        }
    }
    
    @IBAction func actionButtonDidPress(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        
        if user.email == event.user.email {
            return
        } else {
            if event.participants?.contains(where: { $0.email == user.email }) ?? false {
                return
            } else {
                let eventsReference = db.collection("events").document(self.event.id)

                let user = User(id: user.uid, email: user.email ?? "")
                
                var registeredUsers = event.participants ?? []
                registeredUsers.append(user)
                let mappedUsers = registeredUsers.map({ $0.dictionary })
                
                eventsReference.updateData([
                    "users": mappedUsers
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            }
        }
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
