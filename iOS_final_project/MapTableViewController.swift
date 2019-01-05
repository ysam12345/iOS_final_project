//
//  MapTableViewController.swift
//  iOS_final_project
//
//  Created by yochien on 2019/1/4.
//  Copyright © 2019 yochien. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewController: UITableViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latlonLabel: UILabel!
    @IBOutlet weak var radiusSegmented: UISegmentedControl!
    @IBOutlet weak var timeInput: UIDatePicker!
    @IBOutlet weak var addButton: UIButton!
    
    var lat: Double = 0
    var lon: Double = 0
    
    var userData : UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapTableViewController.mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.0 // in seconds
        mapView.addGestureRecognizer(longPress)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("AddButton has been pressed.")
        print(lat,lon)
        print(radiusSegmented.selectedSegmentIndex)
        print(timeInput)
    }
    
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        
        
        if(recognizer.state == UIGestureRecognizerState.began) {
            print("A long press has began.")
            mapView.removeAnnotations(mapView.annotations)
            let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
            let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
            
            let newPin = MKPointAnnotation()
            newPin.coordinate = touchedAtCoordinate
            latlonLabel.text = String(format: "%.4f",touchedAtCoordinate.latitude) + String(format: ",%.4f",touchedAtCoordinate.longitude)
            lat = touchedAtCoordinate.latitude
            lon = touchedAtCoordinate.longitude
            mapView.addAnnotation(newPin)
        }
        
        print("A long press has been detected.")

    }
    
    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
