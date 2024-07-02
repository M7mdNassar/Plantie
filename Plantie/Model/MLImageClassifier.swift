import UIKit
import Vision
import Foundation


protocol ImageClassifier {
    func classify(image: UIImage, completion: @escaping (String?) -> Void)
}


class MLImageClassifier: ImageClassifier {
    private let model: VNCoreMLModel
    
    init(model: VNCoreMLModel) {
        self.model = model
    }
    
    func classify(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                  let firstResult = results.first else {
                completion(nil)
                return
            }
            completion(firstResult.identifier)
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
                completion(nil)
            }
        }
    }
}

