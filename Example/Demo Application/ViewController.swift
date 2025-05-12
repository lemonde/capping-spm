//
//  ViewController.swift
//  CappingDemo
//
//  Copyright © 2020 Le Monde. All rights reserved.
//

import UIKit
import LMDCapping

class ViewController: UIViewController, CappingServiceErrorDelegate
{
    // MARK: - Outlets

    @IBOutlet weak var startSessionButton: UIButton!
    @IBOutlet weak var stopSessionButton: UIButton!
    @IBOutlet weak var continueReadingButton: UIButton!
    @IBOutlet weak var autoUnblockSwitch: UISwitch!
    @IBOutlet weak var lockStateLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var conversionEventButton: UIButton!
    @IBOutlet weak var popinDisplayedEventButton: UIButton!

    private var cappingService: CappingService?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let baseURL = URL(string: "https://capping.lemonde.fr")!
        self.cappingService = CappingService(baseURL: baseURL, apiKey: "api-key-test")
        self.cappingService?.addObserver(self, selector: #selector(cappingServiceBlockingStatusDidChange(_:)))
        self.cappingService?.errorDelegate = self

        self.cappingService?.setUserId("user-test")
    }



    // MARK: - Actions

    @IBAction func startSessionButtonTouchUpInside(_ sender: Any) {
        self.cappingService?.startSession()
    }

    @IBAction func stopSessionTouchUpInside(_ sender: Any) {
        self.cappingService?.stopSession()
    }

    @IBAction func continueReadingTouchUpInside(_ sender: Any) {
        self.cappingService?.continueReading()
    }

    @IBAction func autoUnlockSwitchValueChanged(_ sender: UISwitch) {
        self.cappingService?.autoUnblock = sender.isOn
    }

    @IBAction func conversionEventTouchUpInside(_ sender: Any) {
        self.cappingService?.trackEvent(.conversion)
    }

    @IBAction func popinDisplayedEventTouchUpInside(_ sender: Any) {
        self.cappingService?.trackEvent(.popinDisplayed)
    }


    // MARK: - CappingService Observer

    @objc private func cappingServiceBlockingStatusDidChange(_ notification: Notification)
    {
        guard let lock = notification.userInfo?[LockStatusDidChangeUserInfoKey] as? CappingLock else {
            return
        }
        switch lock {
            case .blocked(_):
                NSLog("Session changed to LOCKED")
                self.lockStateLabel.text = "LOCKED"
                self.lockStateLabel.textColor = .systemRed
                self.continueReadingButton.isHidden = false
                self.autoUnblockSwitch.isEnabled = true
            case .unblocked:
                NSLog("Session changed to UNLOCKED")
                self.lockStateLabel.text = "UNLOCKED"
                self.lockStateLabel.textColor = .systemGreen
                self.continueReadingButton.isHidden = true
                self.autoUnblockSwitch.isEnabled = false
                self.autoUnblockSwitch.isOn = true
        }
        self.errorLabel.text = nil
    }


    // MARK: - CappingServiceErrorDelegate

    func cappingServiceOperationFailedWithError(_ error: NSError) {
        NSLog("CappingService error: \(error)")
        self.errorLabel.text = error.localizedDescription
    }
}

