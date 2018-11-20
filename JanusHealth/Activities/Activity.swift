//
//  Activity.swift
//  JanusHealth
//
//  Created by bayers on 11/17/18.
//  Copyright © 2018 bayers. All rights reserved.
//

import Foundation
import CareKit

/**
 Protocol that defines the properties and methods for sample activities.
 */
protocol Activity {
    var activityType: ActivityType { get }
    
    func carePlanActivity() -> OCKCarePlanActivity
}


/**
 Enumeration of strings used as identifiers for the `SampleActivity`s used in
 the app.
 */
enum ActivityType: String {
    case cardio
    case pulse
    case temperature
}
