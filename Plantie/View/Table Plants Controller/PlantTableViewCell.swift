
import UIKit

class PlantTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var plantNameLabel: UILabel!
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    
    func configure(plant:Plant){
        self.plantImageView.image = UIImage(named: plant.imageName)
        self.plantNameLabel.text = plant.name
    }
    
}
