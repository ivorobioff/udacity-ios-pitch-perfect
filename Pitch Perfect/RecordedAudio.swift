//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Igor Vorobiov on 1/31/16.
//  Copyright © 2016 Igor Vorobiov. All rights reserved.
//

import Foundation

class RecordedAudio {
    
    let title: String
    let url: NSURL
    
    init (title: String, url: NSURL){
        self.title = title
        self.url = url
    }
}
