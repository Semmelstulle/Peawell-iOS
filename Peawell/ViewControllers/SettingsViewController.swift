//
//  SettingsViewController.swift
//  Peawell
//
//  Created by Dennis on 29.04.22.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up general page
        view.backgroundColor = UIColor.systemBackground
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
}
