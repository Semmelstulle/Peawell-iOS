//
//  ViewController.swift
//  Peawell
//
//  Created by Dennis on 29.04.22.
//

import UIKit

class MainViewController: UIViewController {
    //logically add objects
    let nextButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //call setup function for button
        setUpUI()
        //Set up general page
        view.backgroundColor = UIColor.systemBackground
        title = "Peawell"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //initialises styloing of button
        func setUpUI() {
            //visually add button
            view.addSubview(nextButton)
            nextButton.configuration = .filled()
            nextButton.configuration?.baseBackgroundColor = .systemGreen
            nextButton.configuration?.baseForegroundColor = .systemGray5
            nextButton.configuration?.title = "Press me btch"
            nextButton.translatesAutoresizingMaskIntoConstraints = false
            //Declare layout in an array
            NSLayoutConstraint.activate([
                nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                nextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                nextButton.widthAnchor.constraint(equalToConstant: 200),
                nextButton.heightAnchor.constraint(equalToConstant: 50)
            ])
            
        }
        
        //Alert
        let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

