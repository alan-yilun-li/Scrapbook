//
//  MomentViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-19.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class MomentViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var moment: Moment?
    var navigationBarHeight: CGFloat!

    override func viewDidLoad() {
        // We do any additional setup after loading the view
        super.viewDidLoad()
        
        // Will be notified when keyboard shows up (for scrolling)
        registerKeyboardRelatedNotifications()
        scrollView.isScrollEnabled = false
    
        // Checking for valid title and photo to enable save button
        checkValidMomentName()
        checkValidPhoto()
        
        // Configuring UIElements 
        configureCaptionTextView()
        
        // Navigationbar UI Specifications
        let navBarAppearance = navigationController?.navigationBar
        navBarAppearance?.isTranslucent = true
        navBarAppearance?.barTintColor = UIColor.lightText
        
        // Handles the text field’s user input through delegate callbacks
        nameTextField.delegate = self
        scrollView.delegate = self
    
        // Sets up an existing moment if it's being edited
        if let moment = moment {
            // Setting the photoImageView to scale based on the photo
            photoImageView.contentMode = .scaleAspectFit
            
            // Setting the views with the data from the given moment
            navigationItem.title = moment.name
            nameTextField.text   = moment.name
            photoImageView.image = moment.photo
            captionTextView.text = moment.caption
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
    
    func checkValidMomentName() {
        // Disables saving if textfield is empty
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func checkValidPhoto() {
        if photoImageView.image!.isEqual(#imageLiteral(resourceName: "DefaultPhoto")) {
            saveButton.isEnabled = false
        }
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Helps configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToTableOfContentsID" {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let caption = captionTextView.text ?? ""
            
            // Set the moment to be passed to the table view controller after the segue
            moment = Moment(name: name, photo: photo, caption: caption)
        }
    }
    
    
    // MARK: Actions
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        //forceHideKeyboard()
        performSegue(withIdentifier: "unwindToTableOfContentsID", sender: self)
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        if captionTextView.isFirstResponder || nameTextField.isFirstResponder {
            captionTextView.resignFirstResponder()
            nameTextField.resignFirstResponder()
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)

    }
}

// MARK: General Keyboard Related Functions
extension MomentViewController {
    
    /// Adds observers and gesture recognizers to self.
    func registerKeyboardRelatedNotifications() {
        // Adding notifies on keyboard appearing
        
        /// An object to set the textView or pickerView to end editing when the outside is tapped.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forceHideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
    }
    
    /// Deregisters keyboard notifications on leaving.
    func deregisterFromKeyboardNotifications(){
        // Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    /// Function that forces the captionTextView or pickerView to end editing and close.
    @objc func forceHideKeyboard() {
        if captionTextView.isFirstResponder {
            captionTextView.resignFirstResponder()
        } else if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification) {
        
        // Only scrolling the keyboard if it is to edit the comment box.
        guard captionTextView.isFirstResponder else {
            return
        }
        
        /// CGRectFrame of the keyboard.
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        scrollView.setContentOffset(CGPoint(x: 0, y: keyboardFrame.height), animated: true)
    }
    
    func scrollToTop() {
        let originalpos: CGPoint = CGPoint(x: 0.0, y: 0.0)
        scrollView.setContentOffset(originalpos, animated: true)
    }
    
    
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
        scrollToTop()
        view.endEditing(true)
    }
    
}



// MARK: UITextFieldDelegate Methods
extension MomentViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disables saving when currently editing
        saveButton.isEnabled = false
    }
    
    // This function is called when DONE is pressed on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // This hides the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidMomentName()
        checkValidPhoto()
        navigationItem.title = textField.text
    }
    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterCountLimit = 30
        
        // Figuring out how many characters the unaltered string would have
        let startingLength = textFieldToChange.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterCountLimit
    }
}

// MARK: UITextViewDelegate Methods & Related Functions
extension MomentViewController: UITextViewDelegate {
    
    /// Setup code for the main TextView.
    fileprivate func configureCaptionTextView() {
        
        // Setting the delegate
        captionTextView.delegate = self
        
        // UI Customization
        captionTextView.layer.cornerRadius = 10
        captionTextView.layer.borderColor = UIColor.brown.cgColor
        captionTextView.layer.borderWidth = 0.5
        
        // Setting up height based on screen size
        
        // Calculating the necessary height for the captionTextView
        // We do this by taking the height of the screen (view.height)
        // And then subtracting the elements composing the height of the screen except the caption textview.
        // The reason this is not in the UIHelper module is because it relies on too many other views to calculate the height.
        
        // Calculating the top position of the map view relative to the screen.
        
        if navigationBarHeight == nil {
            navigationBarHeight = navigationController!.navigationBar.frame.height
        }
        
        let height = view.frame.height
            - view.frame.width // for the image picker view height b/c 1-1 aspect ratio
            - nameTextField.frame.height
            - 4 * 10 // for the stack view spacing
            - navigationBarHeight
        captionTextView.addConstraint(NSLayoutConstraint(item: captionTextView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: height))
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = false
        
        if (textView.text != nil) && (textView.text == Constants.captionPlaceholderText) {
            textView.text = ""
            textView.textColor = UIColor.darkText
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == nil) || (textView.text == "") {
            textView.text = Constants.captionPlaceholderText
            textView.textColor = UIColor.lightGray
        } else {
            saveButton.isEnabled = true 
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Enforcing a character limit on the caption for safety.
        
        // The new state of the text if the change happens
        let newText = (textView.text + text)
        
        // Allowing the change if the text is under or at our limit, and cutting it if it isn't
        if newText.characters.count <= Constants.commentMaxLength {
            return true
        } else {
            textView.text = newText.substring(to: newText.index(newText.startIndex, offsetBy: Constants.commentMaxLength))
            return false
        }
    }

}


// MARK: UIImagePickerControllerDelegate Methods
extension MomentViewController: UIImagePickerControllerDelegate {
    
    // This is called when the user clicks the cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Dismisses the picker
        dismiss(animated: true, completion: nil)
    }
    
    // This is called when the user has picked a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Setting the image and scaling the photoImageView accordingly
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.image = selectedImage
        
        // Enables the save button if the photo title is non-empty
        checkValidMomentName()
        
        // Dismisses the picker
        dismiss(animated: true, completion: nil)
    }
    
}


// MARK: UINavigationController Conformance Addition
extension MomentViewController: UINavigationControllerDelegate {}

