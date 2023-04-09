//
//  AddLocation.swift
//  project_2
//
//  Created by Sagar Gurung on 2023-04-07.
//

import UIKit

protocol AddDataDelegate: AnyObject {
    func addData( locationName: String, temperature: Float,lat: Double ,lon:Double, icon: UIImage?)
}

class AddLocation: UIViewController {

    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    weak var delegate: AddDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weatherImageView.image = UIImage(systemName: "cloud.sun.bolt.fill")
        temperature.text = "10 C"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchBtnTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
        
    }
    
    
    @IBAction func saveBtnTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
       
    }
    @IBAction func cancelBtnTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
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
             
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print (weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    self.location.text = weatherResponse.location.name
                    self.condition.text = weatherResponse.current.condition.text
                    self.temperature.text = "\(weatherResponse.current.temp_c) C"
                    self.displayImage(code: weatherResponse.current.condition.code)
                    
                    //Call Function to send data to main page
                    
                    self.delegate?.addData(locationName: weatherResponse.location.name,
                                      temperature: Float(weatherResponse.current.temp_c),
                                           lat: Double(weatherResponse.location.lat),
                                           lon: Double(weatherResponse.location.lon),
                                      icon: self.getImageName(code: weatherResponse.current.condition.code))

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
    
    private func getURl(query: String)->URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let endPoint = "current.json"
        let apiKey = "03b553e6eb96411a8ef21900231603"
        guard let url = "\(baseUrl)\(endPoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        return URL(string: url)
    }
    private func getImageName (code: Int)-> UIImage?{
        switch code {
        case 1000 : return UIImage(systemName: "sun.max")
        case 1006, 1003 : return UIImage(systemName: "cloud.fill")
        case 1009 : return UIImage(systemName: "cloud")
        case 1030, 1135, 1147 : return UIImage(systemName: "cloud.fog.fill")
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201,1240,1243, 1246, 1249 : return UIImage(systemName: "cloud.rain.fill")
        
        case 1087 : return UIImage(systemName: "cloud.bolt.rain")
        case 1114, 1210,1213,1216,1219,1222,1225,1255,1258,1279,1282 : return UIImage(systemName: "cloud.snow.fill")
        default : return UIImage(systemName: "cloud.sun.bolt.fill")
        }
    }
    
    private func displayImage(code: Int){
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemOrange, .systemGray, .systemTeal])
        weatherImageView.preferredSymbolConfiguration = config
        switch code{
        case 1000 :weatherImageView.image = UIImage(systemName: "sun.max")
        case 1006, 1003 : weatherImageView.image = UIImage(systemName: "cloud.fill")
        case 1009 : weatherImageView.image = UIImage(systemName: "cloud")
        case 1030, 1135, 1147 : weatherImageView.image = UIImage(systemName: "cloud.fog.fill")
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201,1240,1243, 1246, 1249 :weatherImageView.image = UIImage(systemName: "cloud.rain.fill")
        
        case 1087 :weatherImageView.image = UIImage(systemName: "cloud.bolt.rain")
        case 1114, 1210,1213,1216,1219,1222,1225,1255,1258,1279,1282 :weatherImageView.image = UIImage(systemName: "cloud.snow.fill")
        default : weatherImageView.image = UIImage(systemName: "cloud.sun.bolt.fill")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


