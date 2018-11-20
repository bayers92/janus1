//
//  DataHelpers.swift
//  JanusHealth
//
//  Created by bayers on 11/17/18.
//  Copyright © 2018 bayers. All rights reserved.
//

import Foundation


class DataHelpers {
    
    func normalize(_ values: [Double?]) -> [Double] {
        let valuesWithDefaults = values.map({ (value) -> Double in
            guard let value = value else { return 0.0 }
            return value
        })
        
        guard let maxValue = valuesWithDefaults.max() , maxValue > 0.0 else {
            return valuesWithDefaults
        }
        
        return valuesWithDefaults.map({$0 / maxValue})
    }
    
}


