//
//  InitialViewController.swift
//  Find My Place
//
//  Created by Chetan on 2020-06-14.
//  Copyright © 2020 Chetan. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    

//    MARK: shows the about info
    @IBAction func showAboutInfo(_ sender: UIButton) {
        let alertMsg = UIAlertController(title: "Welcome!", message: "To Visit Place is your places tracking list app, where you can add places you wan to visit.\n\n1. Simply click 'Add Place' button to be taken to Map where you can add the place.(Tip: See Map info for details)\n\n2.See your place in the list on home screen, and tap on the place to be taken to the place on Map\n\n3.Remove the item by swiping right", preferredStyle: .alert)
        alertMsg.addAction(UIAlertAction(title: "Let's Go!", style: .default))
        self.present(alertMsg, animated: true)
    }
    

}
