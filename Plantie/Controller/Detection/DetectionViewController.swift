import UIKit
import Vision
import CoreML

class DetectionViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var treatmentNameLabel: UILabel!
    @IBOutlet weak var getPlantStoreButton: UIButton!
    @IBOutlet weak var plantImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultsStackLabelsConstraint: NSLayoutConstraint!
    @IBOutlet weak var getPlantStoreButtonTopConstraint: NSLayoutConstraint!
    
    // MARK: Variables
    var imageClassifier: ImageClassifier = MLImageClassifier(model: try! VNCoreMLModel(for: PlantieML().model))
    var selectedImage: UIImage? {
        didSet {
            if let image = selectedImage {
                classifyImage(image: image)
            }
        }
    }
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
                   self.resultsStackLabelsConstraint.constant = 120
                   self.getPlantStoreButtonTopConstraint.constant = 300

                   self.plantImageView.image = self.selectedImage
                   self.updateLabels(disease: identifier!)
               }
           }
       }

    private func updateLabels(disease: String) {
        if let info = DiseaseInfo.data[disease] {
            self.diseaseNameLabel.text = info.name
            self.treatmentNameLabel.text = info.treatment
        } else {
            self.diseaseNameLabel.text = "Unknown"
            self.treatmentNameLabel.text = "No treatment available."
        }
    }
}

// MARK: - UI Setup
extension DetectionViewController {
    private func setupViews() {
        getPlantStoreButton.layer.cornerRadius = 17
    }
}