//
//  ScannerError.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/02.
//

import Foundation

enum ScannerError: Error, CustomStringConvertible {
    case convertToCIImageError
    case invalidFeaturesOfImage
    
    var description: String {
        switch self {
        case .convertToCIImageError:
            return "CIImage변환을 실패했습니다."
        case .invalidFeaturesOfImage:
            return "입력된 이미지의 잘못된 feature입니다."
        }
    }
}
