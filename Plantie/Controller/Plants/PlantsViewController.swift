
import UIKit

class PlantsViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var weatherBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    
    var plants:[Plant] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getPlants()
        
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
}
