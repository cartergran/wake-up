//
//  Article.swift
//  WakeUp
//
//  Created by Carter Gran on 4/5/20.
//  Copyright © 2020 Carter Gran. All rights reserved.
//

import Foundation
import UIKit

struct Article {
    let title: String?
    var description: String?
    let content: String?
    let url: String?
    let source: String?
    var image: UIImage = UIImage(imageLiteralResourceName: "defaultImage")
    var urlToImage: String?
}

extension Article: Decodable {
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case content
        case url
        case urlToImage
        case sourceInfo = "source"
        
        enum SourceKeys: String, CodingKey {
            case sourceName = "name"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String?.self, forKey: .title) ?? ""
        description = try container.decode(String?.self, forKey: .description) ?? ""
        content = try container.decode(String?.self, forKey: .content) ?? ""
        url = try container.decode(String?.self, forKey: .url) ?? ""
        urlToImage = try container.decode(String?.self, forKey: .urlToImage) ?? ""
        
        let sourceContainer = try container.nestedContainer(keyedBy: CodingKeys.SourceKeys.self, forKey: .sourceInfo)
        source = try sourceContainer.decode(String?.self, forKey: .sourceName) ?? ""
    }
}



