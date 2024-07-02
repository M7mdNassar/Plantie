
import UIKit

class FertlizerCalculatorViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var NPKLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var mopLabel: UILabel!
    @IBOutlet weak var ureaLabel: UILabel!
    @IBOutlet weak var sspLabel: UILabel!
    @IBOutlet weak var fertlizerCalculateButtonOutlet: UIButton!
    @IBOutlet weak var resultStackView: UIStackView!
    
    // MARK: Variabels
    
    var area = 0
    var plant: Plant!
    
    // MARK: Life Cycle Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    // MARK: Actions
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        self.area += 1
        self.updateNumOfPlantsLabel()
    }
    
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        self.area -= 1
        self.updateNumOfPlantsLabel()
    }
    
    @IBAction func calculateButtonTapped(_ sender: UIButton) {
        calculateFertilizer()
        self.resultStackView.isHidden = false
    }
    
    // MARK: Methods
    
    func updateNumOfPlantsLabel(){
        if self.area < 0 {
            self.area = 0
        }
        self.areaLabel.text = String(area)
    }

    func setupUI(){
        self.plantNameLabel.text = plant.name
        self.NPKLabel.text = plant.npk
        self.plantImageView.image = UIImage(named: plant.imageName)
        self.fertlizerCalculateButtonOutlet.layer.cornerRadius = 15
    }

    func calculateFertilizer() {
           guard let npkString = plant?.npk else { return }
           let npkValues = npkString.split(separator: "-").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
           if npkValues.count == 3 {
               let fertilizerAmounts = calculateUMSFertilizer(N: npkValues[0], P: npkValues[1], K: npkValues[2])
               let areaFactor = Double(area)
               
               self.ureaLabel.text = String(format: "%.2f kg", fertilizerAmounts["Urea"]! * areaFactor)
               self.sspLabel.text = String(format: "%.2f kg", fertilizerAmounts["SSP"]! * areaFactor)
               self.mopLabel.text = String(format: "%.2f kg", fertilizerAmounts["MOP"]! * areaFactor)
           }
       }
       
       func calculateUMSFertilizer(N: Int, P: Int, K: Int) -> [String: Double] {
           let amountOfUrea = (100.0 * Double(N)) / 46.0
           let amountOfSSP = (100.0 * Double(P)) / 16.0
           let amountOfMOP = (100.0 * Double(K)) / 60.0
           return [
               "Urea": amountOfUrea,
               "SSP": amountOfSSP,
               "MOP": amountOfMOP
           ]
       }
}
