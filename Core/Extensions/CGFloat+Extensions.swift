//
//  CGFloat+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/04/2025.
//

import Foundation

extension CGFloat {

    var remainderAfterPowerOfTwo: CGFloat {
        let intValue = Int(self)
        var power = 1
        while power * 2 <= intValue {
            power *= 2
        }
        return CGFloat(intValue - power)
    }

    static func interpolate(from start: CGFloat, to end: CGFloat, progress: CGFloat) -> CGFloat {
        return start + (end - start) * progress
    }
    
    func rounded(to decimals: Int) -> CGFloat {
        let factor = pow(10.0, CGFloat(decimals))
        return (self * factor).rounded() / factor
    }
}
