//
//  SystemFrameworkExtenstion.swift
//  Lobddit
//
//  Created by PersonA on 7/18/19.
//  Copyright © 2019 Michael Tai. All rights reserved.
//

import Foundation

extension URL {
    var isHttps: Bool {
        get { return (scheme ?? "") == "https" }
    }
}
