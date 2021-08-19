//
//  InitialViewController.swift
//  pet_prototype
//
//  Created by 윤재필 on 2021/07/28.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var ivLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        view.backgroundColor = UIColor.init(displayP3Red: 99/255, green: 197/255, blue: 148/255, alpha: 1)

        let sqlite = SQLite()
        sqlite.createTable()
        
        let time = DispatchTime.now() + .seconds(1)

        ivLogo.alpha = 0
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.ivLogo.alpha = 1.0
        })
        DispatchQueue.main.asyncAfter(deadline: time, execute: self.moveToMain)
    } //viewDidLoad
    
    func moveToMain(){
      let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "main")
        mainVC?.modalPresentationStyle = .fullScreen
        self.present(mainVC!, animated: true, completion: nil)
        self.navigationController?.popViewController(animated: false)
    } //moveToMain
} //InitialViewController
