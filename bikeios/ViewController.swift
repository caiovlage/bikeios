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
    var bounds = GMSCoordinateBounds()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.6
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
        
        self.navigationController?.navigationBar.setBottomBorderColor(color: UIColor.white , height:3)
        

    }

    override func loadView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
       mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
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
                                              longitude: userLocation!.coordinate.longitude, zoom: 16)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        self.view = mapView
        locationManager.stopUpdatingLocation()
        
        self.view.addSubview(progress)
        mapView.setMinZoom(10.0, maxZoom: 30.0)
        //mapView.settings.myLocationButton = true
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.addControls()
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
            
             DispatchQueue.main.async(execute: {
                
                self.bounds = self.bounds.includingCoordinate(self.startPosition)
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
                                marker.icon = self.resizeImage(image: UIImage(named: "marker")!, targetSize: CGSize(width:42.0, height:48.0) )
                                marker.map = self.mapView
                                self.bounds = self.bounds.includingCoordinate(marker.position)
                            }
                        }
                    }
                }
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
                self.progress.hide()
                self.addControls()
            })
        }
    }
    
    func addControls()
    {
        let image = UIImage(named: "h") as UIImage?
        let button = UIButton(frame: CGRect(x: self.view.frame.maxX - 70, y: self.view.frame.maxY - 70, width: 70, height: 62))
        button.setImage(image, for: .normal)
        button.setTitle("Button", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.tag = 5
        button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.mapView.addSubview(button)
        
        
        let imageBike = UIImage(named: "bike") as UIImage?
        let buttonBike = UIButton(frame: CGRect(x: -1, y: self.view.frame.maxY - 70, width: 70, height: 61))
        buttonBike.setImage(imageBike, for: .normal)
        buttonBike.setTitle("Button", for: .normal)
        buttonBike.setTitleColor(.red, for: .normal)
        buttonBike.tag = 4
        buttonBike.addTarget(self, action: #selector(self.zoomAll), for: .touchUpInside)
        self.mapView.addSubview(buttonBike)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let help = storyboard?.instantiateViewController(withIdentifier: "HelpController") as! HelpController
        help.telefone = self.telefone
        navigationController?.pushViewController(help, animated: true)
    }
    
    @objc func zoomAll(sender: UIButton!) {
        self.clickShowAllLoications()
    }
    
    func clickShowAllLoications()
    {
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
        self.mapView.animate(with: update)
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
extension UINavigationBar {
    
    func setBottomBorderColor(color: UIColor, height: CGFloat) -> UIView {
        let bottomBorderView = UIView(frame: CGRect())
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderView.backgroundColor = color
        
        self.addSubview(bottomBorderView)
        
        let views = ["border": bottomBorderView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[border]|", options: [], metrics: nil, views: views))
        self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
        self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: height))
        
        return bottomBorderView
    }
}
