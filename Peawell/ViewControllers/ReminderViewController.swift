//
//  ReminderViewController.swift
//  Peawell
//
//  Created by Dennis on 30.04.22.
//

import UIKit

class ReminderViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up general page
        view.backgroundColor = UIColor.systemBackground
        title = "Reminders"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
}

class UICollectionView : UIScrollView {
    
}
