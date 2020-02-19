//
//  BaseUrlStatic.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 19/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

#if DEBUG
let BASE_URL = "https://app.sldev.ovh/"
#else
let BASE_URL = "https://app.simplelogin.io"
#endif

let ALIAS_PREFIX_MAX_LENGTH = 100
