import UIKit
import SwiftLocation
import CoreLocation

class PlantsViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var weatherBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var tempretureLabel: UILabel!
    @IBOutlet weak var getUserLocationButton: UIButton!
    
    // MARK: Variables
    var plants:[Plant] = []
    var locationManager = CLLocationManager()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTime()
        
        locationManager.delegate = self
        setupTableView()
        getPlants()
    }
    
    // MARK: Actions
    
    @IBAction func getUserLocation(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: Methods
    
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
    
    func setTime(){
        historyLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)

    }
}

// MARK: Core Location

extension PlantsViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        print(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        
    }
}
