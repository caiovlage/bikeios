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
        //mapView.setMinZoom(10.0, maxZoom: 30.0)
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
                                marker.icon = UIImage(named: "marker")
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
                
            })
        }
    }
    
    func addControls()
    {
        let image = UIImage(named: "h") as UIImage?
        let button = UIButton(frame: CGRect(x: self.view.frame.maxX, y: self.view.frame.maxY - 70, width: 66, height: 55))
        button.setImage(image, for: .normal)
        button.setTitle("Button", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.tag = 5
        button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.mapView.addSubview(button)
        
        
        let imageBike = UIImage(named: "bike") as UIImage?
        let buttonBike = UIButton(frame: CGRect(x: -66, y: self.view.frame.maxY - 70, width: 66, height: 55))
        buttonBike.setImage(imageBike, for: .normal)
        buttonBike.setTitle("Button", for: .normal)
        buttonBike.setTitleColor(.red, for: .normal)
        buttonBike.tag = 4
        buttonBike.addTarget(self, action: #selector(self.zoomAll), for: .touchUpInside)
        self.mapView.addSubview(buttonBike)
        
        let imagePoint = UIImage(named: "center") as UIImage?
        let buttonPoint = UIButton(frame: CGRect(x: 8, y: (self.navigationController?.navigationBar.frame.maxY)! + 10, width: 37, height: 37))
        buttonPoint.setImage(imagePoint, for: .normal)
        buttonPoint.setTitle("Button", for: .normal)
        buttonPoint.setTitleColor(.red, for: .normal)
        buttonPoint.tag = 4
        buttonPoint.addTarget(self, action: #selector(self.center), for: .touchUpInside)
        self.mapView.addSubview(buttonPoint)
        
        UIView.animate(withDuration: 0.4,delay: 1.5, animations:{
            buttonBike.frame.origin.x += 66
            button.frame.origin.x -= 66
        })
        
        self.drawPermitedArea()
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let help = storyboard?.instantiateViewController(withIdentifier: "HelpController") as! HelpController
        help.telefone = self.telefone
        navigationController?.pushViewController(help, animated: true)
    }
    
    @objc func zoomAll(sender: UIButton!) {
        self.clickShowAllLoications()
    }
    
    @objc func center(sender: UIButton!) {
        self.mapView.animate(toLocation: self.mapView.myLocation!.coordinate)
        self.mapView.animate(toZoom: 16)
    }
    
    
    func clickShowAllLoications()
    {
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
        self.mapView.animate(with: update)
    }
    
    func drawPermitedArea()
    {
        let path = GMSMutablePath()
        
        
        path.add(CLLocationCoordinate2D(latitude: -43.4688594, longitude: -23.0292315))
        path.add(CLLocationCoordinate2D(latitude: -43.4652009,longitude: -23.0273653))
        path.add(CLLocationCoordinate2D(latitude: -43.4647610,longitude: -23.0283428))
        path.add(CLLocationCoordinate2D(latitude: -43.4683659,longitude: -23.0299621))
       /* path.add(CLLocationCoordinate2D(latitude: -43.4550198,longitude: -23.0239924))
        path.add(CLLocationCoordinate2D(latitude: -43.4529169,longitude: -23.0233604))
        path.add(CLLocationCoordinate2D(latitude: -43.4502562,longitude: -23.0224915))
        path.add(CLLocationCoordinate2D(latitude: -43.4477671,longitude: -23.0218990))
        path.add(CLLocationCoordinate2D(latitude: -43.4439905,longitude: -23.0213461))
        path.add(CLLocationCoordinate2D(latitude: -43.4405573,longitude: -23.0205956))
        path.add(CLLocationCoordinate2D(latitude: -43.4402569,longitude: -23.0213461))
        path.add(CLLocationCoordinate2D(latitude: -43.4412869,longitude: -23.0217411))
        path.add(CLLocationCoordinate2D(latitude: -43.4436043,longitude: -23.0221755))
        path.add(CLLocationCoordinate2D(latitude: -43.4468229,longitude: -23.0232025))
        path.add(CLLocationCoordinate2D(latitude: -43.4494408, longitude:-23.0237159))
        path.add(CLLocationCoordinate2D(latitude: -43.4514578,longitude: -23.0241109))
        path.add(CLLocationCoordinate2D(latitude: -43.4534319,longitude: -23.0247428))
        path.add(CLLocationCoordinate2D(latitude: -43.4558352,longitude: -23.0254143))
        path.add(CLLocationCoordinate2D(latitude: -43.4582813,longitude: -23.0264412))
        path.add(CLLocationCoordinate2D(latitude: -43.4602555,longitude: -23.0271521))
        path.add(CLLocationCoordinate2D(latitude: -43.4622725,longitude: -23.0276655))
        path.add(CLLocationCoordinate2D(latitude: -43.4644612,longitude: -23.0284949))
        path.add(CLLocationCoordinate2D(latitude: -43.4665640,longitude: -23.0294033))
        path.add(CLLocationCoordinate2D(latitude: -43.4679373, longitude:-23.0301537))
        path.add(CLLocationCoordinate2D(latitude: -43.4688814, longitude:-23.0300748))
        path.add(CLLocationCoordinate2D(latitude: -43.4689238,longitude: -23.0297054))
        path.add(CLLocationCoordinate2D(latitude: -43.4688487, longitude:-23.0292117))
        path.add(CLLocationCoordinate2D(latitude: -43.4684088, longitude:-23.0287674))*/
        
        let polygon = GMSPolygon(path: path)
        polygon.strokeColor = .green
        polygon.fillColor = UIColor(red: 1.0, green: 187.0, blue: 39.0, alpha: 0.05);
        polygon.strokeWidth = 1.0
        polygon.map = self.mapView
        
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
