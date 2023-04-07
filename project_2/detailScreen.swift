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
            let fullLocation = "\(latitude),\(longitude)"
            loadWeather(search: fullLocation)
        }
        
    }
    
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
            
            if let WeatherData = self.parseJson(data: data){
                
                print(WeatherData.current.condition.text)
                print(WeatherData.location.name)
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
    private func getURl(query: String)->URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let endPoint = "forecast.json"
        let apiKey = "03b553e6eb96411a8ef21900231603"
        guard let url = "\(baseUrl)\(endPoint)?key=\(apiKey)&q=\(query)&days=1&aqi=no&alerts=no".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        return URL(string: url)
    }
    
    
    
    
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

