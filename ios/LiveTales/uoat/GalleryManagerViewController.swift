//
//  GalleryManagerViewController.swift
//  uoat
//
//  Created by Pyro User on 5/9/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class GalleryManagerViewController: UIViewController, UIGestureRecognizerDelegate
{
    weak var editedPhotosDelegate:EditedPhotosDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //load resources.
        self.leftArrowEnableImage = Utils.flipImage( named: "btn_next_available", orientation: .Down )
        self.leftArrowDisableImage = Utils.flipImage( named: "btn_next_idle", orientation: .Down )
        self.rightArrowEnableImage = UIImage( named: "btn_next_available" )
        self.rightArrowDisableImage = UIImage( named: "btn_next_idle" )
        
        //.:Back button
        self.leftArrowImage.image = self.leftArrowEnableImage
        
        //.:Left navigation button.
        self.leftArrowNavigationImage.image = self.leftArrowEnableImage
        
        //Head title.
        let headAttrString = NSMutableAttributedString(string: self.headerLabel.text!,
                                                       attributes: [NSStrokeWidthAttributeName: -7.0,
                                                        NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 22)!,
                                                        NSStrokeColorAttributeName: UIColor.whiteColor(),
                                                        NSForegroundColorAttributeName: self.headerLabel.textColor ])
        self.headerLabel.attributedText! = headAttrString
        
        self.prepareView()
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }
    
    func tapPhoto(sender:UITapGestureRecognizer)
    {
        let checkedPhoto = sender.view as! UIImageView
        print("PHOTO SELECTED: \(checkedPhoto.tag)")
        
        if( !self.photosSelected[checkedPhoto.tag] )
        {
            checkedPhoto.image = UIImage(named: "checkbox_checked")
            photosSelectedCount += 1
            self.deleteButton.enabled = true
            self.saveButton.enabled = true
            self.cancelButton.enabled = true
        }
        else
        {
            checkedPhoto.image = UIImage(named: "checkbox_unchecked")
            photosSelectedCount -= 1
            self.deleteButton.enabled = ( photosSelectedCount > 0 )
            self.saveButton.enabled = ( photosSelectedCount > 0 )
            self.cancelButton.enabled = (photosSelectedCount > 0 )
        }
        self.photosSelected[checkedPhoto.tag] = !self.photosSelected[checkedPhoto.tag]
    }
    
    func handleSwipeLeft( gesture: UISwipeGestureRecognizer )
    {
        self.doNextPage()
    }
    
    func handleSwipeRight( gesture: UISwipeGestureRecognizer )
    {
        self.doPrevPage()
    }
    
    func prevPage(sender:UIButton)
    {
        self.doPrevPage()
    }
    
    func nextPage(sender:UIButton)
    {
        self.doNextPage()
    }
    
    func removePhotos(sender:UIButton)
    {
        var stateOk:Bool = true
        for index in 0..<self.photosSelected.count
        {
            if( self.photosSelected[index] )
            {
                let content:NSURL = self.directoryContents![index]
                stateOk = stateOk && self.removePhotoWithPath( content.path! )
            }
        }
        
        if( !stateOk )
        {
            Utils.alertMessage(self, title: "Error", message: "Sorry, but some files couldn't be removed!", onAlertClose: { [unowned self](action) in
                    self.prepareView()
            })
        }
        else
        {
            Utils.alertMessage(self, title: "Remove photos", message: "Your photos have been removed!", onAlertClose:{ [unowned self](action) in
                self.prepareView()
            })
        }
    }
    
    func savePhotos(sender:UIButton)
    {
        var stateOk:Bool = true
        for index in 0..<self.photosSelected.count
        {
            if( self.photosSelected[index] )
            {
                //let image:UIImage = UIImage( data:UIImageJPEGRepresentation( self.imagesView[index].image!,1.0 )! )!
                
                let content:NSURL = self.directoryContents![index]
                let image:UIImage
                //get image in current page
                if( index / MAX_ITEMS_BY_PAGE == self.currentPage )
                {
                    let position:Int = index % MAX_ITEMS_BY_PAGE
                    //self.checkboxesView[position].image = UIImage(named: "checkbox_unchecked")
                    image = UIImage( data:UIImageJPEGRepresentation( self.imagesView[position].image!,1.0 )! )!
                }
                else
                {
                    
                    let imageTmp:UIImage = UIImage(contentsOfFile: content.path!)!
                    image = UIImage( data:UIImageJPEGRepresentation( imageTmp, 1.0 )! )!
                }
                
                //let content:NSURL = self.directoryContents![index]
                if( self.removePhotoWithPath( content.path! ) )
                {
                    UIImageWriteToSavedPhotosAlbum( image, nil, nil, nil)
                }
                else
                {
                    stateOk = false
                }
            }
        }
        
        if( !stateOk )
        {
            Utils.alertMessage(self, title: "Error", message: "Sorry, but some files couldn't be removed!", onAlertClose: { [unowned self](action) in
                    self.prepareView()
            })
        }
        else
        {
            Utils.alertMessage(self, title: "Save photos", message: "Your photos have been move to album device", onAlertClose:{ [unowned self](action) in
                self.prepareView()
            })
        }
    }

    
    func cancelSelectedPhotos(sender: UIButton)
    {
        for index in 0..<self.photosSelected.count
        {
            print("Cleaning...\(index)")
            
            self.photosSelected[index] = false
            
            //uncheck in current page
            if( index / MAX_ITEMS_BY_PAGE == self.currentPage )
            {
                let position:Int = index % MAX_ITEMS_BY_PAGE
                self.checkboxesView[position].image = UIImage(named: "checkbox_unchecked")
            }
        }
        photosSelectedCount = 0
        self.deleteButton.enabled = false
        self.saveButton.enabled = false
        self.cancelButton.enabled = false
    }

    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var leftArrowNavigationImage: UIImageView!
    @IBOutlet weak var leftNavigationButton: UIButton!
    
    @IBOutlet weak var rightArrowNavigationImage: UIImageView!
    @IBOutlet weak var rightNavigationButton: UIButton!
    
    @IBOutlet var imagesView: [UIImageView]!
    @IBOutlet var checkboxesView: [UIImageView]!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func back(sender: UIButton)
    {
        self.editedPhotosDelegate?.updatePhotos()
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func prepareView()
    {
        //Reset old values.
        self.photosSelected.removeAll()
        for index in 0..<self.imagesView.count
        {
            self.imagesView[index].image = nil
            self.checkboxesView[index].image = UIImage(named: "checkbox_unchecked")
            self.checkboxesView[index].hidden = true
        }
        
        let documentsURL:NSURL = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains:.UserDomainMask )[0]
        
        do {
            self.directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL( documentsURL, includingPropertiesForKeys: nil, options: [])
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
        
        for _ in 0..<self.directoryContents!.count
        {
            self.photosSelected.append(false)
        }
        
        //Check elements to prepare view.
        self.pages = self.directoryContents!.count / MAX_ITEMS_BY_PAGE
        self.photosInLastPage = self.directoryContents!.count % MAX_ITEMS_BY_PAGE
        
        let itemsToShow:Int
        if( self.currentPage == self.pages )
        {
            itemsToShow = self.photosInLastPage
        }
        else
        {
            itemsToShow = ( self.pages > 0 ) ? MAX_ITEMS_BY_PAGE : self.photosInLastPage
        
            if( self.photosInLastPage == 0 )
            {
                self.pages -= 1
                self.currentPage = (self.currentPage > 0) ? self.currentPage - 1 : 0
            }
        }
        
        self.updatePhotosInPage( self.currentPage, itemsToShow:itemsToShow, pages:self.pages )
        
        //Swipe
        self.swipeGestureLeft.delegate = self
        self.swipeGestureRight.delegate = self
        self.swipeGestureLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.swipeGestureRight.direction = UISwipeGestureRecognizerDirection.Right
        self.swipeGestureLeft.addTarget(self, action: #selector(GalleryManagerViewController.handleSwipeLeft(_:)))
        self.swipeGestureRight.addTarget(self, action: #selector(GalleryManagerViewController.handleSwipeRight(_:)))
        self.view.addGestureRecognizer(self.swipeGestureLeft)
        self.view.addGestureRecognizer(self.swipeGestureRight)
        
        //Left - Right navigation button.
        self.leftNavigationButton.addTarget( self, action:#selector(GalleryManagerViewController.prevPage(_:)), forControlEvents:UIControlEvents.TouchUpInside )
        self.rightNavigationButton.addTarget( self, action:#selector(GalleryManagerViewController.nextPage(_:)), forControlEvents:UIControlEvents.TouchUpInside )
        
        //Delete button.
        self.deleteButton.enabled = false
        self.deleteButton.addTarget( self, action:#selector(GalleryManagerViewController.removePhotos(_:)), forControlEvents:UIControlEvents.TouchUpInside )
        
        //Save button.
        self.saveButton.enabled = false
        self.saveButton.addTarget( self, action:#selector(GalleryManagerViewController.savePhotos(_:)), forControlEvents:UIControlEvents.TouchUpInside )
        
        //Cancel button.
        self.cancelButton.enabled = false
        self.cancelButton.addTarget( self, action:#selector(GalleryManagerViewController.cancelSelectedPhotos(_:)), forControlEvents:UIControlEvents.TouchUpInside )
    }
    
    private func removePhotoWithPath(path:String) -> Bool
    {
        var removedOk:Bool = true
        do
        {
            try NSFileManager.defaultManager().removeItemAtPath( path )
        }
        catch let error as NSError
        {
            print( error.localizedDescription )
            removedOk = false
        }
        
        return removedOk
    }
    
    private func doPrevPage()
    {
        if( self.currentPage - 1 >= 0 )
        {
            self.currentPage -= 1
            self.refreshView()
        }
    }
    
    private func doNextPage()
    {
        if( self.currentPage + 1 <= self.pages )
        {
            self.currentPage += 1
            self.refreshView()
        }
    }
    
    private func refreshView()
    {
        //Reset old values.
        for index in 0..<self.imagesView.count
        {
            self.imagesView[index].image = nil
            self.checkboxesView[index].image = UIImage(named: "checkbox_unchecked")
            self.checkboxesView[index].hidden = true
        }
        
        let itemsToShow:Int = ( self.currentPage < self.pages ) ? MAX_ITEMS_BY_PAGE : self.photosInLastPage
        
        self.updatePhotosInPage( self.currentPage, itemsToShow:itemsToShow, pages:self.pages )
    }
    
    private func updatePhotosInPage(currentPage:Int, itemsToShow:Int, pages:Int)
    {
        var index = MAX_ITEMS_BY_PAGE * currentPage
        for position in 0..<itemsToShow
        {
            let content:NSURL = self.directoryContents![index]
            
            self.imagesView[position].image = UIImage(contentsOfFile: content.path!)!
            self.imagesView[position].tag = index
            let tap = UITapGestureRecognizer( target:self, action:#selector(GalleryManagerViewController.tapPhoto(_:)) )
            self.checkboxesView[position].tag = index
            self.checkboxesView[position].userInteractionEnabled = true
            self.checkboxesView[position].addGestureRecognizer( tap )
            self.checkboxesView[position].hidden = false
            
            if( self.photosSelected[index] )
            {
                self.checkboxesView[position].image = UIImage(named: "checkbox_checked")
            }
            index += 1
        }
        
        //Navigation buttons.
        if( pages == 0 )
        {
            self.leftArrowNavigationImage.image = self.leftArrowDisableImage
            self.rightArrowNavigationImage.image = self.rightArrowDisableImage
        }
        else
        {
            if( self.currentPage == 0 )
            {
                self.leftArrowNavigationImage.image = self.leftArrowDisableImage
                self.rightArrowNavigationImage.image = self.rightArrowEnableImage
            }
            else if( self.currentPage == pages )
            {
                self.leftArrowNavigationImage.image = self.leftArrowEnableImage
                self.rightArrowNavigationImage.image = self.rightArrowDisableImage
            }
            else
            {
                self.leftArrowNavigationImage.image = self.leftArrowEnableImage
                self.rightArrowNavigationImage.image = self.rightArrowEnableImage
            }
        }
    }
    
    private let MAX_ITEMS_BY_PAGE = 15
    
    private var leftArrowEnableImage:UIImage? = nil
    private var leftArrowDisableImage:UIImage? = nil
    private var rightArrowEnableImage:UIImage? = nil
    private var rightArrowDisableImage:UIImage? = nil
    
    private var directoryContents:[NSURL]? = nil
    private let swipeGestureLeft = UISwipeGestureRecognizer()
    private let swipeGestureRight = UISwipeGestureRecognizer()
    private var photosSelected:[Bool] = [Bool]()
    private var photosSelectedCount:Int = 0
    
    private var pages:Int = 0
    private var currentPage:Int = 0
    private var photosInLastPage:Int = 0
}
