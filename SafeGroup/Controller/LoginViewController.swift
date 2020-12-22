//
//  LoginViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 11/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print(error)
            } else {
                // Buscar en Firebase el usuario con ID igual al que esta en authResult
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let window = appDelegate.window
                let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                window?.rootViewController = mainController
                window?.makeKeyAndVisible()
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        login(email: email, password: password)
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
