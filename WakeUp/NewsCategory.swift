//
//  NewsCategories.swift
//  WakeUp
//

import Foundation
import UIKit

class NewsCategory {
    var name: String
    var image: UIImage
    
    init?(name: String, image: UIImage? = UIImage(named: "defaultImage")){
        
        guard !name.isEmpty else {
            return nil
        }
        
        guard let categoryImage = image else {
            return nil
        }
        
        self.name = name
        self.image = categoryImage
    }
}
