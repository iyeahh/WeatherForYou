# 🗓 웨더포유 (WeatherForYou)

##### 2023년 11월 1일 → 2023년 11월 20일 (3주)

## ☀️ 배경색만으로도 날씨를 확인할 수 있는 직관적인 날씨앱
* 맑음 / 흐림 / 비 / 눈 의 배경색을 다르게 하여 앱을 켜자마자 현재 날씨를 알 수 있도록 함

## 🤓 기술스택
* UIKit
* UI -> Code
* CLLocation, CLGeocoder
* URLSession
* MVC → MVVM 리팩토링

## 💡 문제 해결

### ❓ 문제
**반복되는 API호출을 줄여, 간단한 코드로 줄일 수 없을까? (제네릭 문법 활용)**

### ❕ 해결 방법

💡 **문제상황**: **API 4개를 사용하고 있는 네트워킹 함수가 있지만, 반복되는 요소들이 눈에 띔. 어떻게 반복되는 코드를 줄일 수 있을까?**

- Result 결과값들이 모두 Decodable을 채택하는 공통점을 이용하여 제네릭 문법을 활용
- URL을 생성하는 함수는 각각 만들고, 네트워킹하는 함수는 하나로 만들어 반복되는 요소를 줄임
    
    ```swift
    // 각 API의 URL을 생성하는 함수들
    func fetchCurrentWeather(lat: String, lon: String, completion: @escaping (Result<CurrentWeather, NetworkError>) -> Void)
    func fetch3DaysForecast(lat: String, lon: String, completion: @escaping (Result<Forecast3Days, NetworkError>) -> Void)
    func fetchWeekWeather(location: String, date: String, completion: @escaping (Result<WeekWeather, NetworkError>) -> Void)
    func fetchWeekWeatherRainAndImage(location: String, date: String, completion: @escaping (Result<WeekWeatherRainAndImage, NetworkError>) -> Void
    ```
    
    ```swift
    // URLSession.shared.dataTask(with: request) 하는 함수
    func performRequest<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, NetworkError>) -> Void)
    ```
    


---
       
### ❓ 문제
**2개 이상의 비동기 함수가 종료되는 시점 확인하기 (DispatchGroup 활용)**

### ❕ 해결 방법

💡 **문제 상황**: **날씨 API의 2개의 결과값을 동시에 사용(위도/경도 및 날씨 관련 이미지)해야 하는데, 어떻게 하면 끝나는 시점이 각기 다른 2개의 비동기 함수들이 모두 종료되는 시점을 어떻게 파악할 수 있을까?**

- 디스패치 그룹을 활용하여, 비동기적으로 동작하는 2개의 함수 시점을 파악
- `DispatchGroup()`을 생성하여 `.enter()` `.leave()`을 활용
- 해당 그룹이 종료되는 시점을 notify메서드를 활용, 해당 시점에 대해 노티를 받음
    
    ```swift
    func fetchWeekWeatherDataWith(regionCode: String, imageRegionCode: String) {
        **let group = DispatchGroup()
        group.enter()**
    
        networkManager.fetchWeekWeather(location: regionCode, date: Date.currentDataForWeek()) { result in
            switch result {
            case .success(let weekWeather):
                guard let weekWeatherTemp = weekWeather.response?.weekWeatherResponse?.weekWeatherItems?.weekWeatherTempList?.first else { return }
                self.weekWeatherTemp = weekWeatherTemp
                **group.leave()**
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    
        **group.enter()**
        networkManager.fetchWeekWeatherRainAndImage(location: imageRegionCode, date: Date.currentDataForWeek()) { result in
            switch result {
            case .success(let weekWeatherImage):
                guard let weekWeatherRainAndImage = weekWeatherImage.response?.weekWeatherImageResponse?.weekWeatherImageItems?.weekWeatherRainAndImageList?.first else { return }
                self.weekWeatherRainAndImageData = weekWeatherRainAndImage
                **group.leave()**
    
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    
        **group.notify**(queue: .global()) { [weak self] in
            guard
                let temp = self?.weekWeatherTemp,
                let rainAndImage = self?.weekWeatherRainAndImageData else { return }
            self?.convertWeekWeather(temp: temp, rainAndImage: rainAndImage)
        }
    }
    ```
    

    
---
### ❓ 문제
**반복되는 네트워킹 호출 줄이기, 비동기적인 데이터 호출 후에 데이터 생성 시점 파악하기 (데이터 관리 Layer추가와 노티피케이션을 활용한 데이터 바인딩)**

### ❕ 해결 방법

💡 **문제상황:** **각 탭마다 네트워킹 함수와 CoreLocation을 호출하여 켜지는데 시간이 소요되고, 반복되는 네트워킹 함수 호출이 많음**
 **→ 어떻게 하면 유저의 더 나은 경험이 되도록 하고, 반복되는 네트워킹 함수 호출을 줄일 수 있을까?**

