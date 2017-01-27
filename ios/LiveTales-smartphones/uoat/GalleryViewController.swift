//
//  GalleryViewController.swift
//  uoat
//
//  Created by Pyro User on 5/9/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UIGestureRecognizerDelegate, EditedPhotosDelegate
{
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

    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        if( self.isFirstTime )
        {
            self.isFirstTime = false
            self.prepareView()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if( segue.identifier == "showGalleryManagerView" )
        {
            let controller = segue.destinationViewController as! GalleryManagerViewController;
            controller.editedPhotosDelegate = self
        }

    }
    
    func tapPhoto(sender:UITapGestureRecognizer)
    {
        let photo = sender.view as! UIImageView
        self.currentBigPhotoIndex = photo.tag
        
        //Detail photo.
        bigPhotoContainerView = UIView( frame: self.view.bounds )
        
        //Add blur efect to hide the last view.
        let blurEffectView:UIVisualEffectView = Utils.blurEffectView( self.bigPhotoContainerView!, radius: 10 )
        self.bigPhotoContainerView!.addSubview( blurEffectView )
        self.bigPhotoContainerView!.sendSubviewToBack( blurEffectView )
        
        //Big photo.
        let bigPhoto:UIImageView = UIImageView()
        bigPhoto.image = photo.image
        bigPhoto.bounds = CGRect( x:0, y:0, width:Int(self.view.bounds.height*0.5), height:Int(self.view.bounds.width*0.5) )
        bigPhoto.center = self.bigPhotoContainerView!.center
        self.bigPhotoContainerView!.addSubview( bigPhoto )
        
        //Close button.
        let exitBtnImage:UIImage = UIImage( named:"btn_exit" )!
        let closeBigPhotoButton:UIButton = UIButton()
        closeBigPhotoButton.setImage( exitBtnImage, forState:UIControlState.Normal )
        closeBigPhotoButton.bounds = CGRect( x:0, y:0, width:Int(exitBtnImage.size.width*0.5), height:Int(exitBtnImage.size.height*0.5) )
        closeBigPhotoButton.center = CGPoint( x: bigPhoto.frame.origin.x+bigPhoto.bounds.width, y: bigPhoto.frame.origin.y )
        self.bigPhotoContainerView!.addSubview( closeBigPhotoButton )
        closeBigPhotoButton.addTarget( self, action:#selector(GalleryViewController.closeBigPhoto(_:)), forControlEvents:UIControlEvents.TouchUpInside )
        
        self.view.addSubview( self.bigPhotoContainerView! )
        self.isCarrouselMode = true
    }
    
    func closeBigPhoto(sender:UIButton)
    {
        for subview in (self.bigPhotoContainerView?.subviews)!
        {
            subview.removeFromSuperview()
        }
        self.bigPhotoContainerView?.removeFromSuperview()
        self.isCarrouselMode = false
    }
    
    func handleSwipeLeft( gesture: UISwipeGestureRecognizer )
    {
        self.doNextPhoto()
    }
    
    func handleSwipeRight( gesture: UISwipeGestureRecognizer )
    {
        self.doPrevPhoto()
    }
    
    func prevPhoto(sender:UIButton)
    {
        self.doPrevPhoto()
    }

    func nextPhoto(sender:UIButton)
    {
        self.doNextPhoto()
    }
    
    func editPhotos(sender:UIButton)
    {
        self.performSegueWithIdentifier( "showGalleryManagerView", sender:nil )
    }
    
    
    /*=============================================================*/
    /*                   from EditedPhotosDelegate                 */
    /*=============================================================*/
    func updatePhotos()
    {
        self.isFirstTime = true
    }
    
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet var imagesView: [UIImageView]!
    
    @IBOutlet weak var leftArrowNavigationImage: UIImageView!
    @IBOutlet weak var leftNavigationButton: UIButton!

    @IBOutlet weak var rightArrowNavigationImage: UIImageView!
    @IBOutlet weak var rightNavigationButton: UIButton!

    @IBOutlet weak var editButton: UIButton!
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func back(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: {})
    }

    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func prepareView()
    {
        //Reset old values.
        for index in 0..<self.imagesView.count
        {
            self.imagesView[index].image = nil
        }
        
        let documentsURL:NSURL = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains:.UserDomainMask )[0]
        
        do
        {
            self.directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL( documentsURL, includingPropertiesForKeys: nil, options: [])
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
        
        if( self.directoryContents!.count == 0 )
        {
            //No photos to show.
            self.prepareSuggestTakePhotoView()
            
            //Hide navigation buttons.
            self.leftArrowNavigationImage.hidden = true
            self.rightArrowNavigationImage.hidden = true
        }
        else
        {
            //Check elements to prepare view.
            self.pages = self.directoryContents!.count / MAX_ITEMS_BY_PAGE
            self.photosInLastPage = self.directoryContents!.count % MAX_ITEMS_BY_PAGE

            let itemsToShow:Int = ( self.pages > 0 ) ? MAX_ITEMS_BY_PAGE : self.photosInLastPage
            
            self.pages = (self.photosInLastPage == 0) ? self.pages - 1 : self.pages
            
            self.updatePhotosInPage( self.currentPage, itemsToShow:itemsToShow, pages:self.pages )
            
            //Swipe
            self.swipeGestureLeft.delegate = self
            self.swipeGestureRight.delegate = self
            self.swipeGestureLeft.direction = UISwipeGestureRecognizerDirection.Left
            self.swipeGestureRight.direction = UISwipeGestureRecognizerDirection.Right
            self.swipeGestureLeft.addTarget(self, action: #selector(GalleryViewController.handleSwipeLeft(_:)))
            self.swipeGestureRight.addTarget(self, action: #selector(GalleryViewController.handleSwipeRight(_:)))
            self.view.addGestureRecognizer(self.swipeGestureLeft)
            self.view.addGestureRecognizer(self.swipeGestureRight)

            //Left - Right navigation buttons.
            self.leftNavigationButton.addTarget( self, action:#selector(GalleryViewController.prevPhoto(_:)), forControlEvents:UIControlEvents.TouchUpInside )
            self.rightNavigationButton.addTarget( self, action:#selector(GalleryViewController.nextPhoto(_:)), forControlEvents:UIControlEvents.TouchUpInside )
        }
        
        //Edit button.
        self.editButton.addTarget( self, action:#selector(GalleryViewController.editPhotos(_:)), forControlEvents:UIControlEvents.TouchUpInside )
        self.editButton.enabled = ( self.directoryContents!.count > 0 )
    }
    
    private func prepareSuggestTakePhotoView()
    {
        let suggestTakePhotoView:UIView = UIView( frame:CGRect(x:0, y:100, width: self.view.bounds.width, height: self.view.bounds.height-100 ) )
        
        //Label.
        let suggestLabel:UILabel = UILabel()
        suggestLabel.text = Utils.localize( "galleryView.noPhotos" )
        suggestLabel.numberOfLines=2
        suggestLabel.textAlignment = .Center
        suggestLabel.frame = CGRect(x: 0, y: Int(self.view.bounds.height/2)-150, width: Int(self.view.bounds.width), height: 100)
        suggestLabel.backgroundColor = UIColor.whiteColor()
        suggestLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        suggestLabel.textColor = UIColor(red: CGFloat(227/255.0), green: CGFloat(167/255.0), blue: CGFloat(78/255.0), alpha: CGFloat(255/255.0))
        
        suggestTakePhotoView.addSubview( suggestLabel )
        
        self.view.addSubview( suggestTakePhotoView )
    }
    
    private func doPrevPhoto()
    {
        if( self.isCarrouselMode )
        {
            if( ( self.currentBigPhotoIndex - 1 ) >= 0 )
            {
                self.currentBigPhotoIndex -= 1
                (bigPhotoContainerView?.subviews[1] as! UIImageView).image = self.imagesView[self.currentBigPhotoIndex].image
            }
            else
            {
                if( self.currentPage - 1 >= 0 )
                {
                    self.currentPage -= 1
                    self.refreshView()
                    self.currentBigPhotoIndex = MAX_ITEMS_BY_PAGE - 1
                    (bigPhotoContainerView?.subviews[1] as! UIImageView).image = self.imagesView[self.currentBigPhotoIndex].image
                }
            }
        }
        else
        {
            if( self.currentPage - 1 >= 0 )
            {
                self.currentPage -= 1
                self.refreshView()
            }
        }
    }
    
    private func doNextPhoto()
    {
        if( self.isCarrouselMode )
        {
            if( ( ( self.currentBigPhotoIndex + 1 ) < self.imagesView.count ) && ( self.imagesView[self.currentBigPhotoIndex + 1].image != nil ) )
            {
                self.currentBigPhotoIndex += 1
                (bigPhotoContainerView?.subviews[1] as! UIImageView).image = self.imagesView[self.currentBigPhotoIndex].image
            }
            else
            {
                if( self.currentPage + 1 <= self.pages )
                {
                    self.currentPage += 1
                    self.refreshView()
                    (bigPhotoContainerView?.subviews[1] as! UIImageView).image = self.imagesView[self.currentBigPhotoIndex].image
                }
            }
        }
        else
        {
            if( self.currentPage + 1 <= self.pages )
            {
                self.currentPage += 1
                self.refreshView()
            }
        }
    }
    
    private func refreshView()
    {
        //Reset old values.
        for index in 0..<self.imagesView.count
        {
            self.imagesView[index].image = nil
        }
        self.currentBigPhotoIndex = 0

        let itemsToShow:Int = ( self.currentPage < self.pages ) ? MAX_ITEMS_BY_PAGE : self.photosInLastPage
        
        self.updatePhotosInPage( self.currentPage, itemsToShow:itemsToShow, pages:self.pages )
    }
    
    private func updatePhotosInPage( currentPage:Int, itemsToShow:Int, pages:Int )
    {
        var index = MAX_ITEMS_BY_PAGE * currentPage
        for position in 0..<itemsToShow
        {
            let content:NSURL = self.directoryContents![index]
            self.imagesView[position].image = UIImage(contentsOfFile: content.path!)!
            self.imagesView[position].tag = index
            self.imagesView[position].userInteractionEnabled = true
            let tap = UITapGestureRecognizer( target:self, action:#selector(GalleryViewController.tapPhoto(_:)) )
            self.imagesView[position].addGestureRecognizer( tap )
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
            if( currentPage == 0 )
            {
                self.leftArrowNavigationImage.image = self.leftArrowDisableImage
                self.rightArrowNavigationImage.image = self.rightArrowEnableImage
            }
            else if( currentPage == pages )
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
    
    private var isFirstTime:Bool = true
    
    private var leftArrowEnableImage:UIImage? = nil
    private var leftArrowDisableImage:UIImage? = nil
    private var rightArrowEnableImage:UIImage? = nil
    private var rightArrowDisableImage:UIImage? = nil
    
    private var directoryContents:[NSURL]? = nil
    private var isCarrouselMode:Bool = false
    private var currentBigPhotoIndex:Int = 0
    private var bigPhotoContainerView:UIView? = nil
    private let swipeGestureLeft = UISwipeGestureRecognizer()
    private let swipeGestureRight = UISwipeGestureRecognizer()
    
    private var pages:Int = 0
    private var currentPage:Int = 0
    private var photosInLastPage:Int = 0
}
