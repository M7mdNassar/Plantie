import UIKit
import Vision
import CoreML

class DetectionViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var treatmentNameLabel: UILabel!
    @IBOutlet weak var getPlantStoreButton: UIButton!
    @IBOutlet weak var plantImageViewHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var resultsStackLabelsConstrain: NSLayoutConstraint!
    @IBOutlet weak var getPlantStoreButtonTopConstrain: NSLayoutConstraint!
    
    // MARK: Variables
    let model = try! VNCoreMLModel(for: PlantieML().model)
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

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    
    func classifyImage(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create CIImage from UIImage")
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }

            if let firstResult = results.first {
                DispatchQueue.main.async {
                    self.plantImageViewHeightConstrain.constant = 250
                    self.resultsStackLabelsConstrain.constant = 120
                    self.getPlantStoreButtonTopConstrain.constant = 300
                    
                    self.plantImageView.image = self.selectedImage
                    self.diseaseNameLabel.text = firstResult.identifier
                }
               
                print("Classification: \(firstResult.identifier), Confidence: \(firstResult.confidence)")
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
}

extension DetectionViewController{
    
    func setupViews(){
        self.getPlantStoreButton.layer.cornerRadius = 17
    }
    
}