- (각 화면이 아닌) 날씨 데이터를 관리하는 객체(`DataManager`)를 따로 분리해서 날씨 데이터를 관리하도록 하고(한 번에 네트워킹 호출), 노티피케이션을 이용해서 데이터 생성 시점에 각 탭에 뷰 그리기
    - 배열들과 함수를 **데이터 관리 객체** 한 곳에 모아 가독성을 높이고 `14개`의 반복되는 함수를 `5개`로 줄일 수 있었음
    - 데이터 관리 객체 Layer에서 데이터 생성 시점을 노티피케이션을 활용해, 시점을 전달 했음 (노티피케이션을 활용한 데이터 바인딩)
    
    ```swift
    // 변수마다 노티피케이션을 부여해 값이 변경되면 뷰를 유동적으로 그리도록 함
    extension Notification.Name {
        static let cityName = Notification.Name("cityName")
        static let mainWeather = Notification.Name("mainWeather")
        static let todayWeatherList = Notification.Name("todayWeatherList")
        static let tomorrowWeatherList = Notification.Name("tomorrowWeatherList")
        static let dayAfterTomorrowWeatherList = Notification.Name("dayAfterTomorrowWeatehrList")
        static let weekWeatherList = Notification.Name("weekWeatherList")
    }
    
    private func setupNotification() {
            NotificationCenter.default.addObserver(self, selector: #selector(configureUI), name: .cityName, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(configureUI), name: .mainWeather, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(configureUI), name: .todayWeatherList, object: nil)
        }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
    ```
    

---
### ❓ 문제
**정확한 위치기반이나 기준이 없는 날씨 API를 이용해야하는 문제점 (기상청 API 예보구역코드 매칭 문제)**

### ❕ 해결 방법

💡 **문제상황:** **기상청 API를 호출할 때 필수로 예보구역코드가 필요한데 201개로 나누어진 코드를 어떻게 적용시켜야 할까?**

- 예보구역코드는 대한민국을 (특별한 기준이 없이 임의로) 201개의 도시로 나누어 놓음 (이에 대해 나누는 정확한 기준이 나와있지 않아)
- CLGeocoder의 `placemark.administrativeArea`를 기준으로 임의로 나눔
- 16개의 시/도로 나누고 예보구역코드에 나와있는 도시 중 해당 시/도에서 인구가 가장 많은 도시의 코드를 매치시킴
    
    ```swift
    let geocoder = CLGeocoder()
    let local = Locale(identifier: "Ko-kr")
    
    geocoder.reverseGeocodeLocation(location, preferredLocale: local) { (placemarks, error) in
          if let error = error {
             print("Error: \(error.localizedDescription)")
             return
          }
    
          if let placemark = placemarks?.first {
             if let cityName = placemark.locality, let subCityName = placemark.subLocality {
    
                  guard let city = placemark.administrativeArea else { return }
                  let regionCode = self.getRegionCodeForWeek(city: city)
    			}
    }
    ```
    
    ```swift
    func getRegionCodeForWeek(city: String) -> String {
            switch city {
            case "서울특별시":
                return "11B10101"
            case "부산광역시":
                return "11H20201"
            case "인천광역시":
                return "11B20201"
            case "대구광역시":
                return "11H10701"
            case "대전광역시":
                return "11C20401"
            case "광주광역시":
                return "11F20501"
            case "경기도":
                return "11B20601"
            case "울산광역시":
                return "11H20101"
            case "충청남도":
                return "11C20301"
            case "충청북도":
                return "11C10301"
            case "경상남도":
                return "11H20301"
            case "경상북도":
                return "11H10201"
            case "전라남도":
                return "11F20401"
            case "전라북도":
                return "11F10201"
            case "제주특별자치도":
                return "11G00201"
            case "강원도":
                return "11D10401"
            default:
                return "11B10101"
            }
    }
    ```
    
---
### ❓ 문제
**런치스크린 시점 조절을 통한 자연스러운 UX구현 (앱 런칭시 네트워킹을 시작하고, 데이터 생성시점에 런치스크린 종료 구현)**

### ❕ 해결 방법
💡 **문제상황:** **앱 런칭시, 필수적으로 날씨 데이터를 가져오기 위한 네트워킹이 진행되고,  네트워킹 동안 유저가 (하얀색 화면이 아닌) 런치스크린을 보다가, 
                자연스럽게 “데이터 생성시점”에 앱의 첫번째 화면으로 넘어가려면 어떻게 구현해야 할까?**

- 네트워킹이 끝나는 시점에 rootViewController를 첫 탭으로 할당해 런치스크린 종료 시점을 파악하여 이동시키도록 구현
    
    ```swift
    // 선언부
    func setupCoreLocation(completion: @escaping () -> Void) {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
    
            completion()
    }
    ```
    
    ```swift
    // 실행부
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WeatherDataManager.shared.setupCoreLocation {
           DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    if let window = windowScene.windows.first {
                       window.rootViewController = TodayViewController()
                    }
                }
           }
    			 return true
        }
    }
    ```
