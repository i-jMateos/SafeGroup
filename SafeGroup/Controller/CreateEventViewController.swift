//
//  CreateEventViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 17/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import Firebase

class CreateEventViewController: UIViewController {

    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var lonTextField: UITextField!
    
    let db = Firestore.firestore()
    let datepicker = UIDatePicker()
    
    var eventsReference: DocumentReference? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsReference = db.collection("events").document()

        datepicker.preferredDatePickerStyle = .wheels
        startDateTextField.inputAccessoryView = datepicker
        // Do any additional setup after loading the view.
    }
    
    func createEvent(event: Event) {
        guard let eventEncoded = event.dictionary else { return }
        
        eventsReference?.setData(eventEncoded, completion: { (err) in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.eventsReference!.documentID)")
            }
        })
    }
    
    @IBAction func createEventButton(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let lat = Double(latTextField.text ?? "0") ?? 0.0
        let lon = Double(lonTextField.text ?? "0") ?? 0.0
        let startDate = Date()
        let endDate = Date()
        let description =  "Una descripcion del evento."
        
        let currentUser = Auth.auth().currentUser
        let user = User(id: currentUser?.uid ?? "", email: currentUser?.email ?? "")
        
        guard let documentId = eventsReference?.documentID else { return }
        let event = Event(id: documentId, name: title, localitation: Location(latitude: lat, longitude: lon), startDate: startDate, endDate: endDate, eventCode: nil, description: description, user: user, imageUrl: nil, participants: nil)
        
        createEvent(event: event)
    }
    
    func createDatePicker() {
    
    let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        _ = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        
        startDateTextField.inputAccessoryView = toolbar
    
        startDateTextField.inputView = datepicker
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

}
