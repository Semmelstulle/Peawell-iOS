//
//  ViewController.swift
//  Peawell
//
//  Created by Dennis on 29.04.22.
//

import UIKit

class MainViewController: UIViewController {

    var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = UINavigationController()
        navBar.title = "Peawell 2"
        navBar.navigationBar.prefersLargeTitles = true

        view.backgroundColor = UIColor.systemBackground
        label = UILabel(frame: CGRect(x: 10, y: 150, width: 300, height: 50))
        label.text = "This is Peawell. Add your medication below.";
        view.addSubview(label)
        
        label = UILabel(frame: CGRect(x: 10, y: 500, width: 300, height: 50))
        label.text = "Hola amigo";
        view.addSubview(label)
        
    }


}

