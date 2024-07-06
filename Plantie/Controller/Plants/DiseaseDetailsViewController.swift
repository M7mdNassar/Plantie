import UIKit
import SDWebImage

class DiseaseDetailsViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var diseaseImageView: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var diseaseDescriptionLabel: UILabel!
    @IBOutlet weak var diseasePreventionLabel: UILabel!
    
    // MARK: Variables
    var diseaseName: String?
    var diseaseImageURL: String?
    var diseaseDescription: String?
    var diseasePrevention: String?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    // MARK: Methods
    func configureView() {
        diseaseNameLabel.text = diseaseName
        diseaseDescriptionLabel.text = diseaseDescription
        diseasePreventionLabel.text = diseasePrevention
        if let imageURL = diseaseImageURL, let url = URL(string: imageURL) {
                  diseaseImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
              }
    }
}
