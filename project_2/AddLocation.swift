//
//  AddLocation.swift
//  project_2
//
//  Created by Sagar Gurung on 2023-04-07.
//

import UIKit

class AddLocation: UIViewController {

    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        weatherImageView.image = UIImage(systemName: "cloud.sun.bolt.fill")
        temperature.text = "10 C"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchBtnTapped(_ sender: UIButton) {
        location.text = searchTextField.text
    }
    
    
    @IBAction func saveBtnTapped(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func cancelBtnTapped(_ sender: UIBarButtonItem) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
