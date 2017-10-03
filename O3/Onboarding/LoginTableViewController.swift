//
//  LoginTableViewController.swift
//  O3
//
//  Created by Andrei Terentiev on 9/16/17.
//  Copyright © 2017 drei. All rights reserved.
//

import Foundation
import UIKit
import NeoSwift
import Channel

class LoginTableViewController: UITableViewController, QRScanDelegate {
    @IBOutlet weak var wifTextField: UITextView!
    @IBOutlet weak var loginButton: ShadowedButton!
    var watchAddresses = [WatchAddress]()

    func loadWatchAddresses() {
        do {
            watchAddresses = try UIApplication.appDelegate.persistentContainer.viewContext.fetch(WatchAddress.fetchRequest())
        } catch {
            return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.tableFooterView = UIView(frame: CGRect(x:0, y:0, width:self.tableView.frame.size.width, height: 1))
        setNeedsStatusBarAppearanceUpdate()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cameraAlt"), style: .plain, target: self, action: #selector(qrScanTapped(_:)))
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let account = Account(wif: self.wifTextField.text ?? "") else {
            return
        }
        Authenticated.account = account
        //subscribe to a topic which is an address to receive push notification
        Channel.shared().subscribe(toTopic: account.address)
        //enable push notifcation. maybe put this in somewhere else?
        Channel.pushNotificationEnabled(true)
        self.performSegue(withIdentifier: "segueToMainFromLogin", sender: nil)
    }

    @objc func qrScanTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToQrFromLogin", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToQrFromLogin" {
            guard let dest = segue.destination as? QRScannerController else {
                fatalError("Undefined segue behavior")
            }
            dest.delegate = self
        } else {
            loadWatchAddresses()
            Authenticated.watchOnlyAddresses = watchAddresses.map {$0.address ?? ""}
        }
    }

    func qrScanned(data: String) {
        DispatchQueue.main.async { self.wifTextField.text = data }
    }
}