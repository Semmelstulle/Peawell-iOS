//
//  SceneDelegate.swift
//  Peawell
//
//  Created by Dennis on 29.04.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    //  store all variables conveniently in one place
    var window: UIWindow?
    var savedShortCutItem: UIApplicationShortcutItem!
    var tabBar = TabBarViewController()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        
        if let shortcutItem = connectionOptions.shortcutItem {
            savedShortCutItem = shortcutItem
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
        self.window = window
        
    }
    
    /*
    not needed currently
     
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    */

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleQuickAct(item: shortcutItem.type)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        // checks if any shortcut item was launched
        if savedShortCutItem != nil {
            handleQuickAct(item: savedShortCutItem.type)
        }
    }

    //  executes the chosen quick action and sets the variable back to nil
    func handleQuickAct(item: String) {
        switch item {
        case "org.semmelstulle.peawell.MainAction":
            tabBar.selectedIndex = 0
        case "org.semmelstulle.peawell.ActionsAction":
            tabBar.selectedIndex = 1
        case "org.semmelstulle.peawell.RemindersAction":
            tabBar.selectedIndex = 2
        case "org.semmelstulle.peawell.SettingsAction":
            tabBar.selectedIndex = 3
        default:
            print("No item found.")
        }
        savedShortCutItem = nil
    }
    
    
    
    /*
     
    I don't use any of this for now so it's commented out
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    */

}

