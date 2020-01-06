//
//  Utility.swift
//  ipad_scrollapp
//
//  Created by miyata ginga on 2020/01/06.
//  Copyright © 2020 com.miyagin.ipad_scroll. All rights reserved.
//

import Foundation

class Utility {
    // y = x/(max-min)+min/(min-max)
    class func faceAURangeChange(faceAUVertex: Float, maxFaceAUVertex: Float, minFaceAUVertex: Float) -> Float {
        let faceAUChangeValue = faceAUVertex / (maxFaceAUVertex - minFaceAUVertex) + minFaceAUVertex / (minFaceAUVertex - maxFaceAUVertex)
        return faceAUChangeValue
    }
}
