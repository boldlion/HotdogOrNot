//
//  ViewController.swift
//  HotdogOrNot
//
//  Created by Bold Lion on 18.12.18.
//  Copyright © 2018 Bold Lion. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
    }

    @IBAction func camTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
            guard let ciImage = CIImage(image: selectedImage) else { fatalError("Couldnt convert the UIImage to CIImage") }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { fatalError("Loading CoreML Module failed.") }
        let request = VNCoreMLRequest(model: model) { vnRequest, error in
            guard let results = vnRequest.results as? [VNClassificationObservation] else {  fatalError("Failed to downcast results") }
            if let topResult = results.first {
                if topResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                }
                else {
                    self.navigationItem.title = "Not a hotdog!"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
