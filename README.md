# Authenticator

[![Build Status](https://travis-ci.org/svachmic/Authenticator.svg?branch=master)](https://travis-ci.org/svachmic/Authenticator)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/svachmic/Authenticator/blob/master/LICENSE.md)
[![Twitter: @Miguelitinho](https://img.shields.io/badge/contact-%40Miguelitinho-blue.svg?style=flat)](https://twitter.com/Miguelitinho)

A ready to use implementation of user authentication using either PIN or TouchID. Comes with Keychain wrapper to securely store PIN.

## Requirements

- iOS 8+
- Xcode 6.1+

## Usage

The concept is to work in closures, so no context needs to be saved and jumped over - simply authenticate the user (or not) and proceed. If TouchID is present, it will always be superior to PIN authentication. If TouchID is not present, or fails to authenticate user, PIN dialog is shown. Number of attempts is set to 3.

All the strings used are wrapped with `NSLocalizedString()`, so to localize to different languages, simply copy and paste all the used strings to your Strings.file in your project.

### PIN Setup

```swift
Authenticator.setUpPIN(self.navigationController!, completionClosure: { () -> Void in
	// PIN has been set up
}, failureClosure: { (error) -> Void in
	// An error has occurred
})
```

### Authenticate

If `authenticateUser` method is called without previously setting up PIN, setup dialog is shown instead. After PIN is set up, method behaves as though user has been authenticated.

```swift
Authenticator.authenticateUser(self.navigationController!, completionClosure: { () -> Void in
	// The user has been authenticated
}, failureClosure: { (error) -> Void in
	// Failed to authenticate the user
})
```

### Reset PIN
If `resetPIN` method is called withou previously setting up PIN, setup dialog is shown instead.

```swift
Authenticator.resetPIN(self.navigationController!, completionClosure: { () -> Void in
	// PIN has been successfully reset
}, failureClosure: { (error) -> Void in
	// An error has occurred
})
```

### Delete PIN

Delete PIN is not protected because it is an atomic function serving only to delete the stored PIN in the keychain. To protect it, simply wrap `authenticateUser` around it.

```swift
Authenticator.deletePIN({ () -> Void in
	// PIN has been successfully deleted
}, failureClosure: { (error) -> Void in
	// An error has occurred
})
```

## TODO

- iOS 7 support (UIAlertController vs UIAlertDialog)

* * *

## Contact

- [Michal Švácha](http://github.com/svachmic) ([@miguelitinho](https://twitter.com/miguelitinho))

## License

Authenticator is released under the MIT license. See LICENSE for details.
