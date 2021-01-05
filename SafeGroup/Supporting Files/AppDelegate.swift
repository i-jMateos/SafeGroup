//
//  AppDelegate.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 11/11/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        if let _ = Auth.auth().currentUser {
            if let userData = UserDefaults.standard.object(forKey: Constants.UserDefaults.currentUser) as? Data, let user = try? JSONDecoder().decode(User.self, from: userData) {
                User.setCurrent(user)
            }
            
            let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            window?.rootViewController = mainController
            window?.makeKeyAndVisible()
        } else {
            let mainController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            window?.rootViewController = mainController
            window?.makeKeyAndVisible()
        }
        
        return true
    }

}

