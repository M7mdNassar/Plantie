import UIKit
import SwiftLocation
import CoreLocation
import ProgressHUD
class PlantsViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var weatherBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var goToWeatherControllerButton: UIButton!
    
    // MARK: Variables
    var plants:[Plant] = []
    var locationManager = CLLocationManager()
    var data: Plant?
    
    var weatherData: WeatherData?
    
    let backButton = UIBarButtonItem()

    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        configureLocationAccess()
        setupTableView()
        getPlants()
        getWeatherData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    // MARK: Actions
    
    @IBAction func goToWeatherController(_ sender: UIButton) {
    
        if locationManager.authorizationStatus == .authorizedWhenInUse {
              // If location access is granted, navigate to weather controller
              navigateToWeatherViewController()
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
}

// MARK: Table Datasource

extension PlantsViewController: UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue() as PlantTableViewCell
        cell.configure(plant:plants[indexPath.row])
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
private extension PlantsViewController{
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(Cell: PlantTableViewCell.self)
    }
    
    func getPlants(){
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
    
     func setupGradient() {
      
        let rightColor = UIColor(red: 241/255, green: 221/255, blue: 83/255, alpha: 1.0).cgColor // Adjusted yellow
              let leftColor = UIColor(red: 219/255, green: 186/255, blue: 116/255, alpha: 1.0).cgColor // DBBA74 DBBA74
        weatherBackgroundView.applyGradient(colors: [rightColor, leftColor])
      }
    func setupViews(){
        
        setupGradient()
        goToWeatherControllerButton.corener(by: 15)
        formatDate(Date())
    }
    
    func configureLocationAccess(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()

    }
    
}

// MARK: Core Location

extension PlantsViewController: CLLocationManagerDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            getWeatherData() // Call getWeatherData when location access is granted
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        getWeatherData()
    }
   
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        ProgressHUD.error("يرجى السماح بالوصول إلى الموقع للحصول على معلومات الطقس.")
        
     
    }
}


extension PlantsViewController{

    func setupNavigationBar(){
        self.navigationController?.navigationBar.isHidden = true
        backButton.title = "رجوع"
        self.navigationItem.backBarButtonItem = backButton
    }
    
    func getWeatherData() {
      
        guard let location = locationManager.location else {
            return // Exit if location is not available
        }
        
        WeatherAPI.getWeatherData(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { [weak self] data, response, error in
            guard let self = self else { return }
            
            guard let data = data else {
                return // Exit if weather data is not available
            }
            
            let decoder = JSONDecoder()
            do {
                let weatherData = try decoder.decode(WeatherData.self, from: data)

                // Store weather data for later use
                self.weatherData = weatherData
                
                DispatchQueue.main.async{
                    self.currentCityLabel.text = weatherData.timezone
                    self.tempretureLabel.text = "\(Int((weatherData.current.temp - 32) * 5 / 9))°C"
                    self.weatherDescription.text = weatherData.current.weather[0].weatherDescription
                }
                
               
            } catch {
                print("Failed to decode weather data: \(error)")
            }
        }
    }

    
}
