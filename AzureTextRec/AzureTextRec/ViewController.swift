//
//  ViewController.swift
//  AzureTextRec
//
//  Created by Jaswant Kasinedi on 1/3/20.
//  Copyright © 2020 Jaswant Kasinedi. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var imagePicker: UIImagePickerController!
    private var textURL = "vision/v2.0/read/core/asyncBatchAnalyze";

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
    }
    override func viewDidAppear(_ animated: Bool) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
       // Retrieve the image.
       let image = (info[.originalImage] as? UIImage)!
       
       // Retrieve the byte array from image.
       let imageByteArray = image.jpegData(compressionQuality: 1.0)
        
       getTextFromImage(subscriptionKey: Constants.computerVisionSubscriptionKey, getTextUrl: Constants.computerVisionEndPoint + textURL, pngImage: imageByteArray!, onSuccess: { cognitiveText in
           print("cognitive text is: \(cognitiveText)")
       }, onFailure: {_ in print("failed")})
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        print("The camera has been closed")
    }
    
    
    /// Returns the text string after it has been extracted from an Image input.
    ///
    /// - Parameters:
    ///     -subscriptionKey: The Azure subscription key.
    ///     -pngImage: Image data in PNG format.
    /// - Returns: a string of text representing the
    func getTextFromImage(subscriptionKey: String, getTextUrl: String, pngImage: Data, onSuccess: @escaping (_ theToken: String) -> Void, onFailure: @escaping ( _ theError: String) -> Void) {
        
        let url = URL(string: getTextUrl)!
        var request = URLRequest(url: url)
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // Two REST API calls are required to extract text. The first call is to submit the image for processing, and the next call is to retrieve the text found in the image.
        
        // Set the body to the image in byte array format.
        request.httpBody = pngImage
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // Check for networking errors.
                error == nil else {
                    print("error", error ?? "Unknown error")
                    onFailure("Error")
                    return
            }
            
            // Check for http errors.
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                onFailure(String(response.statusCode))
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString!))")
            
            // Send the second call to the API. The first API call returns operationLocation which stores the URI for the second REST API call.
            let operationLocation = response.allHeaderFields["Operation-Location"] as? String
            
            if (operationLocation == nil) {
                print("Error retrieving operation location")
                return
            }
            
            // Wait 10 seconds for text recognition to be available as suggested by the Text API documentation.
            print("Text submitted. Waiting 10 seconds to retrieve the recognized text.")
            sleep(10)
            
            // HTTP GET request with the operationLocation url to retrieve the text.
            let getTextUrl = URL(string: operationLocation!)!
            var getTextRequest = URLRequest(url: getTextUrl)
            getTextRequest.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            getTextRequest.httpMethod = "GET"
            
            // Send the GET request to retrieve the text.
            let taskGetText = URLSession.shared.dataTask(with: getTextRequest) { data, response, error in
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    // Check for networking errors.
                    error == nil else {
                        print("error", error ?? "Unknown error")
                        onFailure("Error")
                        return
                }
                
                // Check for http errors.
                guard (200 ... 299) ~= response.statusCode else {
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    onFailure(String(response.statusCode))
                    return
                }
                
                // Decode the JSON data into an object.
                let customDecoding = try! JSONDecoder().decode(TextApiResponse.self, from: data)
                
                // Loop through the lines to get all lines of text and concatenate them together.
                var textFromImage = ""
                for textLine in customDecoding.recognitionResults[0].lines {
                    textFromImage = textFromImage + textLine.text + " "
                }
                
                onSuccess(textFromImage)
            }
            taskGetText.resume()

        }
        
        task.resume()
    }
    
    // Structs used for decoding the Text API JSON response.
    struct TextApiResponse: Codable {
        let status: String
        let recognitionResults: [RecognitionResult]
    }

    struct RecognitionResult: Codable {
        let page: Int
        let clockwiseOrientation: Double
        let width, height: Int
        let unit: String
        let lines: [Line]
    }

    struct Line: Codable {
        let boundingBox: [Int]
        let text: String
        let words: [Word]
    }

    struct Word: Codable {
        let boundingBox: [Int]
        let text: String
        let confidence: String?
    }
    
}

