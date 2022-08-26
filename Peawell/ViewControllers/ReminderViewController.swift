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
        
        
        //@IBOutlet var reminderCollection: UICollectionView!
        
        
        //  setting up top navigation and background
        view.backgroundColor = UIColor.systemBackground
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        
        
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

class UICollectionView : UIScrollView {
    
}
