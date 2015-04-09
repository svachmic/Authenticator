//
//  ViewController.swift
//  AuthenticatorExample
//
//  Created by Michal Švácha on 19/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func setupButtonPressed(sender: AnyObject) {
        Authenticator.setUpPIN(self.navigationController!, completionClosure: { () -> Void in
            println("All is good")
        }, failureClosure: { (error) -> Void in
            println(error.localizedDescription)
        })
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        Authenticator.resetPIN(self.navigationController!, completionClosure: { () -> Void in
            println("All is good")
        }, failureClosure: { (error) -> Void in
            println(error.localizedDescription)
        })
    }
    
    @IBAction func authenticateButtonPressed(sender: AnyObject) {
        Authenticator.authenticateUser(self.navigationController!, completionClosure: { () -> Void in
            println("Multipass!")
        }, failureClosure: { (error) -> Void in
            println(error.localizedDescription)
        })
    }
    
    @IBAction func deletePINButtonPressed(sender: AnyObject) {
        if let error = AuthenticatorKeychain.deletePIN() {
            println(error.localizedDescription)
        } else {
            println("Successfully deleted.")
        }
    }
}

