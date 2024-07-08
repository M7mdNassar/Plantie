
import UIKit

class PlantTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var plantNameLabel: UILabel!
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }
    override func prepareForReuse() {
         super.prepareForReuse()
        self.plantNameLabel.text = nil
        self.plantImageView.image = nil
     }

    
    func configure(plant:Plant){
        self.plantImageView.image = UIImage(named: plant.imageName)
        self.plantNameLabel.text = plant.name
    }
    
}
