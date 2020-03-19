
import UIKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var loginFrontView: UIView!
    @IBOutlet weak var frontViewLabelJoeppie: UILabel!
    @IBOutlet weak var poweredby: UILabel!
    
    let touchMe = BiometricIDAuth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.poweredby.text = "Powered by"
        self.frontViewLabelJoeppie.text = "Bever Apps"
        loginFrontView.isHidden = false
        
        logInButton.layer.cornerRadius = 5
       
        
        
        usernameTextField.placeholder = NSLocalizedString("username_placeholder", comment: "")
        passwordTextField.placeholder = NSLocalizedString("password_placeholder", comment: "")
        logInButton.setTitle(NSLocalizedString("log_in_button", comment: ""), for: .normal)
        
        // TODO : Delete this
        usernameTextField.text = "benjamin123"
        passwordTextField.text = "joeppieBegeleider123"
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        

        //usernameTextField.text=""
        //passwordTextField.text=""
        checkForUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func checkForUser() {
        
        guard KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) != nil else {
            loginFrontView.isHidden = true
            return
        }
        
        self.touchMe.authenticateUser() { [weak self] message in
            DispatchQueue.main.async {
                if message != nil {
                    // if the completion is not nil show an alert
                    self!.loginFrontView.isHidden = true
                    
                } else {
                    UserService.getUser(withCompletionHandeler: { user in
                        guard let user = user else {
                            return
                        }
                        self!.launchNextScreen(forUser: user)
                        return
                        
                    })
                    
                }
                
            }
            
        }
        
    }
    
    private func launchNextScreen(forUser user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch user.role.id {
        case 4: //coach
            guard let controller = storyboard.instantiateViewController(withIdentifier:
                "PatientsTableViewController") as? PatientsTableViewController else {
                    fatalError("Unexpected destination:")
            }
            self.navigationController?.pushViewController(controller, animated: true)
        case 5: //patient
            guard let controller:TapBarController = storyboard.instantiateViewController(withIdentifier:
                "TapBarController") as? TapBarController else {
                    fatalError("Unexpected destination:")
            }
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            return
            
        }
        
    }
    
    
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        guard let identiefier = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if Reachability.isConnectedToNetwork(){
            ApiService.logUserIn(withIdentiefier: identiefier, andPassword: password).responseData(completionHandler: { response in
                guard let jsonData = response.data else { return }
                let decoder = JSONDecoder()
                let loginResponse = try? decoder.decode(LoginResponse.self, from: jsonData)
                print(loginResponse?.token)
                if loginResponse == nil{
                    Errorpopup.displayErrorMessage(vc: self, title: NSLocalizedString("login_error_title", comment: ""), msg: NSLocalizedString("login_error_msg", comment: ""))
                }else{
                    UserService.setUser(instance: loginResponse!.user)
                    KeychainWrapper.standard.set(loginResponse!.token, forKey: Constants.tokenIdentifier)
                    self.launchNextScreen(forUser: loginResponse!.user)
                }
            })
        }else{
            Errorpopup.displayConnectionErrorMessage(vc: self)
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

//Shahin - Textfield Delegate
extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            self.view.endEditing(true)
        }
        // Do not add a line break
        return false
    }
}
