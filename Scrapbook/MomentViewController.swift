//
//  MomentViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-19.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class MomentViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `MomentTableViewController` in `prepareForSegue(_:sender:)`
     or constructed as part of adding a new moment.
     */
    var moment: Moment?
    
    

    override func viewDidLoad() {
        // We do any additional setup after loading the view
        super.viewDidLoad()
        
        // Will be notified when keyboard shows up (for scrolling)
        registerForKeyboardNotifications()
        
        // Caption Border
        captionTextView.layer.cornerRadius = 10
        captionTextView.layer.borderColor = UIColor.lightGray.cgColor
        captionTextView.layer.borderWidth = 0.5
        
        // Handles the text field’s user input through delegate callbacks!
        nameTextField.delegate = self
        captionTextView.delegate = self
        scrollView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        deregisterFromKeyboardNotifications()
    }
    
    // MARK: UITextFieldDelegate
    
    // This function is called when DONE is pressed on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // This hides the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    
    // MARK: UITextViewDelegate
    
    // Making the TextView scroll when blocked by keyboard
    
    func registerForKeyboardNotifications() {
        // Adding notifies on keyboard appearing
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        // Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    func keyboardWasShown(_ notification: NSNotification)
    {
        // Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let height = keyboardSize!.height + 35
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= height
        if let captionTextView = self.captionTextView
        {
            if (!aRect.contains(captionTextView.frame.origin))
            {
                self.scrollView.scrollRectToVisible(captionTextView.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification: NSNotification){
        // Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        //self.view.endEditing(true) // safety
        self.scrollView.isScrollEnabled = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        captionTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        captionTextView = nil
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") { // This is when DONE is pressed
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
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
    
    
    // MARK: Navigation
    
    // Helps configure a view controller before it's presented
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let caption = captionTextView.text ?? ""
            
            // Set the moment to be passed to the table view controller after the segue
            moment = Moment(name: name, photo: photo, caption: caption)
        }
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

