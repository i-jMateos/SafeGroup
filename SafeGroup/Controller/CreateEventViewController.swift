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

protocol CreateEventViewDelegate {
    func eventCreated(event: Event)
}

class CreateEventViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var addImagesButton: UIButton!
    @IBOutlet weak var eventImageView: UIImageView!
    
    var datepicker = UIDatePicker()
    
    let db = Firestore.firestore()
    var eventsReference: DocumentReference? = nil
    
    let storage = Storage.storage()
    
    var delegate: CreateEventViewDelegate?
    
    var latitude: Double?
    var longitude: Double?
    var eventImages: UIImage?
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        eventsReference = db.collection("events").document()
        
        createDatePicker()
        setupUI()
    }
    
    private func setupUI() {
        eventDescriptionTextView.layer.borderWidth = 0.5
        eventDescriptionTextView.layer.cornerRadius = 8
        eventDescriptionTextView.layer.borderColor = UIColor.darkGray.cgColor
        
        self.startDateTextField.delegate = self
        self.endDateTextField.delegate = self
        
        if let latitude = self.latitude, let longitude = self.longitude {
            
            self.geocode(latitude: latitude, longitude: longitude) { (placemark, error) in
                if let placemark = placemark?.first {
                    
                    let address = [placemark.name ?? "",
                                   placemark.locality ?? "",
                                   placemark.postalCode ?? "",
                                   placemark.country ?? ""].joined(separator: ", ")
                    
                    self.addressLabel.text = address
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func createEvent(event: Event) {
        guard let eventEncoded = event.dictionary else { return }
        
        self.showLoading(onView: self.view)
        eventsReference?.setData(eventEncoded, completion: { (err) in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.eventsReference!.documentID)")
                self.delegate?.eventCreated(event: event)
                self.dismiss(animated: true, completion: nil)
            }
            
            self.removeLoading()
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
    
    @IBAction func addImagesButtonAction(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Select an option", message: "Message", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            alertController.addAction(photoLibraryAction)
        }
        
        alertController.popoverPresentationController?.sourceView = sender
        
        present(alertController, animated: true, completion: nil)
    }
    
    // TODO: Crear vista para mostrar mensaje de error.
    @IBAction func createEventButton(_ sender: Any) {
        let title = titleTextField.text ?? ""
        
        /// No permitir crear un evento si las coordenadas son nulas.
        guard let lat = self.latitude, let lon = self.longitude else { return }
        
        /// No permitir crear un evento si las fechas son incorrectas.
        guard let startDate = dateFormatter.date(from: self.startDateTextField.text ?? ""),
            let endDate = dateFormatter.date(from: self.endDateTextField.text ?? "") else {
                return
        }
        
        let description = self.eventDescriptionTextView.text ?? ""
        
        let currentUser = Auth.auth().currentUser
        let user = User(id: currentUser?.uid ?? "", email: currentUser?.email ?? "")
        
        guard let documentId = eventsReference?.documentID else { return }
        let event = Event(id: documentId, name: title, localitation: Location(latitude: lat, longitude: lon), startDate: startDate, endDate: endDate, eventCode: nil, description: description, user: user, imageUrl: nil, participants: nil)
        
        self.showLoading(onView: self.view)
        if let imageData = self.eventImageView.image?.jpegData(compressionQuality: 80) {
            let storageRef = storage.reference()
            let eventsRef = storageRef.child("images/\(event.id).jpg")
            
            let uploadTask = eventsRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                eventsRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    event.imageUrl = downloadURL.absoluteString
                    self.createEvent(event: event)
                }
                
                self.removeLoading()
            }
        }
    }
    
    func createDatePicker() {
        datepicker = UIDatePicker()
        datepicker.minimumDate = Date().addingTimeInterval(3600)
        
        datepicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        startDateTextField.inputView = datepicker
        endDateTextField.inputView = datepicker
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        if startDateTextField.isFirstResponder {
            self.startDateTextField.text = dateFormatter.string(from: sender.date)
        } else if endDateTextField.isFirstResponder {
            self.endDateTextField.text = dateFormatter.string(from: sender.date)
        }
        
        /// No permitir fecha de fin anterior a la de inicio.
//        if let startDate = dateFormatter.date(from: self.startDateTextField.text ?? ""),
//            let endDate = dateFormatter.date(from: self.endDateTextField.text ?? "") {
//            if endDate < startDate {
//                self.endDateTextField.text = dateFormatter.string(from: startDate)
//            }
//        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
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

extension CreateEventViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.endDateTextField {
            guard let startDateText = self.startDateTextField.text, let startDate = dateFormatter.date(from: startDateText) else { return }
            self.datepicker.minimumDate = startDate
        } else {
            self.datepicker.minimumDate = Date().addingTimeInterval(3600)
        }
    }
}

extension CreateEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        self.eventImageView.image = image
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
