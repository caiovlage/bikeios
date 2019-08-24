//
//  ViewController.swift
//  bikeios
//
//  Created by caio victor lage on 23/08/19.
//  Copyright © 2019 caio victor lage. All rights reserved.

import UIKit
import GoogleMaps

class ViewController: UIViewController , CLLocationManagerDelegate{

    
    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    let urlToRequest = "https://gruposolarbrasil.com.br/json/localizacoes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
       mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        mapView.isMyLocationEnabled = true
        dataRequest()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.view = mapView
        locationManager.stopUpdatingLocation()
    }

    
    func dataRequest() {
        
        let url4 = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url4)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let task = session4.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
                print("*****error")
                return
            }
            do{
            let anyObj: AnyObject? = try JSONSerialization.jsonObject(with: data as! Data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as AnyObject
                self.parseJson(anyObj: anyObj!)
            }catch
            {
                
            }
        }
        task.resume()
    }
    
    func parseJson(anyObj:AnyObject){
        if  anyObj is Array<AnyObject> {
            
            for json in anyObj as! Array<AnyObject>
            {
                
                for json2 in json as! Array<AnyObject>
                {
                    DispatchQueue.main.async(execute: {
                        
                        print(Double((json2["latitude"] as AnyObject? as? String) ?? "0.0" ))
                        
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: Double( (json2["latitude"] as AnyObject? as? String) ?? "0.0" ) as! CLLocationDegrees, longitude: Double( (json2["latitude"] as AnyObject? as? String) ?? "0.0" ) as! CLLocationDegrees)
                        marker.map = self.mapView
                       
                    })
                    
                  //  marker.position = CLLocationCoordinate2D(latitude: Double( (json2["latitude"] as AnyObject? as? String) ?? "0.0" ) as! CLLocationDegrees , longitude: Double( (json2["longitude"] as AnyObject? as? String) ?? "0.0" ) as! CLLocationDegrees)

                    // let position = CLLocationCoordinate2D(latitude: 10, longitude: 10)
                    //let marker = GMSMarker(position: position)
                    //marker.title = "Hello World"
                    //marker.map = mapView
                    
                    //print(Double( (json2["latitude"] as AnyObject? as? String) ?? "0.0" ));
                }
                
             //   let marker = GMSMarker()
               // marker.position = CLLocationCoordinate2D(latitude: (json["latitude"] as? Double) ?? 0,longitude: json["longitude"] as? Double ?? 0)
                //marker.map = mapView
           // list.append(Localizacao( latitude: (json["latitude"] as AnyObject? as? Double) ?? 0,
           //                          longitude: json["longitude"] as AnyObject? as? Double ?? 0))
            }
        }
    }
    
    struct Localizacao:Decodable {
        var latitude = 0.0
        var longitude = 0.0
    }
}
