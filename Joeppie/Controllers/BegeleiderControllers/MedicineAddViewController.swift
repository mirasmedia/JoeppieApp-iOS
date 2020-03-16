//
//  MedicineAddViewController.swift
//  Joeppie
//
//  Created by qa on 14/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class DropDownCell: UITableViewCell {
}

class MedicineAddViewController: UIViewController {
    var patient: Patient?
    var listOfMedicines = [Medicine]()
    var selectedMedicine: Medicine?
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    let transparantView = UIView()
    let mediListTblView = UITableView()
    var barHeight = CGFloat()
    
    @IBOutlet weak var selectMedicineBtn: UIButton!
    var frames = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMedicines()
        frames = selectMedicineBtn.frame
        barHeight = UIApplication.shared.statusBarFrame.size.height +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
        mediListTblView.delegate = self
        mediListTblView.dataSource = self
        mediListTblView.register(DropDownCell.self, forCellReuseIdentifier: "dropDownCell")
        
        
    }
    
    @IBAction func displayDropDown(_ sender: Any) {
        addTransparantView()
    }
    
    
    private func addTransparantView(){
        let window = UIApplication.shared.keyWindow
        transparantView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparantView)
        
        mediListTblView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(mediListTblView)
        mediListTblView.layer.cornerRadius = 5
        
        transparantView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparantView))
        transparantView.addGestureRecognizer(tapGesture)
        print(self.frames.origin.y, self.frames.origin.x, self.frames.height, self.frames.width)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0,
        initialSpringVelocity:1.0,
        options: .curveEaseInOut, animations: {
            self.transparantView.alpha = 0.7
            self.mediListTblView.frame = CGRect(x: self.frames.origin.x, y: self.frames.origin.y + self.frames.height + self.barHeight, width: (self.transparantView.frame.width - CGFloat(40)), height: 300)
        }, completion: nil)
    }
    
    @objc func removeTransparantView(){
        let frames = selectMedicineBtn.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity:1.0,
                       options: .curveEaseInOut, animations: {
            self.transparantView.alpha = 0
            self.mediListTblView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    private func getMedicines(){
        ApiService.getAllMedicines().responseData(completionHandler: { (response) in
            guard let jsonData = response.data else { return }
            self.dateFormatter.locale = Locale.current
            self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

            self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
            guard let medi = try? self.decoder.decode([Medicine].self, from: jsonData) else { print("here 2"); return }
            self.listOfMedicines = medi.sorted(by: {$0.name < $1.name})
        })
    }
    
}

extension MedicineAddViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfMedicines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dropDownCell", for: indexPath)
        cell.textLabel?.text = listOfMedicines[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMedicine = listOfMedicines[indexPath.row]
        selectMedicineBtn.setTitle(listOfMedicines[indexPath.row].name, for: .normal)
        removeTransparantView()
    }
}
