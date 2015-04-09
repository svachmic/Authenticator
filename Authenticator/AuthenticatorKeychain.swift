//
//  AuthenticatorKeychainService.swift
//  Authenticator
//
//  Created by Michal Švácha on 19/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import Foundation
import Security

/// Authenticator constants
let serviceIdentifier = "AuthenticatorService"
let attributeAccount = "AuthenticatorPIN"

/**
Class encapsulating all AUthenticator - Keychain communication. Provides API for CRUD operations.
*/
class AuthenticatorKeychain {
    
    /**
    Saves the PIN and returns status of the operation.
    
    :param: pinToken String with the PIN to be saved.
    :returns: Either nil or NSError object (when error has occurred).
    */
    class func savePIN(pinToken: String) -> NSError? {
        var pinData: NSData = pinToken.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        let keychainQuery = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrService as String : serviceIdentifier,
            kSecAttrAccount : attributeAccount,
            kSecValueData : pinData]
        
        let deleteStatusCode = SecItemDelete(keychainQuery as CFDictionaryRef)
        
        // 0 means deleted successfully, -25300 means nothing found. Both are valid conditions.
        if deleteStatusCode == 0 || deleteStatusCode == -25300 {
            var addStatusCode = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
            return addStatusCode == 0 ? nil : NSError(domain: NSOSStatusErrorDomain, code: Int(addStatusCode), userInfo: nil)
        } else {
            return NSError(domain: NSOSStatusErrorDomain, code: Int(deleteStatusCode), userInfo: nil)
        }
    }
    
    /**
    Deletes the PIN and returns status of the operation.
    
    :returns: Either nil or NSError object (when error has occurred).
    */
    class func deletePIN() -> NSError? {
        let keychainQuery = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrService as String : serviceIdentifier,
            kSecAttrAccount : attributeAccount]
        
        // 0 means deleted successfully, -25300 means nothing found. Both are valid conditions.
        let deleteStatusCode = SecItemDelete(keychainQuery as CFDictionaryRef)
        return (deleteStatusCode == 0 || deleteStatusCode == -25300) ? nil : NSError(domain: NSOSStatusErrorDomain, code: Int(deleteStatusCode), userInfo: nil)
    }
    
    /**
    Loads the PIN and returns it.
    
    :returns: Either the value as String or nil (when nothing has been found).
    */
    class func loadPIN() -> String? {
        let keychainQuery = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrService as String : serviceIdentifier as NSString,
            kSecAttrAccount : attributeAccount,
            kSecReturnData : kCFBooleanTrue,
            kSecMatchLimit : kSecMatchLimitOne]
        
        var dataTypeRef: Unmanaged<AnyObject>?
        let statusCode = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        var pinToken: String?
        if let opaquePointer = dataTypeRef?.toOpaque() {
            let retrievedData = Unmanaged<NSData>.fromOpaque(opaquePointer).takeUnretainedValue()
            pinToken = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
        }
        
        return pinToken
    }
}