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
    @IBOutlet weak var areaOrNumberOfPlantsLabel: UILabel!
    
    // MARK: Variables
    
    var plant: Plant!
    var isFruit: Bool {
        return plant.category == "فواكه"
    }
    var currentValue: Double = 0 {
        didSet {
            areaLabel.text = "\(Int(currentValue))"
        }
    }
    
    // MARK: Life Cycle Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: Actions
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        currentValue += 1
    }
    
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        if currentValue > 0 {
            currentValue -= 1
        }
    }
    
    @IBAction func calculateButtonTapped(_ sender: UIButton) {
        let npkComponents = plant.npk.split(separator: "-").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard npkComponents.count == 3 else {
            // Handle invalid NPK format
            return
        }
        
        let fertilizerAmounts: [String: Double]
        
        if isFruit {
            fertilizerAmounts = calculateFertilizerUMS(npk: npkComponents, numberOfPlants: currentValue)
        } else {
            // Adjust the current value for area calculation for vegetables
            let adjustedArea = currentValue * 10
            fertilizerAmounts = calculateFertilizerUDM(npk: npkComponents, area: adjustedArea)
        }
        
        updateUI(with: fertilizerAmounts)
        resultStackView.isHidden = false
    }
    
    // MARK: Methods
    
    func setupUI() {
        plantNameLabel.text = plant.name
        NPKLabel.text = plant.npk
        plantImageView.image = UIImage(named: plant.imageName)
        fertlizerCalculateButtonOutlet.layer.cornerRadius = 15
        areaOrNumberOfPlantsLabel.text = isFruit ? "عدد الأشجار لديك؟" : "كم المساحة بالمتر مربع؟"
        areaLabel.text = "\(Int(currentValue))"
        resultStackView.isHidden = true
    }
    
    func updateUI(with fertilizerAmounts: [String: Double]) {
        ureaLabel.text = "Urea: \(String(format: "%.2f", fertilizerAmounts["Urea"] ?? 0)) kg"
        mopLabel.text = "MOP: \(String(format: "%.2f", fertilizerAmounts["MOP"] ?? 0)) kg"
        sspLabel.text = isFruit ? "SSP: \(String(format: "%.2f", fertilizerAmounts["SSP"] ?? 0)) kg" : "DAP: \(String(format: "%.2f", fertilizerAmounts["DAP"] ?? 0)) kg"
    }
    
    func calculateFertilizerUMS(npk: [Double], numberOfPlants: Double) -> [String: Double] {
        let amountOfUrea = (100 * npk[0]) / 46 * numberOfPlants
        let amountOfSSP = (100 * npk[1]) / 16 * numberOfPlants
        let amountOfMOP = (100 * npk[2]) / 60 * numberOfPlants
        return ["Urea": amountOfUrea, "SSP": amountOfSSP, "MOP": amountOfMOP]
    }
    
    func calculateFertilizerUDM(npk: [Double], area: Double) -> [String: Double] {
        let areaFactor = area / 100 // Adjusting for 100m² as the base area
        
        // Amount of DAP needed for phosphorus (P)
        let amountOfDAP_P = (100 * npk[1]) / 46 * areaFactor
        let amountOfDAP_N = (amountOfDAP_P * 18) / 46 // Correct DAP contains 18% N
        let totalNitrogen = npk[0] * areaFactor // Total nitrogen required
        let amountOfUrea_N = totalNitrogen - amountOfDAP_N // Remaining nitrogen needed from Urea
        let amountOfUrea = (amountOfUrea_N > 0) ? (100 * amountOfUrea_N) / 46 : 0 // Ensure no negative value
        
        let amountOfMOP = (100 * npk[2]) / 60 * areaFactor
        return ["Urea": amountOfUrea, "DAP": amountOfDAP_P, "MOP": amountOfMOP]
    }
}
