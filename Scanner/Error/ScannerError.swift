//
//  ScannerError.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/02.
//

import Foundation

enum ScannerError: Error, CustomStringConvertible {
    
    case convertToCIImageError
    case failToCreateCGImage
    
    var description: String {
        switch self {
        case .convertToCIImageError:
            return "convertToCIImageError: CIImage변환을 실패했습니다."
        case .failToCreateCGImage:
            return "failToCreateCGImage: CGImage생성에 실패했습니다."
        }
    }
}
