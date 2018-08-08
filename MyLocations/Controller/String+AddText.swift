//
//  String+AddText.swift
//  MyLocations
//
//  Created by Ronald Tong on 8/8/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import UIKit

// Mutatung Function: the method can only be used on structures made with var, not those declared with let
// separator has a default value "" if no parameter is given for separatedBy

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
