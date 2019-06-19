import UIKit
import TORoundedButton

/// Presents the user with an option to begin the authentication process and let the user know that
/// authentication is in process. We should only see this when we have either no access token or
/// an invalid one, since every other action requires authentication.
/// - Note: This ViewController needs a bit of love, but given that it serves only for
/// the user to tap one button and is incredibly short lived.
final class AuthenticationViewController: UIViewController {
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    

    // MARK: - Properties
    let loadingView = UIActivityIndicatorView(style: .whiteLarge)
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = "MonYo"
        return label
    }()
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "A small app to implement some of the features of Monzo's public api."
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let signInStackview: UIStackView = {
        let stackView = UIStackView()
        let textfield = UILabel()
        textfield.isUserInteractionEnabled = false
        textfield.text = "You will have to sign in via Monzo to use MonYo."
        textfield.font = UIFont.preferredFont(forTextStyle: .footnote)
        textfield.numberOfLines = 0
        textfield.textColor = .white
        let signinButton = RoundedButton(text: "Sign in")
        signinButton.backgroundColor = .purple
        signinButton.textColor = .purple
        signinButton.tintColor = .white
        signinButton.translatesAutoresizingMaskIntoConstraints = false
        signinButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        signinButton.tappedTintColorBrightnessOffset = -0.15
        signinButton.tappedHandler = {
            Current.update(message: .startFetchingTokens)
        }
        let debugButton = RoundedButton(text: "Fake It!")
        debugButton.backgroundColor = .purple
        debugButton.textColor = .purple
        debugButton.tintColor = .white
        debugButton.translatesAutoresizingMaskIntoConstraints = false
        debugButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        debugButton.tappedTintColorBrightnessOffset = -0.15
        debugButton.tappedHandler = {
            // FIXME: remove ASAP, need a better way to switch backends
            // inside `Debug`
            //Realworld.networkRequest = babylonNetworkMock

//            Commands._fetchTokens =
//                { authCode, clientID, clientSecret, redirectURI in
//                    return Cont.pure(.success(Tokens(accessToken: "adsf", refreshToken: nil, expires: nil)))
//            }
//
            Current.update(message: .receievedAuthCode(authCode: "authCode", stateToken: Current.model.authentication.credentials.stateToken))
        }
        
        let debugTextField = UILabel()
        debugTextField.isUserInteractionEnabled = false
        debugTextField.text = "I don't have a monzo account, or I don't trust you!"
        debugTextField.font = UIFont.preferredFont(forTextStyle: .footnote)
        debugTextField.numberOfLines = 0
        debugTextField.textColor = .white


        stackView.addArrangedSubview(signinButton)
        stackView.addArrangedSubview(textfield)
        stackView.setCustomSpacing(50, after: textfield)
        stackView.addArrangedSubview(debugButton)
        stackView.addArrangedSubview(debugTextField)


        return stackView
    }()

    
    // MARK: - Setup
    func setup() {
        self.view.backgroundColor = .purple
        self.view.addSubview(signInStackview)
        self.view.addSubview(loadingView)
        
        self.view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        self.view.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
        
        loadingView.isHidden = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loadingView.hidesWhenStopped = true
        
        signInStackview.translatesAutoresizingMaskIntoConstraints = false
        signInStackview.spacing = 5
        signInStackview.axis = .vertical
        signInStackview.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
        signInStackview.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
        signInStackview.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    // MARK: - Update
    func update(model: Model) {
        if model.authentication.loading {
            self.signInStackview.isHidden = true
            self.loadingView.startAnimating()
        } else {
            self.signInStackview.isHidden = false
            self.loadingView.stopAnimating()
        }
    }
    
}
