//
//  News.swift
//  WakeUp
//
//  Created by Carter Gran on 4/18/20.
//  Copyright © 2020 Carter Gran. All rights reserved.
//

import Foundation

struct News: Decodable {
    var articles = [Article]()
    
    init() {}
    
    init (_ articles: [Article]) {
        self.articles = articles
    }
}
