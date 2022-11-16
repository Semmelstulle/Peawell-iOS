//
//  ActionsViewController.swift
//  Peawell
//
//  Created by Dennis on 29.04.22.
//

import UIKit

class ActionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up general page
        view.backgroundColor = UIColor.systemBackground
        title = "Actions"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }

}
