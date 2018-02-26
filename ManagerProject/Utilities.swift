//
//  Utilities.swift
//  ManagerProject
//
//  Created by Oleh Busko on 02/08/2017.
//  Copyright © 2017 Oleh Busko. All rights reserved.
//

import Foundation
import ARKit

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension CGRect {
    var mid: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
