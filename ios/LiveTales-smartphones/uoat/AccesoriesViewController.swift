//
//  AccesoriesViewController.swift
//  uoat
//
//  Created by Pyro User on 20/7/16.
//  Copyright © 2016 Zed. All rights reserved.
//

import UIKit

class AccesoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var pack:String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Title header.
        let mutableAttrString = NSMutableAttributedString(string: headerLabel.text!,
                                        attributes: [NSStrokeWidthAttributeName: -7.0,
                                        NSFontAttributeName: UIFont(name: "ArialRoundedMTBold", size: 24)!,
                                        NSStrokeColorAttributeName: UIColor.whiteColor(),
                                        NSForegroundColorAttributeName: headerLabel.textColor ])
        headerLabel.attributedText! = mutableAttrString
        
        //Add blur efect to hide the last view.
        let blurEffectView:UIVisualEffectView = Utils.blurEffectView(self.view, radius: 10)
        self.view.addSubview(blurEffectView)
        self.view.sendSubviewToBack(blurEffectView)
        
        //Prepare complements by packs or show all.
        if( pack == nil )
        {
            let complementsByPack:[String:[Complement]] = AccesoriesMgr.getInstance().getAll()
            for item in complementsByPack
            {
                for complement in item.1
                {
                    self.complements.append( complement )
                }
            }
        }
        else
        {
            self.complements = AccesoriesMgr.getInstance().getByPack( self.pack! )
        }
        
        self.accesoriesTableView.delegate = self
        self.accesoriesTableView.dataSource = self
    }

    override func viewDidLayoutSubviews()
    {
        let x:Int = Int(self.view.bounds.width)/2 - Int(self.complementContainerView.bounds.width)/2
        let y:Int = Int(self.view.bounds.height)/2 - Int(self.complementContainerView.bounds.height)/2
        
        self.complementContainerView.frame = CGRect(x: x, y: y, width: Int(self.complementContainerView.frame.width), height: Int(self.complementContainerView.frame.height))
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func willCheckAccesory(sender:UIButton)
    {
        let index = sender.tag
        let imgName = self.complements[index].id
        let pack:String = self.complements[index].pack
        
        print("Seleccionado \(imgName) - pos:\(index)")
        
        self.dismissViewControllerAnimated( true, completion:{} )

        let message = Message(type:MessageType.changeAccesory,data:["accesoryId":imgName,"pack":pack]);
        Observer.getInstance.sendMessage( message );
    }

    
    /*=============================================================*/
    /*                  from UITableViewDataSource                 */
    /*=============================================================*/
    func numberOfSectionsInTableView(tableView:UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        var rows = (self.complements.count / ITEMS_BY_ROW)
        rows = ( ( self.complements.count % ITEMS_BY_ROW) > 0 ) ? rows + 1 : rows
        return rows
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier( self.cellIdentifier, forIndexPath:indexPath ) as! AccesoriesTableViewCell
        let row = indexPath.row
        
        let initPos:Int = row * ITEMS_BY_ROW
        //let items:Int = 4
        var i:Int = 0
        for index:Int in initPos...(initPos+ITEMS_BY_ROW-1)
        {
            if( index < self.complements.count )
            {
                let complement:Complement = self.complements[index]
                
                let accesoryButton:UIButton
                let accesoryImageView:UIImageView
                
                if( i == 0 )
                {
                    accesoryButton = cell.accesoryButtom1
                    accesoryImageView = cell.accesoryImageView1
                }
                else if( i == 1)
                {
                    accesoryButton = cell.accesoryButtom2
                    accesoryImageView = cell.accesoryImageView2
                }
                else if( i == 2 )
                {
                    accesoryButton = cell.accesoryButtom3
                    accesoryImageView = cell.accesoryImageView3
                }
                else
                {
                    accesoryButton = cell.accesoryButtom4
                    accesoryImageView = cell.accesoryImageView4
                }
                accesoryButton.hidden = false
                accesoryImageView.hidden = false
            
                if( accesoryImageView.image == nil )
                {
                    let img:UIImage = UIImage( contentsOfFile:complement.imagePath )!
                    images[complement.id] = img
                    accesoryImageView.image = img
                }
                else
                {
                    if( images[complement.id] == nil )
                    {
                        images[complement.id] = UIImage( contentsOfFile:complement.imagePath )!
                    }
                    accesoryImageView.image = images[complement.id]

                }
                
                if( accesoryButton.allTargets().isEmpty )
                {
                    accesoryButton.addTarget(self, action:  #selector(AccesoriesViewController.willCheckAccesory(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                }
                
                accesoryButton.tag = index
                i += 1
            }
            else
            {
                let accesoryButton:UIButton
                let accesoryImageView:UIImageView
                
                if( i == 0 )
                {
                    accesoryButton = cell.accesoryButtom1
                    accesoryImageView = cell.accesoryImageView1
                }
                else if( i == 1)
                {
                    accesoryButton = cell.accesoryButtom2
                    accesoryImageView = cell.accesoryImageView2
                }
                else if( i == 2 )
                {
                    accesoryButton = cell.accesoryButtom3
                    accesoryImageView = cell.accesoryImageView3
                }
                else
                {
                    accesoryButton = cell.accesoryButtom4
                    accesoryImageView = cell.accesoryImageView4
                }
                
                accesoryButton.hidden = true
                accesoryImageView.hidden = true
                i += 1
            }
        }
        
        return cell
    }
    
    
    /*=============================================================*/
    /*                   from UITableViewDelegate                  */
    /*=============================================================*/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = .clearColor()
    }
    
    
    /*=============================================================*/
    /*                          UI Section                         */
    /*=============================================================*/
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var complementContainerView: UIView!
    @IBOutlet weak var accesoriesTableView: UITableView!
    
    //---------------------------------------------------------------
    //                         UI Actions
    //---------------------------------------------------------------
    @IBAction func close(sender: UIButton)
    {
        self.dismissViewControllerAnimated( true, completion:{} )
    }
    
    
    /*=============================================================*/
    /*                        Private Section                      */
    /*=============================================================*/
    private let ITEMS_BY_ROW:Int = 4
    private let cellIdentifier:String = "AccesoriesTableViewCell"
    private var complements:[Complement] = []
    private var images:[String:UIImage] = [String:UIImage]()
}
