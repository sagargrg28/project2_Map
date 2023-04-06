//
//  ViewController.swift
//  project_2
//
//  Created by Sagar Gurung on 2023-04-05.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    var fullLocation: String?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
   // private let locationManagerDelegate = MyLocationManagerDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        
       
        //Requesting current location
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got the current Location")
        if let location = locations.last {
             latitude = location.coordinate.latitude
             longitude = location.coordinate.longitude
            
            fullLocation = "\(String(describing: latitude)),\(String(describing: longitude))"
            if let fullLocation = fullLocation {
                print(fullLocation)
            }
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            setupMap()
//            addAnnotation(location: location)
            loadWeather(search: fullLocation)


            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    //Getting weather from api
    private func loadWeather(search: String?){
        guard let search = search else{
            return
        }
        //Get url
        guard let url = getURl(query: search) else{
            print("URL not found ")
            return
        }
        //create url session
        let urlSession = URLSession.shared
        //creating task for session
        let dataTask = urlSession.dataTask(with: url) { data, response, error in
            
            guard  error == nil else {
                print("Error received ")
                return
            }
            
            guard let data = data else {
                print ("Data not received ")
                return
            }
             
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print (weatherResponse.current.temp_c)
                print (weatherResponse.current.temp_f)
                
                DispatchQueue.main.async {
                    self.addAnnotation(location: CLLocation(latitude: self.latitude, longitude: self.longitude), title: "\(weatherResponse.current.temp_c)C ")
//                    self.location.text = weatherResponse.location.name
//                    self.condition.text = weatherResponse.current.condition.text
//                    self.temperature.text = "\(weatherResponse.current.temp_c) C"
//                    self.celcious = "\(weatherResponse.current.temp_c) C"
//                    self.ferenhight = "\(weatherResponse.current.temp_f)F"
//                    self.displayImage(code: weatherResponse.current.condition.code)
//
              }
            }
            
        }
        //start the task
        dataTask.resume()
        
    }
    
    private func parseJson(data: Data)-> weatherRespose?{
        let decoder = JSONDecoder()
        var weather:weatherRespose?
        do{
            try weather = decoder.decode(weatherRespose.self, from: data)
        }catch{
            print("Error decoding")
        }
        return weather

    }
    // Making URL
    private func getURl(query: String)->URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let endPoint = "current.json"
        let apiKey = "03b553e6eb96411a8ef21900231603"
        guard let url = "\(baseUrl)\(endPoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        return URL(string: url)
    }
    
    
    private func addAnnotation(location: CLLocation, title: String){
        let annotation = Myannotation(cordinate: location.coordinate, title: title, subTitle: "My subtitle" )
        
        mapView.addAnnotation(annotation)
        
    }
    
    private func setupMap(){
        //set the delecate
        mapView.delegate = self
        

        let location = CLLocation(latitude: latitude, longitude: longitude)
        let radiusInMeter: CLLocationDistance = 1000

        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: radiusInMeter,
                                        longitudinalMeters: radiusInMeter)


        mapView.setRegion(region, animated: true)

        //camera boundries
        let cameraBoundries = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundries, animated: true)

        //Camera Zoom Range
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true)

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "whatIsthis "
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        
        //set the position for callout
        view.calloutOffset = CGPoint(x: 0, y: 10)
        
        //add a button to the right hand side
        let button = UIButton(type: .detailDisclosure)
        view.rightCalloutAccessoryView = button
        
        //add and image
        let image = UIImage(systemName: "sun.and.horizon.circle.fill")
        view.leftCalloutAccessoryView = UIImageView(image: image)
        
        //change the color of the marker
        view.markerTintColor = UIColor.purple
        
        //change the color of accessories
        view.tintColor = UIColor.red
        
        return view
        
    }

}

struct weatherRespose: Decodable {
    let location : location
    let current : current
}

struct location: Decodable{
    let name: String
}

struct current: Decodable{
    let temp_c : Double
    let temp_f : Double
    let condition : weatherCondition
}

struct weatherCondition: Decodable{
    let text: String
    let code: Int
}



class Myannotation:NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    
    init(cordinate: CLLocationCoordinate2D, title: String, subTitle: String) {
        self.coordinate = cordinate
        self.title = title
        self.subtitle = subTitle
        super.init()
    }
    
}



