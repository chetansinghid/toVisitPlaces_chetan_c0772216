//
//  InitialViewController.swift
//  Find My Place
//
//  Created by Chetan on 2020-06-14.
//  Copyright © 2020 Chetan. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    reference to table
    @IBOutlet weak var tableView: UITableView!
//    variables to store data for places
    var data = MyPlaceItem.getPlace()
//    var to store index to pass to next view controller on tap
    var indexForCell: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
    }
    
    
    
//    MARK: updates the table view on loading page again
    override func viewWillAppear(_ animated: Bool) {
        data = MyPlaceItem.getPlace()
        self.tableView.reloadData()
    }
    
    
    
//    MARK: does inital table view setup
    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
//        setup for auto size of cell
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    
//    MARK: table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell!.textLabel?.text = data?[indexPath.row].name
        cell!.textLabel?.numberOfLines = 0
        return cell!
    }
    
    
    
    
//    MARK: tap selection logic for table cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexForCell = indexPath.row
        performSegue(withIdentifier: "showLocation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLocation" {
            if let destinationView = segue.destination as? ViewController {
                destinationView.isTapped = true
                destinationView.row = indexForCell
            }
        }
    }
    
    
    
    
//    MARK: table delete item method
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            MyPlaceItem.removePlace(index: indexPath.row)
            self.data = MyPlaceItem.getPlace()
            self.tableView.reloadData()
        }
        deleteItem.backgroundColor =  #colorLiteral(red: 0.660077189, green: 0.9588123381, blue: 0.8589506137, alpha: 1)
    //    deleteItem.image = UIImage(named: "delete")
        return UISwipeActionsConfiguration(actions: [deleteItem])
    }

    
    
    
//    MARK: shows the about info
    @IBAction func showAboutInfo(_ sender: UIButton) {
        let alertMsg = UIAlertController(title: "Welcome!", message: "To Visit Place is your places tracking list app, where you can add places you wan to visit.\n\n1. Simply click 'Add Place' button to be taken to Map where you can add the place.(Tip: See Map info for details)\n\n2.See your place in the list on home screen, and tap on the place to be taken to the place on Map\n\n3.Remove the item by swiping", preferredStyle: .alert)
        alertMsg.addAction(UIAlertAction(title: "Let's Go!", style: .default))
        self.present(alertMsg, animated: true)
    }

}

