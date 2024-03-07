

import UIKit
import SDWebImage

class ImagesPostCollectionViewCell: UICollectionViewCell {

    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Methods
    func configure(imageUrl: String) {
        self.imageView.layer.cornerRadius = 20
        self.imageView.layer.masksToBounds = true
        
        
        if imageUrl != ""{
            self.imageView.sd_setImage(with: URL(string: imageUrl))
           
        }
        
    }

}
