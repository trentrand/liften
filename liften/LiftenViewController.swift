//
//  LiftinViewController.swift
//  liften
//
//  Created by Trent Rand on 3/30/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import Foundation

class LiftenViewController: UIViewController {
    
    @IBOutlet var searchDestination: UISearchBar!
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        searchDestination.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}