//
//  Helpers.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/10/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation
import UIKit


//Make sure things are done on the main thread
func performOnMain(updates: () -> Void){
    dispatch_async(dispatch_get_main_queue()){
        updates()
    }
}

