//
//  ViewController.swift
//  MemeMe-V1
//
//  Created by Sagar Choudhary on 28/10/18.
//  Copyright © 2018 Sagar Choudhary. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: meme object
    struct memeObject {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memeImage: UIImage
    }
    
    //MARK: Views
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    //MARK: textField
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    //MARK: Navigation Bar and Toolbar
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    //MARK: Custom Textfield delegate
    let TextFieldDelegate = MemeTextFieldDelegate()

    //MARK: text Attributes
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -4.0]
    
    //MARK: Placeholder Attributes
    let placeHolderTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.white]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = (imageView.image != nil)
        subscribeToKeyboardNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTextField(textField: topTextField, initialText: "TOP", placeholderText: "Enter Top Text")
        initializeTextField(textField: bottomTextField, initialText: "BOTTOM", placeholderText: "Enter Bottom Text")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    //MARK: Initialize textField
    func initializeTextField(textField: UITextField, initialText: String, placeholderText: String) {
        textField.text = initialText
        textField.delegate = TextFieldDelegate
        textField.defaultTextAttributes = memeTextAttributes
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeHolderTextAttributes)
        textField.textAlignment = .center
    }
    
    //MARK: subscribe keyboard notification
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: unsubscribe keyboard notification
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if(bottomTextField.isFirstResponder) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if (bottomTextField.isFirstResponder) {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    //MARK: select from album
    @IBAction func selectImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        if (sender.tag == 0) {
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
        } else {
            imagePicker.sourceType = .camera
        }

        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: cancelImageSelection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: userSelectImage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = image
            shareButton.isEnabled = true
        }
        else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetMeme(_ sender: Any) {
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.isEnabled = false
    }
    
    func saveMeme(memeImage: UIImage) {
        _ = memeObject(
            topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memeImage: memeImage)
    }
    
    //MARK: show/hide Bars
    func hideBars(hide: Bool) {
        navigationBar.isHidden = hide
        toolbar.isHidden = hide
    }
    
    //MARK: Generate meme
    func generateMemeImage() -> UIImage {
        
        //hide top and bottom bars
        hideBars(hide: true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show top and bottom bars
        hideBars(hide: false)

        return memeImage
    }
    
    //MARK: Share Meme
    @IBAction func shareMeme(_ sender: Any) {
        let memeImage = generateMemeImage()
        let shareController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        shareController.completionWithItemsHandler = {
            (activity, success, items, error) in if(success) {
                self.saveMeme(memeImage: memeImage)
            }
        }
        present(shareController, animated: true, completion: nil)
    }
    
}
