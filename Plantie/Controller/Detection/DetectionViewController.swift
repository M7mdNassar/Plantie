import UIKit
import Vision
import CoreML

class DetectionViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    
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
