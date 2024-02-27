
import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }


}

// MARK: Private Methods

private extension SplashViewController{
    
    func setupView(){
        registerButton.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
    }
}


