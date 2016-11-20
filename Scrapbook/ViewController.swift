//
//  ViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-19.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    override func viewDidLoad() {
        // We do any additional setup after loading the view
        super.viewDidLoad()

        captionTextView.layer.cornerRadius = 10
        captionTextView.layer.borderColor = UIColor.lightGray.cgColor
        captionTextView.layer.borderWidth = 0.5
        
        // Handles the text field’s user input through delegate callbacks!
        nameTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: UITextFieldDelegate
    
    // This function is called when DONE is pressed on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // This hides the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Makes the photoNameLabel's text that which was in the text field
        photoNameLabel.text = textField.text
    }
    
    // MARK: UITextViewDelegate
  
    
    
    // MARK: UIImagePickerControllerDelegate
    
    // This is called when the user clicks the cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismisses the picker
        dismiss(animated: true, completion: nil)
    }
    
    // This is called when the user has picked a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Sometimes there is also an edited version of the photo: this uses the original!
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the picked photo
        photoImageView.image = selectedImage
        
        // Dismisses the picker
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Recall, resigning FR status means hiding the keyboard
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets people choose a photo
        let imagePickerController = UIImagePickerController()
        
        // Sets source of the photo
        imagePickerController.sourceType = .photoLibrary
        
        // Assigns ViewController as the delegate (notifies it!)
        imagePickerController.delegate = self
        
        // This gets executed on the "implicit self-object", ViewController & tells it to present the photo
        present(imagePickerController, animated: true, completion: nil)
    }
}

