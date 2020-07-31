//
//  MainViewController.swift
//  WakeMeUp
//
//  Created by Santiago Moreno on 9/05/20.
//  Copyright © 2020 Santiago Moreno. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore

class MainViewController: UIViewController {
    
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var makeCoffeeButton: UIButton!
    @IBOutlet weak var cupsLabel: UITextField!
    
    var ref: DatabaseReference?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTimePicker.setValue(UIColor.black, forKeyPath: "textColor")
        ref = Database.database().reference()
        getCurrentTimeProgrammed()
        observeTheCoffeeDevice()
        
        cupsLabel.keyboardType = .numberPad
        cupsLabel.layer.borderWidth = 1
        cupsLabel.layer.borderColor = UIColor.gray.cgColor
        cupsLabel.attributedPlaceholder = NSAttributedString(string: "How many cups",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func getCurrentTimeProgrammed(){
        showLoadingView()
        db.collection("devices").document("JlAtXf52v7WpxwCMSAfY").getDocument { (document, error) in
            if let data = document?.data(){
                let dateTimeInterval = data["hour"] as? Timestamp
                let date = dateTimeInterval != nil ? dateTimeInterval!.dateValue() : Date()
                self.dateTimePicker.setDate(date, animated: true)
            }
            self.hideLoadingView()
        }
    }
    
    func showLoadingView(){
        loadingView.isHidden = false
    }
    
    func hideLoadingView(){
        loadingView.isHidden = true
    }
    
    func observeTheCoffeeDevice(){
        ref?.child("casa14/node1/value1").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? String {
                if(value == "ON"){
                    let image = UIImage(named: "ic_coffee_maker_off")
                    self.makeCoffeeButton.setImage(image, for: .normal)
                }else{
                    let image = UIImage(named: "ic_coffee_maker")
                    self.makeCoffeeButton.setImage(image, for: .normal)
                }
            }
        })
        
        ref?.child("casa14/node1/cups").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                self.cupsLabel.text = "\(value)"
            }
        })
    }
    
    @IBAction func onCoffeePressed(_ sender: Any) {
        showLoadingView()
        ref?.child("casa14/node1/value1").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? String {
                var setSwitch = ""
                if(value == "ON"){
                    setSwitch = "OFF"
                }else{
                    setSwitch = "ON"
                }
                self.ref?.child("casa14/node1/dispatch_cups").setValue("YES")
                self.ref?.child("casa14/node1/value1").setValue(setSwitch)
                self.hideLoadingView()
            }
        }) { (error) in
            print(error.localizedDescription)
            self.hideLoadingView()
        }
    }
    
    @IBAction func onSetTime(_ sender: Any) {
        let time = dateTimePicker.date
        showLoadingView()
        db.collection("devices").document("JlAtXf52v7WpxwCMSAfY").setData(["hour": time, "lastModification": Date()], merge: true) { (error) in
            if let err = error {
                print(err.localizedDescription)
            }
            self.hideLoadingView()
        }
    }
    
    @IBAction func onScanQr(_ sender: Any) {
         let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
         self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func setCups(_ sender: Any) {
        let cupsOnLabel = Int(cupsLabel.text ?? "1") ?? 1
        self.ref?.child("casa14/node1/cups").setValue(cupsOnLabel)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
