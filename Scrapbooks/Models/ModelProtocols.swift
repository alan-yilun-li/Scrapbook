//
//  ModelProtocols.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-08-10.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation

protocol Named {

    var name: String { get set }
}

// MARK: - Scrapbook-Name Uniqueness Functions
extension String {
    
    func isUniqueName<T>(among: [T]?) -> Bool where T: Named {
        
        let group = among ?? []
        
        for item in group {
            if self == item.name {
                return false
            }
        }
        return true
    }
}



