//
//  HelperFunctions.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 03/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import FirebaseFirestore

//MARK: - GLOBAL FUNCTIONS
private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}


