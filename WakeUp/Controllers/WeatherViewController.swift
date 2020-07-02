//
//  WeatherViewController.swift
//  WakeUp
//

import UIKit
import CoreLocation

private let reuseIdentifier = "weatherCell"

class WeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var apparentTemperatureLabel: UILabel!
    @IBOutlet weak var uvIndexLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
}

class WeatherViewController: UIViewController {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var apparentTemperatureLabel: UILabel!
    @IBOutlet weak var weatherSummaryLabel: UILabel!
    
    @IBOutlet weak var weatherTableView: UITableView!
    
    let weatherAPI = WeatherAPI()
    var weather = Weather()
    var temperature: Double?
    var apparentTemperature: Double?
    var weatherSummary: String?
    
    let locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    
    var city: String?
    var latitude: String?
    var longitude: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLM()
        
        //let image = UIImage(systemName: "cloud.sun.fill")
    }
    
    func setUpLM()  {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func fillWeather() {
        weatherAPI.fetchLocalWeather(latitude: latitude!, longitude: longitude!) { (data) in
            //let dataString = String(data: data, encoding: .utf8) ?? ""
            //print(dataString)
            
            if let weather = self.decodeWeather(from: data) {
                self.weather = weather
                self.temperature = weather.hourly!.data[0].temperature
                self.apparentTemperature = weather.hourly!.data[0].apparentTemperature
                self.weatherSummary = weather.hourly!.summary
            }
            
            DispatchQueue.main.async {
                self.temperatureLabel.text = String(self.temperature!) + "˚"
                self.apparentTemperatureLabel.text = String(self.apparentTemperature!) + "˚"
                self.weatherSummaryLabel.text = String(self.weatherSummary!)
                self.weatherTableView.reloadData()
            }
        }
    }
    
    func decodeWeather(from jsonData: Data) -> Weather?{
        var weather: Weather?
        let decoder = JSONDecoder()
        do {
            weather = try decoder.decode(Weather.self, from: jsonData)
        } catch {
            print(error)
            weather = nil
        }
        return weather
    }
    
    func setDate() {
        let now = Date()
        let formatter = DateFormatter()
        
        formatter.dateStyle = .full
        let date = formatter.string(from: now)
        dateLabel.text = date
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

extension WeatherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! WeatherTableViewCell
        
        if let hourlyWeather = weather.hourly {
            let hourWeather = hourlyWeather.data[indexPath.row]
            
            let hour = Date(timeIntervalSince1970: hourWeather.time!)
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let hourString = formatter.string(from: hour)
            cell.hourLabel.text = hourString
            
            cell.summaryLabel.text = hourWeather.summary
            cell.temperatureLabel.text = String(hourWeather.temperature!) + "˚"
            cell.apparentTemperatureLabel.text = String(hourWeather.apparentTemperature!) + "˚"
            cell.uvIndexLabel.text = String(hourWeather.uvIndex!)
            cell.humidityLabel.text = String(hourWeather.humidity!) + "%"
        }
        
        return cell
    }
}

extension WeatherViewController: UITableViewDelegate {}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        
        print("lat: \(latestLocation.coordinate.latitude) long: \(latestLocation.coordinate.longitude)")
        
        self.latitude = String(latestLocation.coordinate.latitude)
        self.longitude = String(latestLocation.coordinate.longitude)
        
        fillWeather()
        reverseGeocode(location: latestLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if error != nil { return }
            guard let placemarks = placemarks else {
                return
            }
            if let placemark = placemarks.first {
                let city = placemark.locality ?? ""
                self.city = city
            }
            self.locationLabel.text = self.city
            self.setDate()
        }
    }
    
}


