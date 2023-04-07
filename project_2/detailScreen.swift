//
//  detailScreen.swift
//  project_2
//
//  Created by Sagar Gurung on 2023-04-06.
//

import UIKit
import CoreLocation

class detailScreen: UIViewController {
    var longitude: Double?
    var latitude: Double?
    var fullLocation: String?
    private var items: [tableItem] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lowTemp: UILabel!
    @IBOutlet weak var highTemp: UILabel!
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var temp_C: UILabel!
    @IBOutlet weak var location: UILabel!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(longitude!)
        print(latitude!)
        
        if let latitude = latitude, let longitude = longitude{
            fullLocation = "\(latitude),\(longitude)"
            loadWeather(search: fullLocation, days: 1)
        }
        
        loadTableItems()
        tableView.dataSource = self
        
        
    }
    
    private func loadWeather(search: String?, days: Int){
        guard let search = search else{
            return
        }
        //Get url
        guard let url = getURl(query: search, days: days) else{
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
            
            if let WeatherData = self.parseJson(data: data){
         
                for forecastDay in WeatherData.forecast.forecastday {
                    print (forecastDay.day.maxtemp_c)
                    print (forecastDay.day.mintemp_c)
                }
                
                
                DispatchQueue.main.async {
                    
                    self.location.text = "Location: \(WeatherData.location.name)"
                    self.weather.text = "Condition: \(WeatherData.current.condition.text)"
                    self.temp_C.text = "Temp :\(WeatherData.current.temp_c) C"
                    for forecastDay in WeatherData.forecast.forecastday {
                        self.highTemp.text = "High Temp: \(forecastDay.day.maxtemp_c) C"
                        self.lowTemp.text = "Min Temp: \(forecastDay.day.mintemp_c) C"
                    }
                    
                }
            }
            
        }
        //start the task
        dataTask.resume()
        
    }
    private func parseJson(data: Data)-> WeatherData?{
        let decoder = JSONDecoder()
        var weather: WeatherData?
        do{
            try weather = decoder.decode(WeatherData.self, from: data)
        }catch{
            print("Error decoding")
        }
        return weather
        
    }
    // Making URL
    private func getURl(query: String, days: Int)->URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let endPoint = "forecast.json"
        let apiKey = "60acdd71266c48b2a8a193311230704"
        guard let url = "\(baseUrl)\(endPoint)?key=\(apiKey)&q=\(query)&days=\(days)&aqi=no&alerts=no".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        return URL(string: url)
    }
    
    private func loadTableItems(){
        
        //Get url
        guard let url = getURl(query: fullLocation!, days: 7) else{
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
            
            if let WeatherData = self.parseJson(data: data){
         
                for forecastDay in WeatherData.forecast.forecastday {
                    print (forecastDay.day.maxtemp_c)
                  
                   
                }
                
                DispatchQueue.main.async {
                    for forecastDay in WeatherData.forecast.forecastday{
                        self.items.append(tableItem(day: forecastDay.date, temperature: forecastDay.day.avgtemp_c, icon: UIImage(systemName: "\(self.weatherImage(code: forecastDay.day.condition.code))")))
                        self.tableView.reloadData()

                    }
                    
                }
            }
            
        }
        //start the task
        dataTask.resume()
        
       

    }
    
    //Function to load the icon string according to the weather code
    private func weatherImage(code: Int)-> String{
        
        var image = ""
        switch code{
        case 1000 :  image = "sun.max"
        case 1006, 1003 :   image = "cloud.fill"
        case 1009 : image = "cloud"
        case 1030, 1135, 1147 : image = "cloud.fog.fill"
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201,1240,1243, 1246, 1249 : image = "cloud.rain.fill"
            
        case 1087 : image = "cloud.bolt.rain"
        case 1114, 1210,1213,1216,1219,1222,1225,1255,1258,1279,1282 : image = "cloud.snow.fill"
        default : image = "cloud.sun.bolt.fill"
        }
        return image
    }
    
    
    
    
}

extension detailScreen: UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        let item = items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.day
        content.secondaryText = "\(item.temperature)"
        content.image = item.icon
        cell.contentConfiguration = content
        return cell
    }
    
    
}

struct tableItem{
    let day: String
    let temperature: Float
    let icon: UIImage?
}

struct WeatherData: Decodable {
    let location: Location
    let current: Weather
    let forecast: Forecast
}

struct Forecast: Decodable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let day: Day
}

struct Day: Decodable {
    let maxtemp_c: Float
    let mintemp_c: Float
    let avgtemp_c: Float
    let condition: WeatherCondition
}
struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location: Decodable {
    let name: String
    let lat: Double
    let lon: Double
}

struct Weather: Decodable {
    let temp_c: Float
    let feelslike_c: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

