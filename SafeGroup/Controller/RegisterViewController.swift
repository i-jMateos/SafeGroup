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

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print(error)
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let window = appDelegate.window
                let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                window?.rootViewController = mainController
                window?.makeKeyAndVisible()
            }
        }
    }

    
    @IBAction func registerButton(_ sender: Any) {
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        register(email: email, password: password)
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
