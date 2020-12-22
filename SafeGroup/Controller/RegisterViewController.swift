//
//  RegisterViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 16/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var createCountTextField: UILabel!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    let db = Firestore.firestore()
    var usersReference: DocumentReference? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usersReference = db.collection("users").document()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func register(email: String, password: String, firstName: String, lastName: String, role: Role) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print(error)
            } else {
                guard let id = authResult?.user.uid else { return }
                
                let user = User(id: id, email: email, firtname: firstName, lastname: lastName, role: role)
                guard let userEncoded = user.dictionary else { return }
                
                usersReference?.setData(userEncoded, completion: { (err) in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(self.usersReference!.documentID)")
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let window = appDelegate.window
                        let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                        window?.rootViewController = mainController
                        window?.makeKeyAndVisible()
                    }
                })
            }
        }
    }

    
    @IBAction func registerButton(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let firstName = self.firstnameTextField.text else { return }
        guard let lastName = self.lastnameTextField.text else { return }
        
        var role: Role!
        let index = roleSegmentedControl.selectedSegmentIndex
        if index == 0 {
            role = .guia
        } else {
            role = .participante
        }
        
        register(email: email, password: password, firstName: firstName, lastName: lastName, role: role)
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
