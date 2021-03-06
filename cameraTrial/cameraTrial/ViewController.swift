//
//  ViewController.swift
//  test
//
//  Created by Jaswant Kasinedi on 12/30/19.
//  Copyright © 2019 Jaswant Kasinedi. All rights reserved.
//

import Foundation
import UIKit
import TesseractOCR
import GPUImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var textView: UITextView!
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
    func performImageRecognition(_ image: UIImage) {
        let scaledImage = image.scaledImage(1000) ?? image
        let preprocessedImage = scaledImage.preprocessedImage() ?? scaledImage
        
        if let tesseract = G8Tesseract(language: "eng+fra") {
          tesseract.engineMode = .tesseractCubeCombined
          tesseract.pageSegmentationMode = .auto
          
          tesseract.image = preprocessedImage
          tesseract.recognize()
          textView.text = tesseract.recognizedText
        }
      }
    
    
<<<<<<< HEAD
=======
}

extension ViewController: UIImagePickerControllerDelegate{
>>>>>>> 2e3c6861aeb3937cc982b256c29f328c7d389058
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("hey")
        self.imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("The camera has been closed")
        picker.dismiss(animated: true, completion: nil)

    }
}
<<<<<<< HEAD
=======
extension ViewController: UINavigationControllerDelegate{}
// MARK: - UIImage extension
extension UIImage {
  func scaledImage(_ maxDimension: CGFloat) -> UIImage? {
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)

    if size.width > size.height {
      scaledSize.height = size.height / size.width * scaledSize.width
    } else {
      scaledSize.width = size.width / size.height * scaledSize.height
    }

    UIGraphicsBeginImageContext(scaledSize)
    draw(in: CGRect(origin: .zero, size: scaledSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
  }
  
  func preprocessedImage() -> UIImage? {
    let stillImageFilter = GPUImageAdaptiveThresholdFilter()
    stillImageFilter.blurRadiusInPixels = 15.0
    let filteredImage = stillImageFilter.image(byFilteringImage: self)
    return filteredImage
  }
}
>>>>>>> 2e3c6861aeb3937cc982b256c29f328c7d389058
