//
//  WeatherAPI.swift
//  WakeUp
//

import Foundation

class WeatherAPI {
    let basePath = "https://dark-sky.p.rapidapi.com/"
    let optionsURL = "?lang=en&units=auto"
    let headers = [
        "x-rapidapi-host": "dark-sky.p.rapidapi.com",
        "x-rapidapi-key": "d3357fd7c0msha3a17e47fc32c8ap10fe78jsna18dbcec6b8f"
    ]
    
    func fetchLocalWeather(latitude: String, longitude: String, completionHandler: @escaping (Data) -> ()) {
        guard let weatherURL = NSURL(string: "\(basePath)\(latitude),\(longitude)\(optionsURL)") else { return }
    
        let request = NSMutableURLRequest(url: weatherURL as URL,
                                            cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
    
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard let data = data, error == nil else { return }
            completionHandler(data)
        })

        dataTask.resume()
    }
}
