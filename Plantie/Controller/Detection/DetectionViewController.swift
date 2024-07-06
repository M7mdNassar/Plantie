import UIKit
import Vision
import CoreML

class DetectionViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var treatmentNameLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var getPlantStoreButton: UIButton!
    @IBOutlet weak var plantImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultsStackLabelsConstraint: NSLayoutConstraint!
    @IBOutlet weak var tipsStackTopConstraint: NSLayoutConstraint!
    
    // MARK: Variables
    var imageClassifier: ImageClassifier = MLImageClassifier(model: try! VNCoreMLModel(for: PlantieML().model))
    var selectedImage: UIImage? {
        didSet {
            if let image = selectedImage {
                classifyImage(image: image)
            }
        }
    }
    
    let backButton = UIBarButtonItem()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
    }
    
    // MARK: Actions
    @IBAction func getPlantStoreButtonTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func classifyImage(image: UIImage) {
           imageClassifier.classify(image: image) { [weak self] identifier in
               guard let self = self else { return }
               DispatchQueue.main.async {
                   self.plantImageViewHeightConstraint.constant = 250
                   self.resultsStackLabelsConstraint.constant = 110
                   
                   self.tipsStackTopConstraint.constant = 10

                   self.plantImageView.image = self.selectedImage
                   self.updateLabels(disease: identifier!)
               }
           }
       }

    private func updateLabels(disease: String) {
        if let info = DiseaseInfo.data[disease] {
            self.diseaseNameLabel.text = info.name
            self.treatmentNameLabel.text = info.treatment == "" ? "لا تحتاج الى مبيدات":info.treatment
            self.tipsLabel.text = info.tips
        } else {
            self.diseaseNameLabel.text = "غير معروف"
            self.treatmentNameLabel.text = "غير معروف"
            self.tipsLabel.text = "غير معروف"
        }
    }
}

// MARK: - UI Setup
private extension DetectionViewController {
     func setupViews() {
        getPlantStoreButton.layer.cornerRadius = 17
    }
    
    func setupNavigationBar(){
        self.backButton.title = "رجوع"
        self.backButton.tintColor = .plantieGreen
        self.navigationItem.backBarButtonItem = backButton
    }
    
    
}
