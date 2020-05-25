//
//  MemeViewController.swift
//  MemeMe
//
//  Created by George Solorio on 5/21/20.
//  Copyright © 2020 George Solorio. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController {

   @IBOutlet weak var cameraButton: UIBarButtonItem!
   @IBOutlet weak var imagePickerView: UIImageView!
   @IBOutlet weak var topTextField: UITextField!
   @IBOutlet weak var bottomTextField: UITextField!
   @IBOutlet weak var topToolBar: UIToolbar!
   @IBOutlet weak var bottomToolBar: UIToolbar!
   @IBOutlet weak var shareButton: UIBarButtonItem!
   
   var meme: Meme!
   
   override func viewDidLoad() {
      super.viewDidLoad()

      cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
      textFieldSetup(for: topTextField, withText: "Top")
      textFieldSetup(for: bottomTextField, withText: "Bottom")
      imagePickerView.contentMode = .scaleAspectFill
      shareButton.isEnabled = false
   }
   
   //MARK:- Methods
   // Atribute set up for text in text field
   func textFieldSetup(for textField: UITextField, withText text: String) {
      textField.text = text
      textField.delegate = self
      
      let memeTextAttributes: [NSAttributedString.Key: Any] = [
         NSAttributedString.Key.strokeColor: UIColor.black,
         NSAttributedString.Key.foregroundColor: UIColor.white,
          NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
          NSAttributedString.Key.strokeWidth: NSNumber(-3)
      ]
      
      textField.defaultTextAttributes = memeTextAttributes
      textField.textAlignment = .center
   }
   
   // Enables the save button and creates a memed image that will be saved in memory
   func save() {
      let memedImage = generateMemedImage()
      shareButton.isEnabled = true
      meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image!, memedImage: memedImage)
   }
   
   func generateMemedImage() -> UIImage {
      
      topToolBar.isHidden = true
      bottomToolBar.isHidden = true
      
      UIGraphicsBeginImageContext(self.view.frame.size)
      view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
      let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      
      topToolBar.isHidden = false
      bottomToolBar.isHidden = false
      return memedImage
   }
   
   //MARK:- Actions
   @IBAction func pickAnImageFromAlbum(_ sender: UIBarButtonItem) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      present(imagePicker, animated: true, completion: nil)
   }
   
   @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = .camera
      present(imagePicker, animated: true, completion: nil)
   }
   
   @IBAction func shareImage(_ sender: UIBarButtonItem) {
      
      let activityViewController = UIActivityViewController(activityItems: [meme!.memedImage], applicationActivities: nil)
      present(activityViewController, animated: true, completion: nil)
   }
   
   @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
      textFieldSetup(for: topTextField, withText: "Top")
      textFieldSetup(for: bottomTextField, withText: "Bottom")
      imagePickerView.image = nil
      shareButton.isEnabled = false
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
      }
      
      save()
      dismiss(animated: true)
   }
   
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      
      dismiss(animated: true)
   }
}