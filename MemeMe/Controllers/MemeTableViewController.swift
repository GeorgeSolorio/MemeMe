//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by George Solorio on 5/26/20.
//  Copyright © 2020 George Solorio. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    //MARK: Properties
    //Accessing memes from AppDelegate
    var memes: [Meme] {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    // Permission to allow users to edit when adding or looking at a meme
    var permissionToEdit = false

    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //MARK: Controller View Cycle Functions
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        presentMemeViewController(with: nil, canEdit: true)
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.isEditing = false
            editButton.title = "Edit"
        } else {
            tableView.isEditing = true
            editButton.title = "Done"
        }
    }
    
    //MARK: Methods
    func presentMemeViewController(with meme: Meme?, canEdit permission: Bool) {
        
        let memeViewController = storyboard!.instantiateViewController(identifier: MemeControllerIdentifier.name) as! MemeViewController
        memeViewController.delegate = self
        if let meme = meme {
             memeViewController.meme = meme
        }

        self.permissionToEdit = permission
        navigationController?.present(memeViewController, animated: true)
    }
}

//MARK:- MemeTableViewController Data Source functions
extension MemeTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MemeTableViewIdentifier.cellName, for: indexPath) as! TableViewCell
        let meme = memes[indexPath.row]
        cell.memeImage.image = meme.memedImage
        cell.textField.text = "\(meme.topText) \(meme.bottomText)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

//MARK:- MemeTableViewController Delegate functions
extension MemeTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentMemeViewController(with: memes[indexPath.row], canEdit: false)
    }
}

//MARK:- MemeControllerView Delegate functions
extension MemeTableViewController: MemeViewControllerDelegate {
    
    // Setsup the MemeView controller before it appears on the screen
    func memeViewControllerWillAppear(_ controller: MemeViewController) {
        controller.viewTitle.title = permissionToEdit ? "Meme Generator!" : "Your Meme"
        controller.topTextField.isEnabled = permissionToEdit
        controller.bottomTextField.isEnabled = permissionToEdit
        controller.shareButton.isEnabled = !permissionToEdit
        controller.bottomToolBar.isHidden = !permissionToEdit
    }
    
    func didUpdate() {
        tableView.reloadData()
    }
    
    func memeViewControllerDidCancel(_ controller: MemeViewController) {
        dismiss(animated: true)
    }

}
