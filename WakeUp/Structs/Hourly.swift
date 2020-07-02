//
//  Hourly.swift
//  WakeUp
//
//  Created by Carter Gran on 5/11/20.
//  Copyright © 2020 Carter Gran. All rights reserved.
//

import Foundation

struct Hourly {
    let summary: String?
    var data = [Hour]()
}

extension Hourly: Decodable {
    enum CodingKeys: String, CodingKey {
        case summary
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        summary = try container.decode(String?.self, forKey: .summary) ?? ""
        data = try container.decode([Hour]?.self, forKey: .data) ?? []
    }
}
