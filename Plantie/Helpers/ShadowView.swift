
import UIKit

class ShadowView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShadow()
    }
    
    func setupShadow(){
        self.layer.shadowColor = UIColor.plantieGreen.cgColor
        self.layer.shadowOpacity = 0.43
        self.layer.shadowOffset = CGSize(width: 0, height: 15)
        self.layer.shadowRadius = 15
        self.layer.cornerRadius = 15
    }
    
}
