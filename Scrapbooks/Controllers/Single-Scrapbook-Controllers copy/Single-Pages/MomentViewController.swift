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
    @IBOutlet weak var datePicker: UIDatePicker!
    
    /// The scrapbook this controller belongs to.
    var scrapbook: Scrapbook!

    /// The moment this momentViewController is responsible for presenting.
    var moment: Moment!
    
    /// Bar height value responsible for helping set up the layout even in navigation.
    var navigationBarHeight: CGFloat!
    
    /* setting the correct initial content offset, fixing the problem coming from allowing content to be shown below the top bars.*/
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToTop(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToTop(animated: false)
    }
    
    override func viewDidLoad() {
        // We do any additional setup after loading the view
        super.viewDidLoad()
        
        // Will be notified when keyboard shows up (for scrolling)
        registerKeyboardRelatedNotifications()
    
        // Checking for valid title and photo to enable save button
        checkFieldsForCompletion()
        
        // Configuring UIElements 
        configureCaptionTextView()
        
        // Navigationbar UI Specifications
        if let navBar = navigationController?.navigationBar {
            ViewCustomizer.customize(navigationBar: navBar)
        }
        
        // Handles the text field’s user input through delegate callbacks
        nameTextField.delegate = self
        scrollView.delegate = self
    
        // Sets up an existing moment if it's being edited
        if let moment = moment {
            
            // Setting the views with the data from the given moment
            nameTextField.text   = moment.name
            photoImageView.image = moment.photo
            datePicker.date = moment.date
            
            if moment.caption == "" || moment.caption == Constants.captionPlaceholderText {
                captionTextView.text = Constants.captionPlaceholderText
                captionTextView.textColor = Colours.tan
            } else {
                captionTextView.text = moment.caption
            }
            scrapbook = moment.scrapbook
        } else {
            navigationItem.title = scrapbook.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
    
    private func checkFieldsForCompletion() {
        
        let name = nameTextField.text ?? ""
        saveButton.isEnabled = !name.isEmpty && !photoImageView.image!.isEqual(#imageLiteral(resourceName: "NoPhotoSelected"))
    }
    
    
    // MARK: - Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Helps configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToTableOfContentsID" {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image!
            let caption = { () -> String in 
                let text = captionTextView.text ?? ""
                if text == Constants.captionPlaceholderText {
                    return ""
                } else {
                    return text
                }
            }()
            let date = datePicker.date
            
            guard let destination = segue.destination as? MomentTableViewController else {
                fatalError()
            }
            
            // Set the moment to be passed to the table view controller after the segue
            moment = Moment(context: CoreDataStack.shared.persistentContainer.viewContext)
            moment.setup(withName: name, photo: photo, newCaption: caption, chosenDate: date, forScrapbook: destination.scrapbook)
        }
    }
    
    
    // MARK: - Actions
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        //forceHideKeyboard()
        
        if !nameTextField.text!.isUniqueName(among: scrapbook.moments.array as? [Moment]) {
            
            let uniquenessAlert = UIAlertController(title: "Name Already Used!", message: "Please choose a unique name.", preferredStyle: .alert)
            let returnAction = UIAlertAction(title: "Return", style: .default, handler: nil)
            uniquenessAlert.addAction(returnAction)
            
            self.present(uniquenessAlert, animated: true)
        } else {
            performSegue(withIdentifier: "unwindToTableOfContentsID", sender: self)
        }
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        if captionTextView.isFirstResponder || nameTextField.isFirstResponder {
            captionTextView.resignFirstResponder()
            nameTextField.resignFirstResponder()
            return
        }
        
        
        let typePicker = UIAlertController(title: "Select Photo Source", message: "Where would you like to get your picture from?", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { [unowned self] _ in
            self.showImagePicker(forSourceType: .camera)
        })
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { [unowned self] _ in
            self.showImagePicker(forSourceType: .photoLibrary)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        typePicker.addAction(cameraAction)
        typePicker.addAction(libraryAction)
        typePicker.addAction(cancelAction)
    
        present(typePicker, animated: true)
    }
}

// MARK: - General Keyboard Related Functions
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
        
        scrollView.setContentOffset(CGPoint(x: 0, y: keyboardFrame.height - navigationBarHeight - 11), animated: true)
    }
    
    func scrollToTop(animated: Bool = true) {
        let originalpos: CGPoint = CGPoint(x: 0.0, y: -navigationBarHeight - 20)
        scrollView.setContentOffset(originalpos, animated: animated)
    }
    
    
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
        scrollToTop()
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate Methods
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
        checkFieldsForCompletion()
    }
    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterCountLimit = 30
        
        // Figuring out how many characters the unaltered string would have
        let startingLength = textFieldToChange.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterCountLimit
    }
}

// MARK: - UITextViewDelegate Methods & Related Functions
extension MomentViewController: UITextViewDelegate {
    
    /// Setup code for the main TextView.
    private func configureCaptionTextView() {
        
        // Setting the delegate
        captionTextView.delegate = self
        
        // UI Customization
        captionTextView.layer.cornerRadius = 10
        captionTextView.layer.borderColor = Colours.brown.cgColor
        captionTextView.layer.borderWidth = 0.5
        captionTextView.text = Constants.captionPlaceholderText
        
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
            - 3 * 10 // for the stack view spacing
            - navigationBarHeight
        captionTextView.addConstraint(NSLayoutConstraint(item: captionTextView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: height))
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = false
        
        if (textView.text != nil) && (textView.text == Constants.captionPlaceholderText) {
            textView.text = ""
            textView.textColor = Colours.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == nil) || (textView.text == "") {
            textView.text = Constants.captionPlaceholderText
            textView.textColor = Colours.tan
        } else {
            checkFieldsForCompletion()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Enforcing a character limit on the caption for safety.
        
        // The new state of the text if the change happens
        let newText = (textView.text + text)
        
        // Allowing the change if the text is under or at our limit, and cutting it if it isn't
        if newText.count <= Constants.commentMaxLength {
            return true
        } else {
            
            // This runs if newText.count > Constants.commentsMaxLength
            
            // Then, we're cutting off the string at index: Constants.commentsMaxLength,
            // since strings start indexing at zero, this will give us our proper string.
            textView.text = String(newText[..<newText.index(newText.startIndex, offsetBy: Constants.commentMaxLength)])
            
            return false
        }
    }

}


// MARK: - UIImagePickerControllerDelegate Methods
extension MomentViewController: UIImagePickerControllerDelegate {
    
    // This function is called to check the availability of certain media
    private func showImagePicker(forSourceType sourceType: UIImagePickerControllerSourceType) {
        
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            
            let sourceUnavailbleAlert = UIAlertController()
            
            if sourceType == .camera {
                sourceUnavailbleAlert.title = "Camera Is Inaccessible"
                sourceUnavailbleAlert.message = "To enable access, see Privacy > Camera in the Settings app."
            }
            
            if sourceType == .photoLibrary {
                sourceUnavailbleAlert.title = "Photo Library Is Inaccessible"
                sourceUnavailbleAlert.message = "To enable access, see Privacy > Photos in the Settings app."
            }
            
            sourceUnavailbleAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(sourceUnavailbleAlert,animated: true)
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = sourceType
        self.present(imagePickerController, animated: true, completion: nil)
    }

    // This is called when the user clicks the cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Dismisses the picker
        dismiss(animated: true, completion: nil)
    }
    
    // This is called when the user has picked a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        photoImageView.image = selectedImage
        
        checkFieldsForCompletion()
        
        // Dismisses the picker
        dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - UINavigationController Conformance Addition
extension MomentViewController: UINavigationControllerDelegate {}


