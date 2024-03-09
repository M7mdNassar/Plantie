import UIKit
import ProgressHUD


class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var contentView: ShadowView!
    @IBOutlet weak var headertView: ShadowView!
    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    // MARK: - Variables
    
    let backButton = UIBarButtonItem()
    
    // MARK: - Life Cycle Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        PlaceholderForImage()
        configureNavigationBar()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = UIColor.tertiarySystemGroupedBackground
        setupUI()
    }
    
    
    // MARK: Actions
    
    @IBAction func updateUserInfoButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goToEdit", sender: self)

    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
        logout()
    }
    func setupUI(){
        setUpFont()
        setShadowAroundImage()
        
        if let user = User.currentUser{
            
            self.userNameLabel.text = user.userName
            
            if user.avatarLink != ""{
                FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
                    self.userImageView.image = avatarImage?.circleMasked
                }
            }
            
        }
    }
    
  
    
    // MARK: - Methods
    
    func configureNavigationBar() {
        backButton.title = NSLocalizedString("رجوع", comment: "")
        self.navigationItem.backBarButtonItem = backButton
        let scaledFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: UIFont.labelFontSize))
        backButton.setTitleTextAttributes([.font: scaledFont], for: .normal)

    }
    
    func configureTabBar() {
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("Profile", comment: ""), image: UIImage(systemName: "person.crop.circle.fill"), selectedImage: nil)
        if let tabBarItem = self.tabBarItem {
            let scaledFont = UIFont.systemFont(ofSize: UIFont.labelFontSize).withSize(12.0)
            tabBarItem.setTitleTextAttributes([.font: scaledFont], for: .normal)
        }
    }
    
 
    
    func logout() {
        let alert = UIAlertController(title: "تسجيل الخروج", message:"هل أنت متأكد أنك تريد تسجيل الخروج؟", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "إلغاء", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "تسجيل الخروج", style: .destructive, handler: { action in
            // Perform logout actions
            
            
            FUserListener.shared.logoutUser { error in
                
                if error == nil{
                    let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SplashView")
                    
                    loginView.modalPresentationStyle = .fullScreen
                    
                    DispatchQueue.main.async {
                        self.present(loginView, animated: true)
                    }
                }
                else{
                    ProgressHUD.error(error?.localizedDescription)
                }
                
            }
            
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    
}



// MARK: - Private Methods For UI

private extension ProfileViewController {
    
    func PlaceholderForImage() {
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.layer.borderWidth = 4.0
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.clipsToBounds = true
        
        circleView.layer.cornerRadius = circleView.frame.size.width / 2
        circleView.clipsToBounds = true
        circleView.clipsToBounds = false
    }
    
    func setShadowAroundImage() {
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOpacity = 0.7
        circleView.layer.shadowOffset = CGSize.zero
        circleView.layer.shadowRadius = 7
    }
    
    func setUpFont() {
        let maximumFontSize: CGFloat = 40.0
        if let customFont = UIFont(name: "Harmattan-Bold", size: 28.0) {
            let scaledFont = UIFontMetrics.default.scaledFont(for: customFont)
            userNameLabel.font = scaledFont.withSize(min(scaledFont.pointSize, maximumFontSize))
        }
    }
    
    func setupView(){
        updateProfileButton.layer.cornerRadius = 15
        logoutButton.layer.cornerRadius = 15
    }
}


