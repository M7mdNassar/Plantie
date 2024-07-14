import UIKit
import SwiftLocation
import CoreLocation
import ProgressHUD
import NVActivityIndicatorView

class PlantsViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var weatherBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var weatherStateLabel: UILabel!
    @IBOutlet weak var weatherStateImageView: UIImageView!
    @IBOutlet weak var adviceWeatherState: UILabel!
    @IBOutlet weak var goToWeatherControllerButton: UIButton!
    @IBOutlet weak var adviceWeatherStateHightConstrain: NSLayoutConstraint!

    // MARK: Variables
    var plants: [Plant] = []
    var locationManager = CLLocationManager()
    var data: Plant?

    var weatherData: WeatherData?

    let backButton = UIBarButtonItem()
    var activityIndicator: NVActivityIndicatorView?

    let weatherAdvice: [String: String] = [
        "veryCold": "الجو متجمد! احمِ نباتاتك من الصقيع. قد تحتاج إلى نقل النباتات إلى الداخل.",
        "cold": "الجو بارد. يفضل تغطية نباتاتك ليلاً. تأكد من مراقبة مستويات الرطوبة.",
        "cool": "الجو بارد. تأكد من حصول نباتاتك على كمية كافية من ضوء الشمس. قد تحتاج إلى تقليل الري.",
        "mild": "الجو معتدل. يجب أن تكون نباتاتك مزدهرة. حافظ على روتين الري المنتظم.",
        "warm": "الجو دافئ. تأكد من ري نباتاتك جيداً. قد تحتاج إلى توفير بعض الظل خلال ساعات الظهيرة.",
        "hot": "الجو حار. حافظ على رطوبة نباتاتك وقدم بعض الظل. تأكد من الري في الصباح الباكر أو المساء لتجنب التبخر السريع."
    ]

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        configureLocationAccess()
        setupActivityIndicator()
        setupTableView()
        getPlants()
        getWeatherData { _ in }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    // MARK: Actions

    @IBAction func goToWeatherController(_ sender: UIButton) {
        if !Reachability.isConnectedToNetwork() {
            // Display an alert if there's no internet connection
            ProgressHUD.banner("لا يوجد اتصال بالإنترنت", "يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.", delay: 2.0)
            return
        }

        if locationManager.authorizationStatus == .authorizedWhenInUse {
            if weatherData == nil {
                // Fetch weather data if not already available
                getWeatherData { success in
                    if success {
                        self.navigateToWeatherViewController()
                    } else {
                        ProgressHUD.banner("فشل في جلب بيانات الطقس", "يرجى المحاولة مرة أخرى.", delay: 2.0)
                    }
                }
            } else {
                // Navigate to weather controller if weather data is already available
                navigateToWeatherViewController()
            }
        } else {
            // If location access is not granted, print a message
            ProgressHUD.banner("لا يوجد صلاحية للوصول إلى موقعك", "يرجى السماح بالوصول إلى الموقع للحصول على معلومات الطقس.", delay: 2.0)
        }
    }

    // MARK: Methods

    func navigateToWeatherViewController() {
        guard let weatherViewController = storyboard?.instantiateViewController(withIdentifier: "weatherController") as? WeatherViewController
        else {
            return
        }

        weatherViewController.weatherData = self.weatherData

        present(weatherViewController, animated: true, completion: nil)
    }

    func getWeatherAdvice(for temperature: Double) -> String {
        switch temperature {
        case ..<0:
            return weatherAdvice["veryCold"] ?? ""
        case 0..<10:
            return weatherAdvice["cold"] ?? ""
        case 10..<20:
            return weatherAdvice["cool"] ?? ""
        case 20..<25:
            return weatherAdvice["mild"] ?? ""
        case 25..<30:
            return weatherAdvice["warm"] ?? ""
        case 30...:
            return weatherAdvice["hot"] ?? ""
        default:
            return "No advice available."
        }
    }
    
    func updateWeatherImage(for description: String) {
        switch description.lowercased() {
        case "clear sky", "sunny":
            weatherStateImageView.image = UIImage(named: "sun")
        case "few clouds", "cloudy":
            weatherStateImageView.image = UIImage(named: "cloudy")
        case "rain":
            weatherStateImageView.image = UIImage(named: "rain")
        default:
            weatherStateImageView.image = UIImage(named: "clouds")
        }
    }
}

// MARK: Table Datasource

