import UIKit
import IQKeyboardManagerSwift
import ProgressHUD

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
