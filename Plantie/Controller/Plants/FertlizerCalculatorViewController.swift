

import UIKit

class FertlizerCalculatorViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var NPKLabel: UILabel!
    @IBOutlet weak var numberOfPlantsLabel: UILabel!
    @IBOutlet weak var mopLabel: UILabel!
    @IBOutlet weak var ureaLabel: UILabel!
    @IBOutlet weak var sspLabel: UILabel!
    
    @IBOutlet weak var fertlizerCalculateButtonOutlet: UIButton!
    
    // MARK: Variabels
    
    var numberOfPlants = 0
    var plant: Plant!
    
    // MARK: Life Cycle Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    // MARK: Actions
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        self.numberOfPlants += 1
        self.updateNumOfPlantsLabel()
    }
    
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        self.numberOfPlants -= 1
        self.updateNumOfPlantsLabel()
    }
    
    @IBAction func calculateButtonTapped(_ sender: UIButton) {
    }
    
    // MARK: Methods
    
    func updateNumOfPlantsLabel(){
        self.numberOfPlantsLabel.text = String(numberOfPlants)
    }

    func setupUI(){
        self.plantNameLabel.text = plant.name
        self.plantImageView.image = UIImage(named: plant.imageName)
        self.fertlizerCalculateButtonOutlet.layer.cornerRadius = 15
        
    }

}
