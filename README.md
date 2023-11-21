# 🗓 WeatherForYou README

##### 2023년 11월 1일 → 2023년 11월 20일

## ☀️ 배경색만으로도 날씨를 확인할 수 있는 직관적인 날씨앱
* 맑음 / 흐림 / 비 / 눈 의 배경색을 다르게 하여 앱을 켜자마자 현재 날씨를 알 수 있도록 함

## 🤓 기술스택
* UIKit
* CLLocation, CLGeocoder
* URLSession
* UICollecionView
* UITableView

## ⚽️ 트러블 슈팅

### 👿 트러블
* `API Key` 숨기기

### 😈 해결 방법
* `API Key`를 config 파일에 담고,
* gitignore에 config 파일을 추가하여 숨김
---
### 👿 트러블
* NetworkManager 하나로 여러 API 사용하기

### 😈 해결 방법
* URL 생성하는 함수는 각각 만들고
* `performRequest<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, NetworkError>) -> Void)`
* 제네릭을 활용하여 네트워킹하는 함수는 하나로 묶음
---
### 👿 트러블
* 2개 이상의 비동기 함수가 종료되는 시점 확인하기

### 😈 해결 방법
* `DispatchGroup()`을 생성하여 `group.enter()` ` group.leave()` 을 활용하여
* 해당 그룹이 종료되는 시점을 노티 받아 확인
---
### 👿 트러블
* 각 탭을 들어갈 때마다 네트워킹 시작 → 탭마다 켜지는데 시간 소요
* 반복되는 함수가 많고 CoreLocation을 탭마다 호출

### 😈 해결 방법
* `DataManager` 을 생성하여 네트워킹 후 노티피케이션을 이용해서 끝나는 시점에 뷰에 그리기
---
### 👿 트러블
* 런치스크린 종료되는 시점

### 😈 해결 방법
* 네트워킹 끝나는 시점에 클로저 실행하여 첫번째 탭 보이기
