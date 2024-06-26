import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import ProgressHUD


class RegisterViewController: UIViewController {
    
    // MARK: Outlets
    //Labels
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    //TextFields
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    //Buttons
    @IBOutlet weak var registerButtonOutlet: UIButton!
    
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
    
    @IBAction func registerButton(_ sender: UIButton) {
        if isInputDataValid(mode: "register"){
            
            registerUser()
            
        }
        else{
            ProgressHUD.error("All Fields requierd")
            
        }
    }
    
    
    
    
    @IBAction func resendEmailButton(_ sender: UIButton) {
        
        resendEmailVerfication()
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            // Present the LoginViewController
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
        
    }
    
    
    @IBAction func googleSignUpButton(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
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
                
                if (authResult?.user) != nil {
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
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                        
                    }
                }
            }
        }
        
    }
    
    
    @IBAction func facebookSignupButton(_ sender: UIButton) {
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


    
 
    
    // MARK: Methods
    
    func setupLabels(){
        userNameLabel.text = ""
        emailLabel.text = ""
        passwordLabel.text = ""
        confirmPasswordLabel.text = ""
    }
    
    private func configureLeftBarButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector (backButtonPressed))
    }
    
    @objc func backButtonPressed(){
        navigationController?.popViewController(animated: true)
    }
    
    func configureTextFields(){
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordField.delegate = self
        
        self.userNameTextField.layer.cornerRadius = 15
        self.userNameTextField.layer.masksToBounds = true
        self.emailTextField.layer.cornerRadius = 15
        self.emailTextField.layer.masksToBounds = true
        self.passwordTextField.layer.cornerRadius = 15
        self.passwordTextField.layer.masksToBounds = true
        self.confirmPasswordField.layer.cornerRadius = 15
        self.confirmPasswordField.layer.masksToBounds = true
    }
    
    
    func resendEmailVerfication(){
        
        FUserListener.shared.resendVerficationEmailWith(email: emailTextField.text!) { error in
            if error == nil{
                ProgressHUD.succeed("Verfication Email Send :)")
            }
            else{
                ProgressHUD.error(error?.localizedDescription)
            }
        }
    }
    
    // MARK: Helpers
    
    func isInputDataValid (mode: String) -> Bool{
        
        switch (mode)
        {
            
        case "register":
            return userNameTextField.hasText && emailTextField.hasText && passwordTextField.hasText && confirmPasswordField.hasText
            
            
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
    
    func registerUser(){
        if passwordTextField.text == confirmPasswordField.text{
            FUserListener.shared.registerUserWith(userName : userNameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!) { error in
                
                if error == nil{
                    ProgressHUD.success("Verification Email Sent , please check you email :)")
                }else {
                    ProgressHUD.error(error?.localizedDescription)
                }
            }
        }else {
            ProgressHUD.error("Not matching in Password")
        }
    }
    
    
    // MARK: - Set Up UI
    private func setUpBackground() {
        self.registerButtonOutlet.layer.cornerRadius = 20
        
    }
}


// MARK: UITextFieldDelegate

extension RegisterViewController : UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        userNameLabel.text = userNameTextField.hasText ? "Email" : ""
        emailLabel.text = emailTextField.hasText ? "Email" : ""
        passwordLabel.text = passwordTextField.hasText ? "Password" : ""
        confirmPasswordLabel.text = confirmPasswordField.hasText ? "Confirm Password" : ""
    }
    
}


