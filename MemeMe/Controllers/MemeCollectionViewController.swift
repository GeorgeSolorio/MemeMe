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
        
        let memeViewController = storyboard!.instantiateViewController(identifier: "MemeViewController") as! MemeViewController
        
        memeViewController.delegate = self
        
        if let meme = meme {
             memeViewController.meme = meme
        }
        navigationController?.present(memeViewController, animated: true) {
            memeViewController.viewTitle.title = permission ? "Meme Generator!" : "Meme"
            memeViewController.topTextField.isEnabled = permission
            memeViewController.bottomTextField.isEnabled = permission
            memeViewController.shareButton.isEnabled = !permission
            memeViewController.bottomToolBar.isHidden = !permission
        }
    }
}

// MARK:- UICollectionView DataSource
extension MemeCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        
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
    
    func didUpdate() {
        collectionView.reloadData()
    }
    
    func memeViewControllerDidCancel(_ controller: MemeViewController) {
        dismiss(animated: true)
    }
}
