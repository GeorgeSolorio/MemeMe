//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by George Solorio on 5/26/20.
//  Copyright © 2020 George Solorio. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {

    //MARK: Properties
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // Permission to allow users to edit when adding or looking at a meme
    var permissionToEdit = false
    
    //Accessing memes from AppDelegate
    var memes: [Meme] {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    //MARK: View Controller Cycle functions
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 1.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MemeCell")
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    //MARK: Actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        presentMemeViewController(with: nil, canEdit: true)
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

// MARK:- UICollectionView DataSource
extension MemeCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeCollectionViewIdentifier.cellName, for: indexPath) as! MemeCollectionViewCell
        
        let meme = memes[indexPath.row]
        cell.memeImage.image = meme.memedImage
        return cell
    }
}

//MARK:- UICollectionView Delegate
extension MemeCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentMemeViewController(with: memes[indexPath.row], canEdit: false)
    }
}

//MARK:- MemeViewController Delegate
extension MemeCollectionViewController: MemeViewControllerDelegate {
    
    // Setsup the MemeView controller before it appears on the screen
    func memeViewControllerWillAppear(_ controller: MemeViewController) {
        
        controller.viewTitle.title = permissionToEdit ? "Meme Generator!" : "Your Meme"
        controller.topTextField.isEnabled = permissionToEdit
        controller.bottomTextField.isEnabled = permissionToEdit
        controller.shareButton.isEnabled = !permissionToEdit
        controller.bottomToolBar.isHidden = !permissionToEdit
        controller.permissionToSave = permissionToEdit
    }
    
    func didUpdate() {
        collectionView.reloadData()
    }
    
    func memeViewControllerDidCancel(_ controller: MemeViewController) {
        dismiss(animated: true)
    }
}
