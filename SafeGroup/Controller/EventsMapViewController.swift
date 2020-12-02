//
//  EventsMapViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 16/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class EventsMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    var locationManager: CLLocationManager!

    let db = Firestore.firestore()
    
    var events: [Event]?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        getEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        determineUserLocation()
    }
    
    private func determineUserLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func getEvents() {
        events = [Event]()
        db.collection("events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let dict = document.data()
                    let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])

                    guard let event: Event = try? JSONDecoder().decode(Event.self, from: jsonData!) else { return }
                    self.events?.append(event)
                    
                    self.createEventAnnotation(event)
                }
            }
        }
    }
    
    private func createEventAnnotation(_ event: Event) {
        let mkAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = CLLocationCoordinate2D(latitude: event.localitation.latitude, longitude: event.localitation.longitude)
        mkAnnotation.title = event.name
        self.mapView.addAnnotation(mkAnnotation)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? EventDetailsViewController
        
        guard let event = sender as? Event else { return }
        destination?.event = event
        destination?.delegate = self
    }
}

extension EventsMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation: CLLocation = locations.first else { return }
        
        let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        mapView.setRegion(mRegion, animated: true)
    }
}

extension EventsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let lat = view.annotation?.coordinate.latitude,
              let lon = view.annotation?.coordinate.longitude else { return }
        
        let event = events?.first(where: {
            $0.localitation.latitude == lat.magnitude && $0.localitation.longitude == lon.magnitude
        })
        
        self.performSegue(withIdentifier: "navigateToEventDetails", sender: event)
    }
}

extension EventsMapViewController: EventDetailsDelegate {
    func eventDetails(didDeleteEvent event: Event) {
        self.events?.removeAll(where: { $0.id == event.id })
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
        for event in self.events ?? [] {
            createEventAnnotation(event)
        }
    }
}
