//
//  LoginViewController.swift
//  HW1
//
//  Created by Ilya Doroshkevitch on 05.04.2021.
//
import UIKit

class LoginViewController: UIViewController {

    let service = RealmService()
    let router = Router()
    lazy var loginView = LoginView(frame: CGRect(
                            x: 0,
                            y: 0,
                            width: view.safeAreaLayoutGuide.layoutFrame.size.width,
                            height: view.bounds.height - 100))

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.delegate = self
        service.delegate = self
        view.addSubview(loginView)

        NotificationCenter.default.addObserver(self, selector: #selector(setBlur), name: Notification.Name("sceneWillResignActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeBlur), name: Notification.Name("sceneDidBecomeActive"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Extensions
extension LoginViewController: LoginViewDelegate {
     func loginButtonPressed(sender: UIButton) {
         guard
             let login = loginView.usernameTextField.text,
             let password = loginView.passwordTextField.text
         else { return }

         service.checkLogin(login: login, password: password)
     }

     func registerButtonPressed(sender: UIButton) {
         guard
             let login = loginView.usernameTextField.text,
             let password = loginView.passwordTextField.text
         else { return }

         service.registerUser(login: login, password: password)
     }
}


extension LoginViewController: RealmServiceDelegate {
    func registerSuccess() {
        showAlert(message: "Register Success!", buttonTitle: "Please login now")
    }

    func passwordChanged() {
        showAlert(message: "Password has been changed", buttonTitle: "OK")
    }

    func noSuchLoginExists() {
        showAlert(message: "No such login exists", buttonTitle: "Please register")
    }

    func passwordIsIncorrect() {
        showAlert(message: "Password is incorrect", buttonTitle: "Enter again")
        loginView.passwordTextField.text = ""
    }

    func goToMainViewController() {
        router.goTo(from: self, to: MainViewController())
    }

}


extension LoginViewController {

    func showAlert(message: String, buttonTitle: String) {
        let alert = UIAlertController(title: "Внимание!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .destructive, handler: {  action in

        }))
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController {

    @objc private func setBlur() {
        Blur.setBlur(view: self.view)
    }

    @objc private func removeBlur() {
        Blur.removeBlur()
    }

}

