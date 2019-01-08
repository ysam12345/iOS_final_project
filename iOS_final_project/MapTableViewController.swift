//
//  MapTableViewController.swift
//  iOS_final_project
//
//  Created by yochien on 2019/1/4.
//  Copyright © 2019 yochien. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapTableViewController: UITableViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latlonLabel: UILabel!
    @IBOutlet weak var radiusSegmented: UISegmentedControl!
    @IBOutlet weak var contentInput: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    
    var lat: Double = 0
    var lon: Double = 0
    
    var userData : UserData?
    var notificationListData : NotificationListData?
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        contentInput.delegate = self
        
        
        if let data = UserData.read() {
            userData = data
            
        } else {
            //no user data
            //logout user
            
        }
        
        locationManager = CLLocationManager()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // 2. 用戶不同意
        else if CLLocationManager.authorizationStatus() == .denied {
            DispatchQueue.main.async(){
                let alertController = UIAlertController(title: "定位權限已關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }//DispatchQueue
        }
            // 3. 用戶已經同意
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapTableViewController.mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.0 // in seconds
        mapView.addGestureRecognizer(longPress)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.loadNotificationList()
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let radiusArray = [10, 100, 500, 1000, 10000]
        print("AddButton has been pressed.")
        if(latlonLabel.text=="latlon") {
            DispatchQueue.main.async(){
                let alertController = UIAlertController(title: "未選擇座標", message: "請長按選取座標", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }//DispatchQueue
        } else if (contentInput.text=="") {
            DispatchQueue.main.async(){
                let alertController = UIAlertController(title: "未填寫通知內容", message: "請填入通知內容", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }//DispatchQueue
        } else {
            struct Data: Codable {
                var lat: Float64
                var lon: Float64
                var radius: Int
                var content: String
            }
            
  
            let data = Data(lat: lat, lon: lon, radius: radiusArray[radiusSegmented.selectedSegmentIndex], content: contentInput.text!)
            
            do {
                let jsonData = try JSONEncoder().encode(data)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                let urlString = "http://140.121.197.197:3000/addNotification?facebook_token="+self.userData!.facebookAccessToken+"&notification_data="+jsonString
                print(urlString)
                let urlWithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                let url = URL(string: urlWithPercentEscapes!)!
                
                let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    if let data = data, let results = try?
                        decoder.decode(ResponseCode.self, from: data)
                    {
                        print(results)
                        if(results.code == "200"){
                            DispatchQueue.main.async(){
                                let alertController = UIAlertController(title: "成功", message: "增加通知成功", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                                self.loadNotificationList()
                                
                            }//DispatchQueue
                        } else {
                            DispatchQueue.main.async(){
                                let alertController = UIAlertController(title: "失敗", message: "發生錯誤", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }//DispatchQueue
                        }

                    } else {
                        print("error")
                    }
                }
                
                task.resume()
            } catch {
                //handle error
                print(error)
            }
            
            
        }
        

    }
    
    func loadNotificationList() {
        let url = URL(string: "http://140.121.197.197:3000/getUserNotificationList?facebook_token="+userData!.facebookAccessToken)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let data = data, let results = try?
                decoder.decode(NotificationListData.self, from: data)
            {
                print("json load success")
                print(results)
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.removeOverlays(self.mapView.overlays)
                self.notificationListData = results
                for var i in results.data {
                    self.addPointAndCircleToMapView(lat: i.data.lat, lon: i.data.lon, radius: i.data.radius, content: i.data.content)
                }
            } else {
                print("error")
            }
        }
        
        task.resume()
    }
    
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        
        
        if(recognizer.state == UIGestureRecognizerState.began) {
            print("A long press has began.")
            self.loadNotificationList()
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
    
    func addPointAndCircleToMapView( lat: Double, lon: Double, radius: Int, content: String) {
        let newPin = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: lat,longitude: lon)
        newPin.coordinate = coordinate
        newPin.title = content
        let circle = MKCircle(center: coordinate, radius: CLLocationDistance(radius))
        mapView.add(circle)
        mapView.addAnnotation(newPin)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKCircle else { return MKOverlayRenderer() }
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.red
        circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
        circle.lineWidth = 1
        return circle
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
