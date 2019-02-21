//
//  WebAPIViewController.swift
//  HelloAPIs
//
//  Created by Yuuki Nishiyama on 2019/02/19.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import MapKit

class WebAPIViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var latitudeTextView: UITextField!
    @IBOutlet weak var longitudeTextView: UITextField!
    
    /*
     * You can get the ID from the web-page of OpenWeatherMap
     * https://openweathermap.org/
     */
    let appId = "YOUR_APP_ID_HERE"
    
    var centerAnnotation = MKPointAnnotation.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        mapView.addAnnotation(self.centerAnnotation)
    }

    @IBAction func didPushButton(_ sender: UIButton) {
        /**
         * https://openweathermap.org/appid
         * https://openweathermap.org/api
         */
        // let center = self.mapView.centerCoordinate
        
        let latitude = Double(self.latitudeTextView.text ?? "0") ?? 0
        let longitude = Double(self.longitudeTextView.text ?? "0") ?? 0
        
        // [example] https://api.openweathermap.org/data/2.5/weather?lat=123&lon=64&units=metric&APPID=xxxxxx
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(Int(latitude))&lon=\(Int(longitude))&units=metric&APPID=\(appId)") {
            var request: URLRequest = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // get a shared session
            let session: URLSession = URLSession.shared
            // generate a session task with a completion handler
            let task = session.dataTask(with: request) { (data, response, error) in
                // completion events
                if let jsonData = data { // optional-binding
                    do {
                        // convert data to JSON object (Any) with do-catch (error handling)
                        let json = try JSONSerialization.jsonObject(with: jsonData,
                                                                    options: .allowFragments)
                        // cast and optional-binding (Any to Dictionary<String,Any>)
                        if let dict = json as? Dictionary<String, Any>{
                            
                            print(dict) // show result
                            
                            DispatchQueue.main.async {
                                // make a new annotation
                                let annotation = MKPointAnnotation()
                                // set center of the annotation. The values is same as the position of map center.
                                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                                
                                // get the country name from the result
                                if let sys = dict["sys"] as? Dictionary<String,Any> {
                                    if let country = sys["country"] as? String {
                                        annotation.title = country
                                    }
                                }
                                // get the main weather information from the result
                                if let main = dict["main"] as? Dictionary<String,Any>{
                                    annotation.subtitle = main.description
                                    // make an alert controller
                                    let alert = UIAlertController(title: "Weather Information in \(annotation.title ?? "Unknown")",
                                        message: main.description,
                                        preferredStyle: .alert)
                                    // make an action
                                    let action = UIAlertAction.init(title: "close", style: .default, handler: nil)
                                    // add an alert action
                                    alert.addAction(action)
                                    self.present(alert, animated: true, completion: nil)
                                    // print(Thread.isMainThread ? "In Main-thread":"In NOT Main-thread")
                                }
                                // add annotation
                                self.mapView.addAnnotation(annotation)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            // send the session task using `.resume()` method
            task.resume()
        }
        
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // https://developer.apple.com/documentation/mapkit/mapkit_annotations/annotating_a_map_with_custom_data
        // update the location of center annotation
        self.centerAnnotation.coordinate = mapView.centerCoordinate
        // update the latitude and longitude on TextViews
        self.latitudeTextView.text  = "\(mapView.centerCoordinate.latitude)"
        self.longitudeTextView.text = "\(mapView.centerCoordinate.longitude)"
    }
}

