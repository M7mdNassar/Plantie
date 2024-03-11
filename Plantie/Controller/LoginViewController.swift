import UIKit
import FirebaseAuth
import FirebaseCore
import IQKeyboardManagerSwift
import ProgressHUD
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    // MARK: Outlets
    //Labels
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    //TextFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Buttons
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackground()
        setupLabels()
        configureLeftBarButton()
        configureTextFields()
        setupBackgroundGesture()
    }
    
    // MARK: Actions
    
    @IBAction func loginButton(_ sender: UIButton) {
        if isInputDataValid(mode: "login"){
            
            loginUser()
           
        }
        else{
            ProgressHUD.error("All Fields requierd")
            
        }
    }
    
    @IBAction func forgetPasswordButton(_ sender: UIButton) {
        if isInputDataValid(mode: "forgetPassword"){
            
            forgetPassword()
        }
        else{
            ProgressHUD.error("All Fields requierd")
        }
    }
    
    
    @IBAction func googleSignButton(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                // Handle sign-in error
                print("Google Sign-In Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            guard let user = result?.user,
              let idToken = user.idToken?.tokenString
            else {
              return
            }

           
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            // Use the credential to sign in with Firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In Error: \(error.localizedDescription)")
                    return
                }
                
                // Firebase sign-in successful, handle further actions if needed
                
                if let user = authResult?.user {
                    if let user = authResult?.user {
                        let newUser = User(
                            id: user.uid,
                            userName: user.displayName ?? "",
                            email: user.email ?? "",
                            pushId: "",
                            avatarLink: user.photoURL?.absoluteString ?? "",
                            bio: "",
                            country: ""
                        )
                        
                        FUserListener.shared.saveUserToFierbase(user: newUser)
                        saveUserLocally(user: newUser)
                        
                        // Proceed to the main app interface
                        self.goToApp()
                        
                    }
                }
            }
        }
    }

    
    
    @IBAction func facebookSigninButton(_ sender: UIButton) {
        
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Facebook login error: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token.")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Facebook authentication with Firebase error: \(error.localizedDescription)")
                    return
                }
                print("Facebook login success!")
                
                // Create user object
                if let user = authResult?.user {
                    let email = user.email ?? "" // Ensure email is not nil
                    let newUser = User(
                        id: user.uid,
                        userName: user.displayName ?? "",
                        email: email,
                        pushId: "",
                        avatarLink: user.photoURL?.absoluteString ?? "",
                        bio: "",
                        country: ""
                    )
                    
                    // Save user to Firestore and locally
                    FUserListener.shared.saveUserToFierbase(user: newUser)
                    saveUserLocally(user: newUser)
                    
                    // Proceed to the main app interface
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                }
            }
        }
    }
    
    
    
    
    @IBAction func registerButton(_ sender: UIButton) {
     
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
               if let loginVC = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
                   // Present the LoginViewController
                   self.navigationController?.pushViewController(loginVC, animated: true)
               }
        
    }
    
    

    // MARK: Helpers
    
    func isInputDataValid (mode: String) -> Bool{
        
        switch (mode)
        {
            
        case "login":
            return emailTextField.hasText && passwordTextField.hasText
            
        case "forgetPassword":
            return emailTextField.hasText
            
        default :
            return false
            
        }
    }
    
    // MARK: Background Tap Gesture
    
    func setupBackgroundGesture(){
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(false)
    }
    
    func loginUser(){
        FUserListener.shared.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { error, isEmailVerified in
            
            if error == nil{
                
                if isEmailVerified{
                    
                    self.goToApp()
                    
                }else{
                    ProgressHUD.failed("Please check you email to verify and complet registration")
                }
                
            }
            else{
                ProgressHUD.error(error?.localizedDescription)
            }
            
        }
        
    }
    
    func forgetPassword(){
        FUserListener.shared.resetPasswordFor(email: emailTextField.text!) { error in
            if error == nil{
                ProgressHUD.success("Email for reset your password has been sent !")
            }else{
                ProgressHUD.failed(error?.localizedDescription)
            }
        }
        
    }
    
    // Navigation to app
    
    func goToApp(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        
    }
    
    
    // MARK: - Set Up UI
    private func setUpBackground() {
        self.loginButtonOutlet.layer.cornerRadius = 20
        
    }
    
    
    // MARK: Methods
    
    func setupLabels(){
        emailLabel.text = ""
        passwordLabel.text = ""
    }
    
    private func configureLeftBarButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector (backButtonPressed))
    }
    
     @objc func backButtonPressed(){
        navigationController?.popViewController(animated: true)
    }
    
    
    func configureTextFields(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        self.emailTextField.layer.cornerRadius = 15
        self.emailTextField.layer.masksToBounds = true
        self.passwordTextField.layer.cornerRadius = 15
        self.passwordTextField.layer.masksToBounds = true
    }

}

// MARK: UITextFieldDelegate

extension LoginViewController : UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        emailLabel.text = emailTextField.hasText ? "Email" : ""
        passwordLabel.text = passwordTextField.hasText ? "Password" : ""

    }
    
}
