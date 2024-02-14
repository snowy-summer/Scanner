# 스캐너 앱

## 팀원

| 범 |
| --- |
| <img src="https://avatars.githubusercontent.com/u/118453865?v=4" width=200> |

<br/>

## 프로젝트 개요

카메라 기능을 사용하여 사각형의 물체를 탐지해 이미지를 스캔하는 앱

<br/>

## 구현 영상

| 구현 영상 |
| --- |
| <img src="https://github.com/snowy-summer/Scanner/assets/118453865/dd4e4f8d-3e03-48bd-9e2d-0c04e8842571" width=300> |

<br/>

## 프로젝트 파일 구조

```swift
.
├── Scanner
│   ├── Scanner
│   │   ├── Info.plist
│   │   ├── Application
│   │   │   ├── AppDelegate.swift
│   │   │   └── SceneDelegate.swift
│   │   │ 
│   │   ├── Controller
│   │   │   ├── MainViewController.swift
│   │   │   ├── PreviewController.swift
│   │   │   └── RepointViewController.swift
│   │   │ 
│   │   ├── View
│   │   │   ├── MainView.swift
│   │   │   ├── Preview.swift
│   │   │   ├── RepointView.swift
│   │   │   ├── ControlCircle.swift
│   │   │ 
│   │   ├── Error
│   │   │   ├── ScannerError.swift
│   │   │   ├── DetectorError.swift
│   │   │   └── CameraError.swift
│   │   │ 
│   │   ├── Scanservice
│   │   │   ├── ScanserviceProvider.swift
│   │   │   └── Detector
│   │   │       ├── RectangleDetector.swift
│   │   │       └── CIFilterKeyName.swift
│   │   │ 
│   │   └── Extension
│   │       └── UIImage+Extension.swift
│   │   
│   └── Scanner.xcodeproj
└── README.md

```

<br/>

## Trouble Shooting

### 좌표 변환 문제

- core Image의 좌표와 UIkit의 좌표 시스템이 달라서 중앙에 위치하면 정상적으로 나오지만 회전 하는 경우 화면위의 사각형이 다르게 표시되는 문제가 발생

| 중앙  | 회전 |
| --- | --- |
| <img src="https://github.com/snowy-summer/Scanner/assets/118453865/4139b3f3-e346-442d-b427-ccffc2d40407" width=300> | <img src="https://github.com/snowy-summer/Scanner/assets/118453865/e59d1331-ad50-408b-a2ab-59c22e2b7c67" width=300> |



- core image로 받아온 좌표를 UIkit에 맞추어 변환을 해주었다.
- 추가적으로 인식 물체가 모서리에 위치 할 경우 사각형이 인식 물체와 위치가 달라지는 문제가 발생
  
| 좌상단  | 우상단 |
| --- | --- |
| <img src="https://github.com/snowy-summer/Scanner/assets/118453865/d88306d6-d877-4abd-8c0c-e6adb010fa50" width=300> | <img src="https://github.com/snowy-summer/Scanner/assets/118453865/f30fe0e2-186d-429d-bc65-329a6173a0db" width=300> |

| 우하단  | 좌하단 |
| --- | --- |
| <img src="https://github.com/snowy-summer/Scanner/assets/118453865/2f9afc3b-44f5-4d8e-9d96-d2056d299e65" width=300> | <img src="https://github.com/snowy-summer/Scanner/assets/118453865/f2c9147f-c1ae-4629-af3e-49977db55828" width=300> |
- 문제 이유: AVCaptureVideoOrientation이 휴대폰의 방향과 달라서 90도 정도 회전 후 들어오기 때문이다.

- 해결방법 1. 받아온 CGPoint를 화면에 맞게 회전을 시켜주었다.
    - 하지만, 정확한 변환이 실패했는지 정확한 위치를 못잡는 경우가 발생하였다.

- 해결방법 2.  AVCaptureVideoOrientation을 디바이스의 orientaion에 일치시켰다.

```swift
mainQueue.async { [weak self] in
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        let orientation = windowScene.interfaceOrientation
        self?.videoOutput.connection(with: .video)?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
    }
}
```

### Repoint View 좌표 문제

- CIRectangleFeature로 받아온 사각형의 포인트 값을 이용해 view에 표시를 해야한다.
- 기존의 문제는 photoOutput으로 받아온 사진을 사용해서 문제가 발생했다.
    - 위의 사각형 표시와 동일하게 90도 정도 회전해 있는 문제가 발생

| RepointView 좌표회전 문제  |
| --- |
| <img src="https://github.com/snowy-summer/Scanner/assets/118453865/95fa4bfe-1573-4b9c-b082-7353ceb4e347" width=300> |

- AVCaptureVideoOrientation의 orientation을 변경한 것과 상관없이 작동을 하였다.
    - photoOutput의 방향을 설정하는 방법을 찾지 못했다.
- 그래서 video의 frame들이 이미지이기 때문에 이 frame을 가지고 오기로 변경했다.
- 변경을 통해서 회전이 일어난 좌표의 문제는 해결했다.

- 추가적으로 그려준 사각형과 사각형의 크기를 변경시킬 수 있는 원의 위치가 다른 문제가 발생하였다.

| RepointView 원과 사각형 불일치|
| --- | 
| <img src="https://github.com/snowy-summer/Scanner/assets/118453865/b1bc4970-b20d-4da8-b4de-1ddcdd9b217e" width=300> |

- 원이 추가된 view와 사각형이 추가된 view가 서로 달라서 발생하는 문제
    - view를 일치 시켜주었다.
