//
//  Authenticator.swift
//  Authenticator
//
//  Created by Michal Švácha on 02/02/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit
import LocalAuthentication

/// Authenticator errors
public let AuthenticatorErrorDomain = "ios.github.svachmic.authenticator.error"

class Authenticator {
    
    /**
    Checks if PIN has been set by checking if there is PIN in the keychain.
    
    :returns: True if setup is needed, false otherwise.
    */
    class func needsPINSetup() -> Bool {
        return AuthenticatorKeychain.loadPIN() == nil
    }
    
    /**
    Shows alert dialog for setting up the PIN. Handles empty PIN and non-matching values situations by showing the alert dialog again with modified message saying what went wrong.
    
    :param: contextController Controller which will modally present the alert view dialog.
    :param: completionClosure Closure performed if everything has gone well.
    :param: failureClosure Closure performed if an error has occurred.
    */
    class func setUpPIN(contextController: UIViewController, completionClosure: () -> Void, failureClosure: (error: NSError) -> Void) {
        var alertClosure: (pin1: String, pin2: String, message: String) -> Void = {(pin1, pin2, message) -> Void in}
        alertClosure = { (pin1, pin2, message) -> Void in
            let title = NSLocalizedString("PIN Setup", comment: "")
            let cancel = NSLocalizedString("Cancel", comment: "")
            let ok = NSLocalizedString("OK", comment: "")
            let PIN = NSLocalizedString("PIN", comment: "")
            let confirmPIN = NSLocalizedString("Confirm PIN", comment: "")
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: cancel, style: UIAlertActionStyle.Destructive, handler: { (alert: UIAlertAction!) -> Void in
                let error = NSError(domain: AuthenticatorErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("PIN setup process has been cancelled.", comment: "")])
                failureClosure(error: error)
            }))
            
            alertController.addAction(UIAlertAction(title: ok, style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
                let pinTextField = alertController.textFields![0] as UITextField
                let pinCheckTextField = alertController.textFields![1] as UITextField
                let originalMessage = NSLocalizedString("Please enter your old and new PIN.", comment: "")
                
                if pinTextField.text == "" {
                    let errorMessage = NSLocalizedString("PIN cannot be empty!", comment: "")
                    let newMessage = "\(originalMessage)\n\n\(errorMessage)"
                    alertClosure(pin1: "", pin2: "", message: newMessage)
                } else if pinTextField.text != pinCheckTextField.text {
                    let errorMessage = NSLocalizedString("PINs must match!", comment: "")
                    let newMessage = "\(originalMessage)\n\n\(errorMessage)"
                    alertClosure(pin1: pinTextField.text, pin2: pinCheckTextField.text, message: newMessage)
                } else {
                    AuthenticatorKeychain.savePIN(pinTextField.text)
                    completionClosure()
                }
            }))
            
            alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = PIN
                textField.secureTextEntry = true
                textField.keyboardType = UIKeyboardType.NumberPad
                textField.text = pin1
            }
            
            alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = confirmPIN
                textField.secureTextEntry = true
                textField.keyboardType = UIKeyboardType.NumberPad
                textField.text = pin2
            }
            
            contextController.presentViewController(alertController, animated: true, completion: nil)
        }
        
        let message = NSLocalizedString("Please enter your new PIN.", comment: "")
        alertClosure(pin1: "", pin2: "", message: message)
    }
    
    /**
    Shows alert dialog for resetting the PIN. Handles invalid original PIN, non-matching values and same PIN entry situations by showing the alert dialog again with modified message saying what went wrong.
    
    :param: contextController Controller which will modally present the alert view dialog.
    :param: completionClosure Closure performed if everything has gone well.
    :param: failureClosure Closure performed if an error has occurred.
    */
    class func resetPIN(contextController: UIViewController, completionClosure: () -> Void, failureClosure: (error: NSError) -> Void) {
        var alertClosure: (oldPin:String, newPin1: String, newPin2: String, message: String) -> Void = {(oldPin, newPin1, newPin2, message) -> Void in}
        alertClosure = { (oldPin, newPin1, newPin2, message) -> Void in
            let title = NSLocalizedString("PIN Reset", comment: "")
            let cancel = NSLocalizedString("Cancel", comment: "")
            let ok = NSLocalizedString("OK", comment: "")
            let oldPIN = NSLocalizedString("Old PIN", comment: "")
            let PIN = NSLocalizedString("New PIN", comment: "")
            let confirmPIN = NSLocalizedString("Confirm new PIN", comment: "")
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: cancel, style: UIAlertActionStyle.Destructive, handler: { (alert: UIAlertAction!) -> Void in
                let error = NSError(domain: AuthenticatorErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("PIN reset process has been cancelled.", comment: "")])
                failureClosure(error: error)
            }))
            
            alertController.addAction(UIAlertAction(title: ok, style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
                let oldPinTextField = alertController.textFields![0] as UITextField
                let pinTextField = alertController.textFields![1] as UITextField
                let pinCheckTextField = alertController.textFields![2] as UITextField
                let originalMessage = NSLocalizedString("Please enter your old and new PIN.", comment: "")
                
                if oldPinTextField.text == AuthenticatorKeychain.loadPIN() {
                    if pinTextField.text == "" {
                        let errorMessage = NSLocalizedString("PIN cannot be empty!", comment: "")
                        let newMessage = "\(originalMessage)\n\n\(errorMessage)"
                        alertClosure(oldPin: oldPinTextField.text, newPin1: "", newPin2: "", message: newMessage)
                    } else if oldPinTextField.text == pinTextField.text {
                        let errorMessage = NSLocalizedString("New PIN must be different from the old one!", comment: "")
                        let newMessage = "\(originalMessage)\n\n\(errorMessage)"
                        alertClosure(oldPin: oldPinTextField.text, newPin1: "", newPin2: "", message: newMessage)
                    } else if pinTextField.text != pinCheckTextField.text {
                        let errorMessage = NSLocalizedString("PINs must match!", comment: "")
                        let newMessage = "\(originalMessage)\n\n\(errorMessage)"
                        alertClosure(oldPin: oldPinTextField.text, newPin1: "", newPin2: "", message: newMessage)
                    } else {
                        AuthenticatorKeychain.savePIN(pinTextField.text)
                        completionClosure()
                    }
                } else {
                    let errorMessage = NSLocalizedString("The old PIN you entered was invalid!", comment: "")
                    let newMessage = "\(originalMessage)\n\n\(errorMessage)"
                    alertClosure(oldPin: "", newPin1: pinTextField.text, newPin2: pinCheckTextField.text, message: newMessage)
                }
            }))
            
            alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = oldPIN
                textField.secureTextEntry = true
                textField.keyboardType = UIKeyboardType.NumberPad
                textField.text = oldPin
            }
            
            alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = PIN
                textField.secureTextEntry = true
                textField.keyboardType = UIKeyboardType.NumberPad
                textField.text = newPin1
            }
            
            alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                textField.placeholder = confirmPIN
                textField.secureTextEntry = true
                textField.keyboardType = UIKeyboardType.NumberPad
                textField.text = newPin2
            }
            
            contextController.presentViewController(alertController, animated: true, completion: nil)
        }
        
        if !Authenticator.needsPINSetup() {
            let message = NSLocalizedString("Please enter your old and new PIN.", comment: "")
            alertClosure(oldPin: "", newPin1: "", newPin2: "", message: message)
        } else {
            Authenticator.setUpPIN(contextController, completionClosure: completionClosure, failureClosure: failureClosure)
        }
    }
    
    /**
    Deletes the PIN.
    
    :param: completionClosure Closure performed if everything has gone well.
    :param: failureClosure Closure performed if an error has occurred.
    */
    class func deletePIN(completionClosure: () -> Void, failureClosure: (error: NSError) -> Void) {
        if let error = AuthenticatorKeychain.deletePIN() {
            failureClosure(error: error)
        } else {
            completionClosure()
        }
    }
    
    /**
    Shows alert dialog for entering the PIN to authenticate. Handles invalid PIN and empty values by showing the alert dialog again with modified message saying what went wrong. Attempt limit is set to 3 - after that failureClosure is called.
    
    :param: contextController Controller which will modally present the alert view dialog.
    :param: completionClosure Closure performed if everything has gone well.
    :param: failureClosure Closure performed if an error has occurred.
    */
    class func showPINAlert(contextController: UIViewController, completionClosure:() -> Void, failureClosure:(error: NSError) -> Void) {
        var alertClosure: (round: Int, message: String) -> Void = {(round, message) -> Void in}
        alertClosure = { (round, message) -> Void in
            if round < 3 {
                let title = NSLocalizedString("PIN Alert", comment: "")
                let cancel = NSLocalizedString("Cancel", comment: "")
                let ok = NSLocalizedString("OK", comment: "")
                let PIN = NSLocalizedString("PIN", comment: "")
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: cancel, style: UIAlertActionStyle.Destructive, handler: { (alert: UIAlertAction!) -> Void in
                    let error = NSError(domain: AuthenticatorErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Authentication process has been cancelled.", comment: "")])
                    failureClosure(error: error)
                }))
                
                alertController.addAction(UIAlertAction(title: ok, style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
                    if let pincode = AuthenticatorKeychain.loadPIN() {
                        let textFieldText = (alertController.textFields![0] as UITextField).text
                        if textFieldText == "" {
                            let originalMessage = NSLocalizedString("Please enter your PIN to proceed.", comment: "")
                            let errorMessage = NSLocalizedString("PIN cannot be empty!", comment: "")
                            let newMessage = "\(originalMessage)\n\n\(errorMessage)"
                            alertClosure(round: round + 1, message: newMessage)
                        } else if pincode == textFieldText {
                            completionClosure()
                        } else {
                            let originalMessage = NSLocalizedString("Please enter your PIN to proceed.", comment: "")
                            let errorMessage = NSLocalizedString("Entered PIN was incorrect.", comment: "")
                            let newMessage = "\(originalMessage)\n\n\(errorMessage)"
                            alertClosure(round: round + 1, message: newMessage)
                        }
                    } else {
                        let error = NSError(domain: AuthenticatorErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("PIN hasn't been set up yet.", comment: "")])
                        failureClosure(error: error)
                    }
                }))
                
                alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
                    textField.placeholder = PIN
                    textField.secureTextEntry = true
                    textField.keyboardType = UIKeyboardType.NumberPad
                }
                
                contextController.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let error = NSError(domain: AuthenticatorErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Attempt limit exceeded.", comment: "")])
                failureClosure(error: error)
            }
        }
        
        if !Authenticator.needsPINSetup() {
            let message = NSLocalizedString("Please enter your PIN to proceed.", comment: "")
            alertClosure(round: 0, message: message)
        } else {
            Authenticator.setUpPIN(contextController, completionClosure: completionClosure, failureClosure: failureClosure)
        }
    }
    
    /**
    Evaluates how the user should be authenticated. Gives the choice for TouchID or PIN code.
    
    :param: contextController Controller which will modally present the alert view dialog.
    :param: completionClosure Closure performed if everything has gone well.
    :param: failureClosure Closure performed if an error has occurred.
    */
    class func authenticateUser(contextController: UIViewController, completionClosure:() -> Void, failureClosure:(error: NSError) -> Void) {
        let context = LAContext()
        let reasonMessage = NSLocalizedString("Authentication is needed to perform this action.", comment: "")
        var error: NSError?
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonMessage, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                if success {
                    completionClosure()
                } else {
                    if evalPolicyError!.code == LAError.SystemCancel.rawValue || evalPolicyError!.code == LAError.UserCancel.rawValue {
                        let error = NSError(domain: AuthenticatorErrorDomain, code: evalPolicyError!.code, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Authentication process has been cancelled.", comment: "")])
                        failureClosure(error: error)
                    } else {
                        self.showPINAlert(contextController, completionClosure: completionClosure, failureClosure: failureClosure)
                    }
                }
            })
        } else {
            self.showPINAlert(contextController, completionClosure: completionClosure, failureClosure: failureClosure)
        }
    }
}
