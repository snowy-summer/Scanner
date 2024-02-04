//
//  DetectorError.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/04.
//

import Foundation

enum DetectorError: Error, CustomStringConvertible {
    
    case failToDetectRectangle
    case failToConvertMonoImage
    case failToGetPerspectiveCorrectionImage
    
    var description: String {
        switch self {
        case .failToDetectRectangle:
            return "cantFindRectangle: 사각형을 찾지 못했습니다."
        case .failToConvertMonoImage:
            return "failToConvertMonoImage: 흑백 이미지변환 실패했습니다."
        case .failToGetPerspectiveCorrectionImage:
            return "failToGetPerspectiveCorrectionImage: 스캔된 이미지를 가지고 오는데 실패했습니다."
        }
    }
}
