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

    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let currentUser = Auth.auth().currentUser
        emailLabel.text = currentUser?.email
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
