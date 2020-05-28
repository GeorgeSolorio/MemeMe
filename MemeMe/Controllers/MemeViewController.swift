//
//  MemeViewController.swift
//  MemeMe
//
//  Created by George Solorio on 5/21/20.
//  Copyright © 2020 George Solorio. All rights reserved.
//

import UIKit

protocol MemeViewControllerDelegate: class {
    func didUpdate()
    func memeViewControllerDidCancel(_ controller: MemeViewController)
    func memeViewControllerWillAppear(_ controller: MemeViewController)
}

class MemeViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var viewTitle: UIBarButtonItem!
    
    var memeTextAttributes: [NSAttributedString.Key: Any]?
    var meme: Meme?
    weak var delegate: MemeViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.memeViewControllerWillAppear(self)
    }
    
    //MARK: MemeViewController Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        memeTextAttributes = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: NSNumber(-3)
        ]
        
        textFieldSetup(for: topTextField, withText: meme?.topText ?? "Top", withAttributes: memeTextAttributes)
        textFieldSetup(for: bottomTextField, withText: meme?.bottomText ?? "Bottom", withAttributes: memeTextAttributes)
        imagePickerView.contentMode = .scaleAspectFill
        if let image = meme?.image {
            imagePickerView.image = image
        }
        shareButton.isEnabled = false
    }

    //MARK:- Methods
    // Atribute set up for text in text field
    func textFieldSetup(for textField: UITextField, withText text: String, withAttributes attributes: [NSAttributedString.Key: Any]?) {
        
        textField.text = text
        textField.delegate = self
        
        if let attributes = attributes {
            textField.defaultTextAttributes = attributes
        }
        textField.textAlignment = .center
    }

    // Enables the save button and creates a memed image that will be saved in memory
    func save(meme image: UIImage) {
        
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image!, memedImage: image)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme!)
        delegate?.didUpdate()
    }

    func generateMemedImage() -> UIImage {
        
        toolBarShould(hide: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        toolBarShould(hide: false)
        return memedImage
    }

    func toolBarShould(hide permission: Bool) {
        topToolBar.isHidden = permission
        bottomToolBar.isHidden = permission
    }

    func presentImagePicker(with sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    //MARK:- Actions
    @IBAction func pickAnImageFromAlbum(_ sender: UIBarButtonItem) {
        presentImagePicker(with: .photoLibrary)
    }

    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        presentImagePicker(with: .camera)
    }

    @IBAction func shareImage(_ sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //Only saves if user shares or saves the image. Populating if user saved image for testing in simulator
        activityViewController.completionWithItemsHandler = { (activity, setup, object, error) in
            switch activity {
            case UIActivity.ActivityType.message, UIActivity.ActivityType.saveToCameraRoll:
                self.save(meme: memedImage)
            default:
                break
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        textFieldSetup(for: topTextField, withText: "Top", withAttributes: memeTextAttributes)
        textFieldSetup(for: bottomTextField, withText: "Bottom", withAttributes: memeTextAttributes)
        imagePickerView.image = nil
        shareButton.isEnabled = false
        delegate?.memeViewControllerDidCancel(self)
    }
}

// MARK:- Keyboard Notification Set Up
extension MemeViewController {
    
    @objc func keyBoardWillShow(_ notification: Notification) {
        view.frame.origin.y = -getKeyBoardHeight(notification)
    }
    
    @objc func keyBoardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyBoardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK:- Text Field delegate
extension MemeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            subscribeKeyboardNotification()
        }
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 1 {
            unsubscribeFromKeyboard()
        }
        return true
    }
}

//MARK:- Image Picker delegate
extension MemeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
