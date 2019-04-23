
//
//  ImageResize.swift
//  MYOpenGLDemo02
//
//  Created by Carol on 2019/4/23.
//  Copyright © 2019 Carol. All rights reserved.
//

import Foundation

enum CAImgSize: Int {
    case AGLK1 = 1
    case AGLK2 = 2
    case AGLK4 = 4
    case AGLK8 = 8
    case AGLK16 = 16
    case AGLK32 = 32
    case AGLK64 = 64
    case AGLK128 = 128
    case AGLK256 = 256
    case AGLK512 = 512
    case AGLK1024 = 1021
}

struct ImageResize {
    static func CAGLKCalculatePowerOf2(forDimension dimension: Int) -> CAImgSize {
        var result = CAImgSize.AGLK1
        if dimension > CAImgSize.AGLK512.rawValue {
            result = .AGLK1024
        } else if dimension > CAImgSize.AGLK256.rawValue {
             result = .AGLK512
        } else if dimension > CAImgSize.AGLK128.rawValue {
            result = .AGLK256
        } else if dimension > CAImgSize.AGLK64.rawValue {
            result = .AGLK128
        } else if dimension > CAImgSize.AGLK32.rawValue {
            result = .AGLK64
        } else if dimension > CAImgSize.AGLK16.rawValue {
            result = .AGLK32
        } else if dimension > CAImgSize.AGLK8.rawValue {
            result = .AGLK16
        } else if dimension > CAImgSize.AGLK4.rawValue {
            result = .AGLK8
        } else if dimension > CAImgSize.AGLK2.rawValue {
            result = .AGLK4
        } else if dimension > CAImgSize.AGLK1.rawValue {
            result = .AGLK2
        }
        return result
    }
}
