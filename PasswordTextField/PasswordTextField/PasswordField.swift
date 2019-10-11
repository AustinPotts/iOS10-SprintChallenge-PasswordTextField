//
//  PasswordField.swift
//  PasswordTextField
//
//  Created by Ben Gohlke on 6/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

//Create an enum for the strenght levels
enum PasswordStrengthLevel: Int {
    case none = 0
    case weak = 5
    case medium = 9
    case strong = 20
    
    var toString: String {
        switch self {
        case .none:
            return "empty"
        case .weak:
            return "weak"
        case .medium:
            return "medium"
        case .strong:
            return "strong"
        }
    }
}


class PasswordField: UIControl {
    
    // Public API - these properties are used to fetch the final password and strength values
    private (set) var password: String = ""
    private (set) var passwordStrength = PasswordStrengthLevel.weak //This needs to be set as the default use
    
    private let standardMargin: CGFloat = 8.0
    private let textFieldContainerHeight: CGFloat = 50.0
    private let textFieldMargin: CGFloat = 6.0
    private let colorViewSize: CGSize = CGSize(width: 60.0, height: 5.0)
    
    private let labelTextColor = UIColor(hue: 233.0/360.0, saturation: 16/100.0, brightness: 41/100.0, alpha: 1)
    private let labelFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    
    private let textFieldBorderColor = UIColor(hue: 208/360.0, saturation: 80/100.0, brightness: 94/100.0, alpha: 1)
    private let bgColor = UIColor(hue: 0, saturation: 0, brightness: 97/100.0, alpha: 1)
    
    // States of the password strength indicators
    private let unusedColor = UIColor(hue: 210/360.0, saturation: 5/100.0, brightness: 86/100.0, alpha: 1)
    private let weakColor = UIColor(hue: 0/360, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let mediumColor = UIColor(hue: 39/360.0, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let strongColor = UIColor(hue: 132/360.0, saturation: 60/100.0, brightness: 75/100.0, alpha: 1)
    
    private var titleLabel: UILabel = UILabel()
    private var textField: UITextField = UITextField()
    private var showHideButton: UIButton = UIButton()
    private var weakView: UIView = UIView()
    private var mediumView: UIView = UIView()
    private var strongView: UIView = UIView()
    private var strengthDescriptionLabel: UILabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    
    func setup() {
        // Lay out your subviews here
        
        backgroundColor = bgColor
        
        //Create the label
        titleLabel.text = "If your password sucks, i'll let you know"
        titleLabel.textColor = labelTextColor
        titleLabel.font = labelFont
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        //Constrain the label created
        titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: standardMargin).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: standardMargin).isActive = true
        
        
        //Show hide button
        
        showHideButton.setImage(UIImage(named: "eyes-closed"), for: .normal)
        showHideButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        showHideButton.addTarget(self, action: #selector(eyeHidePassword), for: .touchUpInside)
        
        
        //Password Text field, create the text field
        textField.delegate = self
        textField.backgroundColor = .clear
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 2
        textField.layer.borderColor = textFieldBorderColor.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.rightView = showHideButton
        textField.rightViewMode = .always
        textField.isSecureTextEntry = true
        
        
        addSubview(textField)
        //Constrain the text field created
        textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: standardMargin).isActive = true
        textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: standardMargin).isActive = true
        textField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -standardMargin).isActive = true
        textField.heightAnchor.constraint(equalToConstant: textFieldContainerHeight).isActive = true
        
       
        
        //The views for Color Indicators
        
        for view in [weakView, mediumView, strongView]{
            view.backgroundColor = unusedColor
            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.heightAnchor.constraint(equalToConstant: colorViewSize.height).isActive = true
            view.widthAnchor.constraint(equalToConstant: colorViewSize.width).isActive = true
        }
        
        //Putting them into stack view
        
        let colorStackView = UIStackView(arrangedSubviews: [weakView, mediumView, strongView])
        colorStackView.translatesAutoresizingMaskIntoConstraints = false
        colorStackView.spacing = 3
        
        //Strength DescriptionLbl
        
        strengthDescriptionLabel.font = labelFont
        strengthDescriptionLabel.textColor = labelTextColor
        
        //StrengthStack,
        
        let strengthStackView = UIStackView(arrangedSubviews: [colorStackView, strengthDescriptionLabel])
        strengthStackView.translatesAutoresizingMaskIntoConstraints = false
        strengthStackView.alignment = .center
        strengthStackView.spacing = standardMargin
        
        addSubview(strengthStackView)
        
        strengthStackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: standardMargin).isActive = true
        strengthStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: standardMargin).isActive = true
        strengthStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -standardMargin).isActive = true
        
        
    }
    
    //Create the function for the eye hider
    @objc func eyeHidePassword(sender: UIButton) {
        textField.isSecureTextEntry.toggle()
        showHideButton.setImage(UIImage(named: textField.isSecureTextEntry ? "eyesOpen" : "eyesClosed"), for: .normal)
    }
    
    //Create a function that determines the strenght of the password entered
    private func figureStrengthPassword(of password: String){
        
        //make a switch case for testing. fo
            switch password.count {
            case (PasswordStrengthLevel.none.rawValue + 1)...PasswordStrengthLevel.weak.rawValue:
            passwordStrength = .weak
            case (PasswordStrengthLevel.weak.rawValue + 1)...PasswordStrengthLevel.medium.rawValue:
            passwordStrength = .medium
            case (PasswordStrengthLevel.medium.rawValue + 1)...PasswordStrengthLevel.strong.rawValue:
            passwordStrength = .strong
            default:
            passwordStrength = .none
            }
            
           
            
            self.password = password
            changeStrengthColor() // Create a function to change the color view
            sendActions(for: [.valueChanged])
        
    }
    
    
    //Function to change the color of the password strength
    private func changeStrengthColor(){
        //Make a switch case that will change the strength color depending on the strength case enum
        switch passwordStrength {
        case .none:
            weakView.backgroundColor = unusedColor   //All gray
            mediumView.backgroundColor = unusedColor
            strongView.backgroundColor = unusedColor
        case .weak:
            weakView.backgroundColor = weakColor
            mediumView.backgroundColor = unusedColor    //Only use the weak color, rest gray
            strongView.backgroundColor = unusedColor
        case .medium:
            weakView.backgroundColor = weakColor //Activate both weak color & medium color, strong = gray
            mediumView.backgroundColor = mediumColor
            strongView.backgroundColor = unusedColor
        case .strong:
            weakView.backgroundColor = weakColor //Activate all since the password is strong
            mediumView.backgroundColor = mediumColor
            strongView.backgroundColor = strongColor
        }
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        endEditing(true)
    }
    
}




extension PasswordField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        // TODO: send new text to the determine strength method
        if newText.count <= PasswordStrengthLevel.strong.rawValue {
            figureStrengthPassword(of: newText)
            return true
        }
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
        
        
}
