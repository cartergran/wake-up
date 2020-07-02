//
//  Hour.swift
//  WakeUp
//
//  Created by Carter Gran on 5/12/20.
//  Copyright © 2020 Carter Gran. All rights reserved.
//

import Foundation

struct Hour {
    let time: Double?
    let summary: String?
    let temperature: Double?
    let apparentTemperature: Double?
    let humidity: Double?
    let uvIndex: Int?
}

extension Hour: Decodable {
    enum CodingKeys: String, CodingKey {
        case time
        case summary
        case temperature
        case apparentTemperature
        case humidity
        case uvIndex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        time = try container.decode(Double?.self, forKey: .time) ?? 0.0
        summary = try container.decode(String?.self, forKey: .summary) ?? ""
        temperature = try container.decode(Double?.self, forKey: .temperature) ?? 0.0
        apparentTemperature = try container.decode(Double?.self, forKey: .apparentTemperature) ?? 0.0
        humidity = try container.decode(Double?.self, forKey: .humidity) ?? 0.0
        uvIndex = try container.decode(Int?.self, forKey: .uvIndex) ?? 0
    }
}
