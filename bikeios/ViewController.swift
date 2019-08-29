//
//  ViewController.swift
//  bikeios
//
//  Created by caio victor lage on 23/08/19.
//  Copyright © 2019 caio victor lage. All rights reserved.

import UIKit
import GoogleMaps

class ViewController: UIViewController , CLLocationManagerDelegate{

    let progress = Progress(text: "Carregando...")
    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    let urlLocalizacoes = "https://gruposolarbrasil.com.br/json/localizacoes"
    let urlTelefone = "https://gruposolarbrasil.com.br/json/telefone"
    var startPosition = CLLocationCoordinate2D()
    var telefone = ""
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

    }

    override func loadView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
       mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        mapView.isMyLocationEnabled = true
        
        dataRequestLocalizacoes(url: urlLocalizacoes)
        dataRequestTelefone(url: urlTelefone)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        startPosition = center
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 17)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.view = mapView
        locationManager.stopUpdatingLocation()
        
        self.view.addSubview(progress)
        
    }
    
    func dataRequestLocalizacoes(url:String) {
        
        let url4 = URL(string: url)!
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
                self.parseJsonLocalizacoes(anyObj: anyObj!)
            }catch
            {
            }
        }
        task.resume()
    }
    
    func parseJsonLocalizacoes(anyObj:AnyObject){
        if  anyObj is Array<AnyObject> {
            
            var bounds = GMSCoordinateBounds()
             DispatchQueue.main.async(execute: {
                
                bounds = bounds.includingCoordinate(self.startPosition)
                for json in anyObj as! Array<AnyObject>
                {
                    for json2 in json as! Array<AnyObject>
                    {
                        if let latitude = (json2["latitude"] as? NSString)?.doubleValue
                        {
                            if let longitude = (json2["longitude"] as? NSString)?.doubleValue
                            {
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2D(latitude:latitude , longitude:longitude)
                                marker.icon = UIImage(named: "marker")
                                marker.map = self.mapView
                                bounds = bounds.includingCoordinate(marker.position)
                            }
                        }
                    }
                }
                let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
                self.mapView.animate(with: update)
            })
        }
    }
    
    func dataRequestTelefone(url:String) {
        
        let url4 = URL(string: url)!
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
                self.parseJsonTelefone(anyObj: anyObj!)
            }catch
            {
            }
        }
        task.resume()
    }
    
    func parseJsonTelefone(anyObj:AnyObject)
    {
        if  anyObj is Array<AnyObject>
        {
            DispatchQueue.main.async(execute:
            {
                for json in anyObj as! Array<AnyObject>
                {
                        if let number = (json["number"] as? String)
                        {
                           self.telefone = number
                        }
                }
                let image = UIImage(named: "h") as UIImage?
                let button = UIButton(frame: CGRect(x: self.view.frame.maxX - 55, y: self.view.frame.maxY - 66, width: 60, height: 60))
                button.setImage(image, for: .normal)
                button.setTitle("Button", for: .normal)
                button.setTitleColor(.red, for: .normal)
                button.tag = 5
                button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                self.mapView.addSubview(button)
                self.progress.hide()
            })
        }
    }
    @objc func buttonAction(sender: UIButton!) {
        let help = storyboard?.instantiateViewController(withIdentifier: "HelpController") as! HelpController
        help.telefone = self.telefone
        navigationController?.pushViewController(help, animated: true)
    }
}
