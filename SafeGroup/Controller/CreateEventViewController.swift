//
//  CreateEventViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 17/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class CreateEventViewController: UIViewController {

    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var lonTextField: UITextField!
    
    let db = Firestore.firestore()
    var datepicker = UIDatePicker()
    
    var eventsReference: DocumentReference? = nil
    
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        eventsReference = db.collection("events").document()

        createDatePicker()
        setupUI()
    }
    
    private func setupUI() {
        if let latitude = self.latitude, let longitude = self.longitude {
            self.latTextField.text = "\(latitude)"
            self.lonTextField.text = "\(longitude)"
            
            self.geocode(latitude: latitude, longitude: longitude) { (placemark, error) in
                if let placemark = placemark?.first {
                    self.titleTextField.text = placemark.locality
                }
            }
        }
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
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemark, error in
            guard let placemark = placemark, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }
    
    @IBAction func createEventButton(_ sender: Any) {
        let title = titleTextField.text ?? ""
        let lat = Double(latTextField.text ?? "0") ?? 0.0
        let lon = Double(lonTextField.text ?? "0") ?? 0.0
        let startDate = Date().addingTimeInterval(20000)
        let endDate = Date().addingTimeInterval(40000)
        let description =  "Una descripcion del evento."
        
        let currentUser = Auth.auth().currentUser
        let user = User(id: currentUser?.uid ?? "", email: currentUser?.email ?? "")
        
        guard let documentId = eventsReference?.documentID else { return }
        let event = Event(id: documentId, name: title, localitation: Location(latitude: lat, longitude: lon), startDate: startDate, endDate: endDate, eventCode: nil, description: description, user: user, imageUrl: nil, participants: nil)
        
        createEvent(event: event)
    }
    
    func createDatePicker() {
        datepicker = UIDatePicker()
        datepicker.minimumDate = Date()
        datepicker.preferredDatePickerStyle = .wheels
        datepicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        startDateTextField.inputView = datepicker
        
        endDateTextField.inputView = datepicker
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        if startDateTextField.isFirstResponder {
            self.startDateTextField.text = dateFormatter.string(from: sender.date)
        } else if endDateTextField.isFirstResponder {
            self.endDateTextField.text = dateFormatter.string(from: sender.date)
        }
        
        /// No permitir fecha de fin anterior a la de inicio.
        if let startDate = dateFormatter.date(from: self.startDateTextField.text ?? ""),
           let endDate = dateFormatter.date(from: self.endDateTextField.text ?? "") {
            if endDate < startDate {
                self.endDateTextField.text = dateFormatter.string(from: startDate)
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
