//
//  NewsAPI.swift
//  WakeUp
//

import Foundation

class NewsAPI {
    private let key = "440616d6bb7b4bb29831118151d52f1c"
    let basePath = "https://newsapi.org/v2/top-headlines/"
    
    func fetchTopHeadlines(in countryCode: String, newsCategory: String, completionHandler: @escaping (Data) -> ()) {
        guard let topHeadlinesURL = URL(string: "\(basePath)/?country=\(countryCode)&category=\(newsCategory)&apiKey=\(key)") else {
            return
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: topHeadlinesURL) { (data, response, error) in
            guard let data = data, error == nil else { return }
            completionHandler(data)
        }
        task.resume()
    }
}
