//
//  AppDelegate.swift
//  Peawell
//
//  Created by Dennis on 29.04.22.
//

import UIKit

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

var dialogMessage = UIAlertController(title: "Attention", message: "I am an alert message you cannot dissmiss.", preferredStyle: .alert)
// Present alert to user

    /*
    let sVC = SettingsViewController()
    sVC.modalPresentationStyle = .fullScreen
    sVC.modalTransitionStyle = .crossDissolve
    self.present(sVC, animated: true)
    */
     
/*
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
        if shortcutItem.type == "org.semmelstulle.beanwell.AgendaAction" {
            
            //self.present(dialogMessage, animated: true, completion: nil)

        }
        if shortcutItem.type == "org.semmelstulle.beanwell.ActionsAction" {
            // shortcut was triggered!
            //self.present(dialogMessage, animated: true, completion: nil)

        }
        if shortcutItem.type == "org.semmelstulle.beanwell.SettingsAction" {
            // shortcut was triggered!
            
             
            //self.window = UIWindow(frame: UIScreen.main.bounds)
            //self.window?.rootViewController = sVC
            //self.window?.makeKeyAndVisible()
            //self.window?.becomeKey()
            //self.present(dialogMessage, animated: true, completion: nil)

        }
    }

    return true
}
*/

