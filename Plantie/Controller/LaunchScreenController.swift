
import UIKit
import Lottie
import Firebase

class LaunchScreenController: UIViewController {
    
    // MARK: Variables
    
    var authListener : AuthStateDidChangeListenerHandle?

    // MARK: - Outlets
    
    @IBOutlet weak var animationView: LottieAnimationView!
    
    // MARK: - Life Cycle Controller
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUpAnimation()
        
    }
    
    // MARK: - Methods
    
    func setUpAnimation(){
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
//        animationView.animationSpeed = 2
        animationView.play { _ in
            self.transitionToMain()
        }
    }
    
    func transitionToMain() {
        
        // Go To Main StoryBoard
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController(),
            let window = windowScene.windows.first {
            window.rootViewController = mainViewController
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Get the relevant window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // Access the windows property on the window scene
            if let window = windowScene.windows.first {
                // if user is logged in before

                authListener = Auth.auth().addStateDidChangeListener({ auth, user in
                    Auth.auth().removeStateDidChangeListener(self.authListener!)
                    
                    if user != nil && UserDefaults.standard.object(forKey: kCURRENTUSER) != nil{
                        
                            // instantiate the main tab bar controller and set it as root view controller
                            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                            window.rootViewController = mainTabBarController

                      
                    }
                    
                    else{
                        
                        // if user isn't logged in
                        // instantiate the navigation controller and set it as root view controller
                        let loginNavController = storyboard.instantiateViewController(identifier: "SplashView")
                        window.rootViewController = loginNavController
                        
                    }
                    
                })
                
                
            }
        }
    }
    

}

