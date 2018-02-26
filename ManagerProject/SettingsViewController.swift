//
//  SettingsViewController.swift
//  ManagerProject
//
//  Created by Oleh Busko on 03/08/2017.
//  Copyright © 2017 Oleh Busko. All rights reserved.
//

import UIKit
import Foundation

class SettingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    var selectedIndex = -1
    var selectedTextureIndex: Int?
    let colorsArray:[UIColor] = [UIColor(rgb:0x75B7B7),
                                 UIColor(rgb:0x18447D),
                                 UIColor(rgb:0x5DDE79),
                                 UIColor(rgb:0x9F5DDE),
                                 UIColor(rgb:0xE5C369),
                                 UIColor(rgb:0xE57F69),
                                 UIColor(rgb:0xEEF068),
                                 UIColor(rgb:0xF06897),
                                 UIColor(rgb:0x826971),
                                 UIColor(rgb:0xF5F1F2),
                                 UIColor(rgb:0x423E3F),
                                 UIColor(rgb:0x3C613B)]
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var focusColorCollectionView: UICollectionView!
    
    @IBOutlet weak var textureTwoImageview: UIImageView!
    @IBOutlet weak var textureOneImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        focusColorCollectionView.delegate = self
        focusColorCollectionView.dataSource = self
        
        let itemSize = UIScreen.main.bounds.width/4
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        focusColorCollectionView.collectionViewLayout = layout
        
        let tapGesture1 = UITapGestureRecognizer(target:self, action:#selector(self.selectFirstTexture(_:)))
        let tapGesture2 = UITapGestureRecognizer(target:self, action:#selector(self.selectSecondTexture(_:)))
        textureOneImageView.addGestureRecognizer(tapGesture1)
        textureTwoImageview.addGestureRecognizer(tapGesture2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switchTexture()
    }
    
    @objc func selectFirstTexture(_ sender: UITapGestureRecognizer) {
        selectedTextureIndex = 1
        switchTexture()
    }
    
    @objc func selectSecondTexture(_ sender: UITapGestureRecognizer) {
        selectedTextureIndex = 2
        switchTexture()
    }
    
    func switchTexture() {
        if selectedTextureIndex == 1 {
            textureOneImageView.alpha = 1
            textureTwoImageview.alpha = 0.5
        }else {
            textureOneImageView.alpha = 0.5
            textureTwoImageview.alpha = 1
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @IBAction func backAction(_ sender: Any) {
        let parentViewController = self.presentingViewController as! ViewController
        parentViewController.selectedIndex = selectedIndex
        parentViewController.focusColor = colorsArray[selectedIndex]
        parentViewController.selectedTextureIndex = selectedTextureIndex
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                      for: indexPath) as! CollectionCell
        cell.backgroundColor = colorsArray[indexPath.item]
        cell.alpha = 0.5
        if indexPath.item == selectedIndex {
            cell.alpha = 1
            cell.layer.borderColor = UIColor(rgb:0x4A4D4A).cgColor
            cell.layer.borderWidth = 1.5
            cell.layer.masksToBounds = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndex != -1 {
            let selectedIndexPath = IndexPath(item: selectedIndex, section: 0)
            let selectedCell = self.focusColorCollectionView.cellForItem(at: selectedIndexPath) as! CollectionCell
            selectedCell.alpha = 0.5
            selectedCell.layer.borderWidth = 0
        }
        
        let cell = self.focusColorCollectionView.cellForItem(at: indexPath) as! CollectionCell
        selectedIndex = indexPath.item
        cell.alpha = 1
        cell.layer.borderColor = UIColor(rgb:0x4A4D4A).cgColor
        cell.layer.borderWidth = 1.5
        cell.layer.masksToBounds = true
    }
}
