//
//  AppMenuViewController.swift
//  uoat
//
//  Created by Pyro User on 5/5/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class AppMenuViewController: UITableViewController, LibraryDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Add background image.
        let backgroundImage = UIImage( named: "bg_sidebar" )!
        let backgroundImageView = UIImageView( frame: CGRectMake(0,0,backgroundImage.size.width,backgroundImage.size.height) )
        backgroundImageView.image = backgroundImage
        self.view.addSubview( backgroundImageView )
        self.view.sendSubviewToBack( backgroundImageView )
    }

    override func viewDidLayoutSubviews()
    {
        for currentView in self.view.subviews
        {
            if( currentView is UIImageView )
            {
                currentView.frame = CGRectMake(0,0,currentView.bounds.width,self.view.bounds.height)
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if( segue.identifier == "showLanguageView" )
        {
            let controller = segue.destinationViewController as! LanguageViewController
            controller.delegate = self
        }
        else if( segue.identifier == "showLibraryView" )
        {
            let controller = segue.destinationViewController as! LibraryViewController
            controller.delegate = self
        }
        else if( segue.identifier == "showExitView" )
        {
            let controller = segue.destinationViewController as! ExitViewController
            controller.delegate = self
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print("Pulsado:\(indexPath.row)")
        /*
        if( indexPath.row == 3 )
        {
            self.BackToMainMenu();
        }
        */
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = .clearColor()
    }
    
    /*=============================================================*/
    /*                       From ExitDelegate                     */
    /*=============================================================*/
    func onCancel()
    {
        if( self.revealViewController() != nil )
        {
            self.revealViewController().revealToggle( self )
        }
    }
    
    func onExit()
    {
        if( self.revealViewController() != nil )
        {
            self.revealViewController().revealToggle( self )
            let navigationController = self.revealViewController().frontViewController as! UINavigationController
            let controller = navigationController.topViewController as! TaleModeViewController
            controller.onExit()
        }
    }
    
    func onBookChoosen(bookId: String)
    {
        if( self.revealViewController() != nil )
        {
            let navigationController = self.revealViewController().frontViewController as! UINavigationController
            let controller = navigationController.topViewController as! TaleModeViewController
            controller.onChooseOtherTale( bookId )
        }
    }
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var mainMenu: UITableViewCell!
    //---------------------------------------------------------------
    //                            UI Actions
    //---------------------------------------------------------------
    
    
    /*=============================================================*/
    /*                       Private Section                       */
    /*=============================================================*/
    private func Close()
    {
        dismissViewControllerAnimated( true, completion: nil )
    }

    private func BackToMainMenu()
    {
        let alert = UIAlertController( title:"Do you want exit?", message:"Back to main menu", preferredStyle:.Alert )
        //options.
        let actionYes = UIAlertAction( title:"Yes", style:.Default, handler:{ action in
            let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier( "mainViewController" ) as? ViewController
            //self.navigationController?.presentViewController( mainViewController!, animated: true, completion: nil )
            self.presentViewController( mainViewController!, animated: true, completion: nil )
        })
        let actionNo = UIAlertAction( title:"No", style:.Default, handler:{ action in
            self.onCancel()
        })
        alert.addAction( actionYes )
        alert.addAction( actionNo )
        
        presentViewController( alert, animated: true, completion: nil )
    }
}
