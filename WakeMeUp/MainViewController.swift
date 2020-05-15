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
    
    var ref: DatabaseReference?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTimePicker.setValue(UIColor.black, forKeyPath: "textColor")
        ref = Database.database().reference()
        getCurrentTimeProgrammed()
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
    
}
