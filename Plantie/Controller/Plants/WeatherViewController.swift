import UIKit

class WeatherViewController: UIViewController {
    
    var weatherData: WeatherData?
    
    var cityName: String?
    var timezone: Int?
    var currentWeather: WeatherItem?
    var hourlyWeatherList = [WeatherItem]()
    var dailyWeatherList = [WeatherItem]() // Adjust as needed if daily data is separate
    var weatherIcons = [String: UIImage]()
    
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyCollectionView: UICollectionView!
    // Current Weather UI
    @IBOutlet weak var countryCityLabel: UILabel!
    @IBOutlet weak var updatedDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        dailyCollectionView.dataSource = self
        dailyCollectionView.delegate = self
        setupData()
    }
    
    func setupData() {
        guard let weatherData = weatherData else { return }
        
        cityName = weatherData.city.name
        timezone = weatherData.city.timezone
        
        // Assume the first item in `list` is the current weather
        if !weatherData.list.isEmpty {
            currentWeather = weatherData.list.first
            hourlyWeatherList = weatherData.list // Use first 24 for hourly if needed
        }
        
        gettingWeatherIcons()
        setMainWeatherUI()
    }
    
    func gettingWeatherIcons() {
        weatherIcons.removeAll()
        guard let currentWeather = currentWeather else { return }
        
        for weather in currentWeather.weather {
            WeatherAPI.gettingWeatherIcon(iconKey: weather.icon) { data, response, error in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                DispatchQueue.main.async { [self] in
                    weatherIcons[weather.icon] = image
                    hourlyCollectionView.reloadData()
                    dailyCollectionView.reloadData()
                }
            }
        }
    }
    
    func setWeatherIcon(key: String) -> UIImage? {
        return weatherIcons[key]
    }
    
    func setTime(index: Int) -> String {
        let timeResult = Double(hourlyWeatherList[index].dt)
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a"
        return dateFormatter.string(from: date)
    }
    
    func setDay(index: Int) -> String {
        let timeResult = Double(hourlyWeatherList[index].dt)
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    func setMainWeatherUI() {
        guard let currentWeather = currentWeather else { return }
        
        countryCityLabel.text = cityName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        let currentTime = dateFormatter.string(from: Date(timeIntervalSince1970: Double(currentWeather.dt)))
        updatedDateLabel.text = "آخر تحديث: \(currentTime)"
        
        descriptionLabel.text = currentWeather.weather.first?.description
        tempLabel.text = "\(fahrenheitToCelsius(currentWeather.main.temp)) °C"
        lowTempLabel.text = "السفلى: °\(fahrenheitToCelsius(currentWeather.main.tempMin))C"
        highTempLabel.text = "العليا: °\(fahrenheitToCelsius(currentWeather.main.tempMax))C"
        
        dateFormatter.dateFormat = "hh:mm a"
        if let sunrise = weatherData?.city.sunrise, let sunset = weatherData?.city.sunset {
            sunriseTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(sunrise)))
            sunsetLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(sunset)))
        }
        
        windLabel.text = "\(currentWeather.wind.speed) miles"
        pressureLabel.text = String(currentWeather.main.pressure)
        humidityLabel.text = String(currentWeather.main.humidity)
    }
    
    func fahrenheitToCelsius(_ fahrenheit: Double) -> Int {
        return Int((fahrenheit - 32) * 5 / 9)
    }
}

// MARK: - Extensions for CollectionView
extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == hourlyCollectionView ? hourlyWeatherList.count : dailyWeatherList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == hourlyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourCell", for: indexPath) as! HourlyCollectionViewCell
            let weatherItem = hourlyWeatherList[indexPath.row]
            cell.timeLabel.text = setTime(index: indexPath.row)
            cell.tempLabel.text = "\(fahrenheitToCelsius(weatherItem.main.temp)) °C"
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DailyCollectionViewCell
            let weatherItem = dailyWeatherList[indexPath.row]
            cell.dayLabel.text = setDay(index: indexPath.row)
            cell.descriptionLabel.text = weatherItem.weather.first?.description
            cell.iconImageView.image = setWeatherIcon(key: weatherItem.weather.first?.icon ?? "")
            cell.highTempLabel.text = "\(fahrenheitToCelsius(weatherItem.main.tempMax)) °C ↑"
            cell.lowTempLabel.text = "\(fahrenheitToCelsius(weatherItem.main.tempMin)) °C ↓"
            return cell
        }
    }
    
    // Adjust layout methods as needed
}