extension PlantsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue() as PlantTableViewCell
        cell.configure(plant: plants[indexPath.row])
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "plantDetails" {
            let vc = segue.destination as! PlantDetailsViewController
            vc.plant = self.data
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Hide the Selection Highlight
        tableView.deselectRow(at: indexPath, animated: true)

        self.data = plants[indexPath.row]

        self.performSegue(withIdentifier: "plantDetails", sender: self)
    }
}

// MARK: Private Methods
private extension PlantsViewController {
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        tableView.register(Cell: PlantTableViewCell.self)
    }

    func getPlants() {
        if let plants = PlantLoader.loadPlants(fromJSONFile: "PlantsData") {
            // Use the plants array here
            self.plants = plants
        } else {
            print("Failed to load plants")
        }
    }

    func formatDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        currentDateLabel.text = dateFormatter.string(from: date)
    }

    func updateBackgroundColor(for temperature: Double) {
        let leftColor: CGColor
        let rightColor: CGColor

        if temperature >= 30 {
            // color for temperatures 30 and above
            rightColor = UIColor(red: 241/255, green: 221/255, blue: 83/255, alpha: 1.0).cgColor // Adjusted yellow
            leftColor = UIColor(red: 219/255, green: 186/255, blue: 116/255, alpha: 1.0).cgColor //  DBBA74
        } else {
            // color for temperatures below 30
            leftColor = UIColor(red: 100/255, green: 118/255, blue: 195/255, alpha: 1.0).cgColor
            rightColor = UIColor(red: 117/255, green: 184/255, blue: 242/255, alpha: 1.0).cgColor
        }
        
        weatherBackgroundView.applyGradient(colors: [leftColor, rightColor])
    }

    func setupViews() {
        goToWeatherControllerButton.corener(by: 15)
        formatDate(Date())
    }

    func configureLocationAccess() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    func setupActivityIndicator(){
        let frame = CGRect(x: (self.view.frame.width / 2) - 25, y: (self.view.frame.height / 2), width: 50, height: 50)
        activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballPulseSync, color: .plantieGreen, padding: 0)
        self.view.addSubview(activityIndicator!)
    }
    
    func showActivityIndicator(){
        activityIndicator?.startAnimating()
    }
    func hideActivityIndicator(){
        activityIndicator?.stopAnimating()
    }
}

// MARK: Core Location

extension PlantsViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            getWeatherData { _ in } // Call getWeatherData when location access is granted
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        getWeatherData { _ in }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        ProgressHUD.error("يرجى السماح بالوصول إلى الموقع للحصول على معلومات الطقس.")
    }
}

extension PlantsViewController {

    func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        backButton.title = "رجوع"
        self.navigationItem.backBarButtonItem = backButton
    }

    func getWeatherData(completion: @escaping (Bool) -> Void) {
        
        guard let location = locationManager.location else {
            completion(false)
            return // Exit if location is not available
        }
        
        if !Reachability.isConnectedToNetwork() {
            // Display an alert if there's no internet connection
            ProgressHUD.banner("لا يوجد اتصال بالإنترنت", "يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.", delay: 2.0)
            return
        }
        
        self.showActivityIndicator()
        
        WeatherAPI.getWeatherData(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    completion(false)
                }
                return // Exit if weather data is not available
            }
            
            let decoder = JSONDecoder()
            do {
                let weatherData = try decoder.decode(WeatherData.self, from: data)
                
                // Store weather data for later use
                self.weatherData = weatherData
                
                DispatchQueue.main.async {
                    let temperature = (weatherData.current.temp - 32) * 5 / 9
                    self.adviceWeatherState.text = self.getWeatherAdvice(for: temperature)
                    self.adviceWeatherStateHightConstrain.constant = 70
                    self.currentCityLabel.text = weatherData.timezone
                    self.tempretureLabel.text = "\(Int(temperature))°C"
                    self.weatherStateLabel.text = weatherData.current.weather[0].weatherDescription
                    
                    // Update the background color based on the temperature
                    self.updateBackgroundColor(for: temperature)
                    // Update the weather image based on the description
                    self.updateWeatherImage(for: weatherData.current.weather[0].weatherDescription)
                    self.hideActivityIndicator()
                    completion(true)
                }
                
            } catch {
                print("Failed to decode weather data: \(error)")
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    completion(false)
                }
            }
        }
    }
}
