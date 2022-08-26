//
//  TabBarViewController.swift
//  Peawell
//
//  Created by Dennis on 29.04.22.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //  fancy up TabBar
        tabBar.isTranslucent = true
        tabBar.backgroundColor = UIColor.systemGray6
        //  maps VCs
        let vc0 = MainViewController()
        let vc1 = ActionsViewController()
        let vc2 = ReminderViewController()
        let vc3 = SettingsViewController()
        //  force large title
//        vc1.navigationItem.largeTitleDisplayMode = .automatic
//        vc2.navigationItem.largeTitleDisplayMode = .always
//        vc3.navigationItem.largeTitleDisplayMode = .always
        //  set titles for the bar
        vc0.title = "Peawell"
        vc1.title = "Actions"
        vc2.title = "Reminders"
        vc3.title = "Settings"
        //  prepares links between bar and controllers
        let nav0 = UINavigationController(rootViewController: vc0)
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        //  set icons to bar
        nav0.tabBarItem = UITabBarItem(title: "Peawell", image: UIImage(systemName: "house"), tag: 0)
        nav1.tabBarItem = UITabBarItem(title: "Actions", image: UIImage(systemName: "list.bullet"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Reminders", image: UIImage(systemName: "bell"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)

        //  force large title
        nav0.navigationBar.prefersLargeTitles = true
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        //  actually adding controls to bar
        setViewControllers([nav0, nav1, nav2, nav3], animated: true)
        // Do any additional setup after loading the view.
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
