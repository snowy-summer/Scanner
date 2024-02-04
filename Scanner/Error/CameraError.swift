//
//  CameraError.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/03.
//

import Foundation

enum CameraError: Error,CustomStringConvertible {
    
    case cantAddBackCamera
    case cantAddDeviceInput
    case cantAddPhotoOutput
    case cantAddVideoOutput
    
    var description: String {
        switch self {
        case .cantAddBackCamera:
            return "cantAddBackCamera: 후면 카메라를 추가하지 못했습니다."
        case .cantAddDeviceInput:
            return "cantAddDeviceInput: 디바이스 입력을 추가하지 못했습니다."
        case .cantAddPhotoOutput:
            return "cantAddPhotoOutput: 사진 출력을 추가하지 못했습니다."
        case .cantAddVideoOutput:
            return "cantAddVideoOutput: 비디오 출력을 추가하지 못했습니다."
        }
    }
}
