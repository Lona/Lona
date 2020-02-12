//
//  AccountPreferencesViewController.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 11/02/2020.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit
import MASPreferences

let GITHUB_CLIENT_ID = Bundle.main.infoDictionary?["GITHUB_CLIENT_ID"] as! String

func encodeURIComponent(_ string: String) -> String {
  var characterSet = CharacterSet.alphanumerics
  characterSet.insert(charactersIn: "-_.!~*'()")
  return string.addingPercentEncoding(withAllowedCharacters: characterSet)!
}

private let LABEL = "Account"

class AccountPreferencesViewController: NSViewController, MASPreferencesViewController {

  var viewIdentifier: String {
    return identifier!.rawValue
  }

  override var identifier: NSUserInterfaceItemIdentifier? {
    get {
      return NSUserInterfaceItemIdentifier(rawValue: LABEL)
    }
    set {
      super.identifier = newValue
    }
  }

  // Ensure that callbacks don't fire when removing from superview
  private var loaded = false

  func render() {
    loaded = false

    Account.reload()

    stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })

    if let token = Account.token {
      let tokenView = TextField(string: token)
      stackView.addArrangedSubview(tokenView)
    } else {
      let signInWithGitHubView = NSButton(title: "Sign In With GitHub", target: self, action: #selector(openGitHubSigninURL))
      let signInWithGoogleView = NSButton(title: "Sign In With Google", target: self, action: #selector(openGoogleSigninURL))
      stackView.addArrangedSubview(signInWithGitHubView)
      stackView.addArrangedSubview(signInWithGoogleView)
    }

    loaded = true
  }

  var stackView = NSStackView()

  override func viewDidLoad() {
    super.viewDidLoad()

    view = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 0))
    view.translatesAutoresizingMaskIntoConstraints = false

    stackView.orientation = .vertical
    stackView.alignment = .left
    stackView.spacing = 5
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    view.addSubview(stackView)

    stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
    stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
    stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
    stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true

    render()
  }

  @objc func openGitHubSigninURL() {
    let url = URL(string: "https://github.com/login/oauth/authorize?scope=user:email&client_id=\(GITHUB_CLIENT_ID)&redirect_uri=\(encodeURIComponent("\(API_BASE_URL)/oauth/github/\(encodeURIComponent("lonastudio://oauth-callback"))"))")!
    if !NSWorkspace.shared.open(url) {
      print("couldn't open the  browser")
    }
  }

  @objc func openGoogleSigninURL() {
    let url = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?client_id=\(GITHUB_CLIENT_ID)&response_type=code&scope=openid%20email%20profile&redirect_uri=\(encodeURIComponent("\(API_BASE_URL)/oauth/github/\(encodeURIComponent("lonastudio://oauth-callback"))"))")!
    if !NSWorkspace.shared.open(url) {
      print("couldn't open the  browser")
    }
  }

  var toolbarItemLabel: String? {
    return LABEL
  }

  var toolbarItemImage: NSImage? {
    return #imageLiteral(resourceName: "icon-layer-list-text")
  }
}

