//
//  ViewController.swift
//  imagepickerexp
//
//  Created by Shravan Sukumar on 15/04/16.
//  Copyright © 2016 shravan. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate //UITableViewDelegate
{
    
    /*func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        <#code#>
    }*/
    var meme : Meme!

    
    @IBOutlet var topToolBar: UINavigationBar!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var bottomToolBar: UIToolbar!
    @IBOutlet var imagePickerView: UIImageView!
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.enabled = false
        
        func prepareTextField(textField: UITextField, defaultText: String) {
            super.viewDidLoad()
            let memeTextAttributes = [
                NSStrokeColorAttributeName : UIColor.blackColor(),
                NSForegroundColorAttributeName : UIColor.whiteColor(),
                NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                NSStrokeWidthAttributeName : -3.0
            ]
            textField.delegate = self
            textField.defaultTextAttributes = memeTextAttributes
            textField.text = defaultText
            textField.autocapitalizationType = .AllCharacters
            textField.textAlignment = .Center
        }
        
        prepareTextField(topTextField, defaultText: "TOP")
        prepareTextField(bottomTextField, defaultText: "BOTTOM")
        
    
        
        //Method for aligning the text in textfields
        func textAlign(textField: UITextField) {
            return textField.textAlignment = NSTextAlignment.Center
        }
        
        textAlign(topTextField)
        textAlign(bottomTextField)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true     // status bar should be hidden
    }
    

    
    //Method to be called when the textfield begins to be edited
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        subscribeToKeyboardNotificatons()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    //Method to save an image
    func save(memedImage: UIImage) {
         meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: memedImage, memedImage: memedImage)
    }
    //To combine both the textfields and the image
    func generatedMemedImage() -> UIImage {

        bottomToolBar.hidden = true
        topToolBar.hidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        bottomToolBar.hidden = false
        topToolBar.hidden = false
        return memedImage
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotificatons() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        if bottomTextField.isFirstResponder() {
        view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification : NSNotification ) {
        if bottomTextField.isFirstResponder() {
        view.frame.origin.y = 0
        }
    }
    //When return key is pressed while using the textfield
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        return true
    }

    //To pick an image using the imagePicker
    func imagePickerController(picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : AnyObject]){
        dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
    }
    
    func  imagePickerControllerDidCancel(picker: UIImagePickerController){
        dismissViewControllerAnimated(true, completion: nil)

    }
    
    //Method to call when the share button is pressed
    func shareButtonWhenTapped(image: UIImage) {
        let nextController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        nextController.completionWithItemsHandler = { action, success,items, error in
            if success {
                self.save(image)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        presentViewController(nextController, animated: true, completion: nil)
    }
    
    //On tapping the share button, the method 'shareButtonWhenTapped' is called
    @IBAction func shareWhenPerformingAction(sender: AnyObject) {
        shareButtonWhenTapped(generatedMemedImage())
        
    }
    
    
    //To determine if the image is from camera or photo library
    /*func sourceForImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
        shareButton.enabled = true
    
            switch (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            
            case true:
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                
     
            case false:
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                
                
                
            }
        }*/
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        //sourceForImage()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
        shareButton.enabled = true
        imagePicker.sourceType = .PhotoLibrary
        
        
    }
    
   
    //To reset the complete meme editor, if the user is not happy with the meme
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        shareButton.enabled = false
    }
    
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        //sourceForImage()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
        shareButton.enabled = true
        imagePicker.sourceType = .Camera
        
    }

}

