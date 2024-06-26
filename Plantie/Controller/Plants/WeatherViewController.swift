import UIKit

class WeatherViewController: UIViewController {
    
    var weatherData: WeatherData?
    
    var countryCityName: String?
    var currentWeather: Current?
    var hourlyWeatherList = [Current]()
    var dailyWeatherList = [Daily]()
    var weatherIcons = [String: UIImage]()

    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyCollectionView: UICollectionView!
    //Current Weather UI
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

    
    func setupData(){
        dailyWeatherList.removeAll()
        hourlyWeatherList.removeAll()
        
        self.countryCityName = weatherData!.timezone
        self.currentWeather = weatherData!.current
        self.hourlyWeatherList = weatherData!.hourly
        self.dailyWeatherList = weatherData!.daily
        gettingWeatherIcons()
        setMainWeatherUI()
    }
    
    func gettingWeatherIcons() {
        weatherIcons.removeAll()
        for key in WeatherIcons.iconKey {
            WeatherAPI.gettingWeatherIcon(iconKey: key) { data, response, error in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                DispatchQueue.main.async { [self] in
                    weatherIcons[key] = image
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
        let time = dateFormatter.string(from: date)
        return time
    }
    
    func setDay(index: Int) -> String {
        let timeResult = Double(dailyWeatherList[index].dt)
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let day = dateFormatter.string(from: date)
        return day
    }
    
    func setMainWeatherUI() {
        countryCityLabel.text = countryCityName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yyyy hh:mm a"
        let currentTime = dateFormatter.string(from: Date(timeIntervalSince1970: Double(currentWeather!.dt)))
        updatedDateLabel.text = "آخر تحديث: \(currentTime)"
        descriptionLabel.text = currentWeather?.weather[0].weatherDescription
        tempLabel.text = "\(fahrenheitToCelsius(currentWeather!.temp)) °C"
        lowTempLabel.text = "السفلى: °\(fahrenheitToCelsius(dailyWeatherList[0].temp.min))C"
        highTempLabel.text = "العليا: °\(fahrenheitToCelsius(dailyWeatherList[0].temp.max))C"
        dateFormatter.dateFormat = "hh:mm a"
        sunriseTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(currentWeather!.sunrise!)))
        sunsetLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(currentWeather!.sunset!)))
        windLabel.text = "\(currentWeather!.windSpeed) miles"
        pressureLabel.text = String(currentWeather!.pressure)
        humidityLabel.text = String(currentWeather!.humidity)
    }
    
    func fahrenheitToCelsius(_ fahrenheit: Double) -> Int {
        return Int((fahrenheit - 32) * 5 / 9)
    }
}

extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case hourlyCollectionView:
            return hourlyWeatherList.count
        case dailyCollectionView:
            return dailyWeatherList.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case hourlyCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourCell", for: indexPath) as! HourlyCollectionViewCell
            cell.backgroundColor = .cyan
            cell.timeLabel.text = setTime(index: indexPath.row)
            cell.tempLabel.text = "\(Int(fahrenheitToCelsius(hourlyWeatherList[indexPath.row].temp))) °C"
            return cell
        case dailyCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DailyCollectionViewCell
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = .black
            }else {
                cell.backgroundColor = .darkGray
            }
            cell.dayLabel.text = setDay(index: indexPath.row)
            cell.descriptionLabel.text = dailyWeatherList[indexPath.row].weather[0].weatherDescription
            cell.iconImageView.image = setWeatherIcon(key: dailyWeatherList[indexPath.row].weather[0].icon)
            cell.highTempLabel.text = "\(Int(fahrenheitToCelsius(dailyWeatherList[indexPath.row].temp.max))) °C ↑"
            cell.lowTempLabel.text = "\(Int(fahrenheitToCelsius(dailyWeatherList[indexPath.row].temp.min))) °C ↓"
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        switch collectionView {
        case hourlyCollectionView:
            return CGSize(width: 75, height: height)
        case dailyCollectionView:
            return CGSize(width: 130, height: height)
        default:
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case hourlyCollectionView:
            return 2
        case dailyCollectionView:
            return 0
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
