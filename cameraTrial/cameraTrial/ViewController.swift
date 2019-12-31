//
//  ViewController.swift
//  test
//
//  Created by Jaswant Kasinedi on 12/30/19.
//  Copyright © 2019 Jaswant Kasinedi. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    let pickerController = UIImagePickerController()
    override func viewDidLoad(){
        super.viewDidLoad()
        pickerController.sourceType = UIImagePickerController.SourceType.camera
        pickerController.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func takePicture(_ sender: Any) {
        present(pickerController,animated: true, completion: nil)
    }
    
}
extension ViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        self.imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("The camera has been closed")
    }
}
extension ViewController: UINavigationControllerDelegate{}
