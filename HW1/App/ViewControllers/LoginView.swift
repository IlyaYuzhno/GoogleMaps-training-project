//
//  LoginView.swift
//  HW1
//
//  Created by Ilya Doroshkevitch on 05.04.2021.
//

import UIKit
import RxCocoa
import RxSwift

protocol LoginViewDelegate: class {
    func loginButtonPressed(sender: UIButton)
    func registerButtonPressed(sender: UIButton)
}

class LoginView: UIView {

    // MARK: - Init
     override init(frame: CGRect) {
         super.init(frame: frame)

         setupViews()
         setupConstraints()
         configureLoginBindings()
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

     // MARK: - Public

     // Vars
     weak var delegate: LoginViewDelegate?

     // Title label
     lazy var registerTitleLabel: UILabel = {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.text = "PLEASE LOGIN OR REGISTER:"
         label.font = .boldSystemFont(ofSize: 24)
         label.textAlignment = .center
         return label
     }()

     // Username
     lazy var usernameLabel: UILabel = {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.text = "Enter username:"
         label.font = .boldSystemFont(ofSize: 22)
         label.textAlignment = .center
         return label
     }()

     lazy var usernameTextField: UITextField = {
         let textField = UITextField()
         textField.translatesAutoresizingMaskIntoConstraints = false
         textField.backgroundColor = .white
         textField.layer.cornerRadius = 6
         textField.autocorrectionType = .no
         return textField
     }()

     // Password
     lazy var passwordLabel: UILabel = {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.text = "Enter password:"
         label.font = .boldSystemFont(ofSize: 22)
         label.textAlignment = .center
         return label
     }()

    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 6
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        return textField
    }()

    // Login Button
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LOGIN", for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 6
        button.accessibilityIdentifier = "loginButton"
        button.addTarget(self, action: #selector(self.loginButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()

    // Register Button
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("REGISTER", for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 6
        button.accessibilityIdentifier = "registerButton"
        button.addTarget(self, action: #selector(self.registerButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()

    // MARK: Add Subviews
    func setupViews() {
        backgroundColor = .systemGray
        addSubviews (registerTitleLabel, usernameLabel, usernameTextField, passwordLabel, passwordTextField, loginButton, registerButton)
    }

    // MARK: - Private
    private func setupConstraints() {
        NSLayoutConstraint .activate([

            registerTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            registerTitleLabel.widthAnchor.constraint(equalTo: widthAnchor),
            registerTitleLabel.heightAnchor.constraint(equalToConstant: 50),
            registerTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            usernameLabel.topAnchor.constraint(equalTo: registerTitleLabel.bottomAnchor, constant: 20),
            usernameLabel.widthAnchor.constraint(equalTo: widthAnchor),
            usernameLabel.heightAnchor.constraint(equalToConstant: 50),
            usernameLabel.centerXAnchor.constraint(equalTo: registerTitleLabel.centerXAnchor),

            usernameTextField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
            usernameTextField.widthAnchor.constraint(equalTo: widthAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40),
            usernameTextField.centerXAnchor.constraint(equalTo: registerTitleLabel.centerXAnchor),

            passwordLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 40),
            passwordLabel.widthAnchor.constraint(equalTo: widthAnchor),
            passwordLabel.heightAnchor.constraint(equalTo: usernameLabel.heightAnchor),
            passwordLabel.centerXAnchor.constraint(equalTo: registerTitleLabel.centerXAnchor),

            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: widthAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalTo: usernameTextField.heightAnchor),
            passwordTextField.centerXAnchor.constraint(equalTo: registerTitleLabel.centerXAnchor),

            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            loginButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            loginButton.widthAnchor.constraint(equalToConstant: 180),
            loginButton.heightAnchor.constraint(equalToConstant: 60),

            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            registerButton.leadingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: 10),
            registerButton.widthAnchor.constraint(equalTo: loginButton.widthAnchor),
            registerButton.heightAnchor.constraint(equalTo: loginButton.heightAnchor)

        ])

    }

    // MARK: - Register Button pressed method
    @objc func registerButtonPressed(sender: UIButton) {
        delegate?.registerButtonPressed(sender: sender)
    }

    @objc func loginButtonPressed(sender: UIButton) {
        delegate?.loginButtonPressed(sender: sender)
    }


}

// MARK: - RxSwift methods extension
extension LoginView {
    func configureLoginBindings() {
            Observable
    // Объединяем два обсервера в один
                .combineLatest(
    // Обсервер изменения текста
                    usernameTextField.rx.text,
    // Обсервер изменения текста
                    passwordTextField.rx.text
                )
    // Модифицируем значения из двух обсерверов в один
                .map { login, password in
    // Если введены логин и пароль больше 6 символов, будет возвращено “истина”
                    return !(login ?? "").isEmpty && (password ?? "").count >= 6
                }
    // Подписываемся на получение событий
                .bind { [weak loginButton] inputFilled in
    // Если событие означает успех, активируем кнопку, иначе деактивируем
                    switch inputFilled {
                    case true:
                        loginButton?.isEnabled = inputFilled
                        loginButton?.backgroundColor = .green
                    case false:
                        loginButton?.isEnabled = inputFilled
                        loginButton?.backgroundColor = .lightGray
                    }
            }
        }


}

public extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
