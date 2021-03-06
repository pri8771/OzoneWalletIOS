//
//  SettingsMenuTableViewControllwe.swift
//  O3
//
//  Created by Andrei Terentiev on 9/26/17.
//  Copyright © 2017 drei. All rights reserved.
//

import Foundation
import KeychainAccess
import UIKit

class SettingsMenuTableViewController: ThemedTableViewController, HalfModalPresentable {
    @IBOutlet weak var showPrivateKeyView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var networkView: UIView!
    @IBOutlet weak var networkCell: UITableViewCell!
    @IBOutlet weak var themeCell: UITableViewCell!
    @IBOutlet weak var themeView: UIView!
    @IBOutlet weak var privateKeyLabel: UILabel!
    @IBOutlet weak var addressBookLabel: UILabel!
    @IBOutlet weak var watchOnlyLabel: UILabel!
    @IBOutlet weak var netLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!

    var netString = UserDefaultsManager.network == .test ? "Network: Test Network": "Network: Main Network" {
        didSet {
            self.setNetLabel()
        }
    }

    var themeString = UserDefaultsManager.theme == .light ? "Theme: Classic": "Theme: Dark" {
        didSet {
            self.setThemeLabel()
        }
    }

    func setNetLabel() {
        guard let label = networkCell.viewWithTag(1) as? UILabel else {
            fatalError("Undefined behavior with table view")
        }
        DispatchQueue.main.async { label.text = self.netString }
    }

    func setThemeLabel() {
        guard let label = themeCell.viewWithTag(1) as? UILabel else {
            fatalError("Undefined behavior with table view")
        }
        DispatchQueue.main.async { label.text = self.themeString }
    }

    func setThemedElements() {
        themedTitleLabels = [privateKeyLabel, addressBookLabel, watchOnlyLabel, netLabel, shareLabel, contactLabel, themeLabel, logoutLabel, versionLabel]
        themedLabels = [versionLabel]
    }

    override func viewDidLoad() {
        setThemedElements()
        super.viewDidLoad()
        let rightBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "angle-up"), style: .plain, target: self, action: #selector(SettingsMenuTableViewController.maximize(_:)))
        navigationItem.rightBarButtonItem = rightBarButton
        showPrivateKeyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPrivateKey)))
        contactView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendMail)))
        shareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share)))
        themeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeTheme)))
        setNetLabel()
        setThemeLabel()

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = String(format:"Version: %@", version)
        }
    }

    @objc func maximize(_ sender: Any) {
        maximizeToFullScreen()
    }

    @objc func changeTheme() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let lightThemeAction = UIAlertAction(title: "Classic Theme", style: .default) { _ in
            UserDefaultsManager.theme = .light
            self.themeString = "Theme: Classic"
        }

        let darkThemeAction = UIAlertAction(title: "Dark Theme", style: .default) { _ in
            UserDefaultsManager.theme = .dark
            self.themeString = "Theme: Dark"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }

        optionMenu.addAction(lightThemeAction)
        optionMenu.addAction(darkThemeAction)
        optionMenu.addAction(cancelAction)

        present(optionMenu, animated: true, completion: nil)
    }

    @objc func sendMail() {
        let email = "O3WalletApp@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }

    @objc func share() {
        let shareURL = URL(string: "https://o3.network/")
        let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func showPrivateKey() {
        let keychain = Keychain(service: "network.o3.neo.wallet")
        DispatchQueue.global().async {
            do {
                let password = try keychain
                    .authenticationPrompt("Authenticate to view your private key")
                    .get("ozonePrivateKey")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueToPrivateKey", sender: nil)
                }

            } catch let error {

            }
        }
    }

    func logoutTapped(_ sender: Any) {

    }

    //properly implement cell did tap
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 7 {
            OzoneAlert.confirmDialog(message: "Log out?", cancelTitle: "Cancel", confirmTitle: "Log out", didCancel: {

            }, didConfirm: {
                Authenticated.account = nil
                UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController()
            })

        }
    }
}
