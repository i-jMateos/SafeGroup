//
//  UserProfileViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 13/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UITextField!
    
    @IBOutlet weak var lastnameLabel: UITextField!
    
    @IBOutlet weak var imageProfileLabel: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var roleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageProfileLabel.layer.cornerRadius = self.imageProfileLabel.frame.width/4.0
        
        let currentUser = User.currentUser
        
        nameLabel.text = currentUser?.firstname
        lastnameLabel.text = currentUser?.lastname
        emailTextField.text = currentUser?.email
        roleLabel.text = "Rol: \(currentUser?.role?.rawValue.uppercased() ?? "")" 
    }
    
    @IBAction func signoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let window = appDelegate.window
            let mainController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            window?.rootViewController = mainController
            window?.makeKeyAndVisible()
        } catch {
            print("Error al intentar cerrar sesion")
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
