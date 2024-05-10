

import UIKit

class PlantCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Cell Configuration
    func configureCell(imageName: String, diseaseName: String) {
        setUpCircleView()
        plantImageView.image = UIImage(named: imageName)
        diseaseNameLabel.text = diseaseName
    }
    
    // MARK: - SetUp Cell
    
    func setUpCircleView() {
        circleView.layer.cornerRadius = circleView.frame.size.width / 2
        circleView.clipsToBounds = true
        circleView.backgroundColor = UIColor.plantieGreen
        circleView.layer.borderWidth = 2.0
        circleView.layer.borderColor = UIColor.white.cgColor
    }
}
