//
//  CSPreferences.swift
//  ComponentStudio
//
//  Created by devin_abbott on 7/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import SwiftyJSON

func preferencesDirectory() -> URL {
    let home: URL
    
    if #available(OSX 10.12, *) {
        home = FileManager.default.homeDirectoryForCurrentUser
    } else {
        home = URL(string: "/tmp")!
    }
    
    return home
}

class CSUserPreferences: CSPreferencesFile {
    static var url: URL {
        return preferencesDirectory().appendingPathComponent(".componentstudio")
    }
    
    static var data: CSData = load()
}
