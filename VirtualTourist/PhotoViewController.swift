//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/13/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    
    struct Constants{
        static let AlertTitle = "Delete?"
        static let AlertMessage = "Delete the photo from the album?"
        static let AlertDelete = "Delete"
        static let AlertCancel = "Cancel"
        static let DeletePhotoSegue = "DeletePhoto Segue"
    }
    
    
    var photo: Photo?
    
    @IBOutlet var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if photo != nil{
            imageView.image = photo!.photoImage
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteClicked(sender: UIButton) {
        let deleteAlert = UIAlertController(title: Constants.AlertTitle, message: Constants.AlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        deleteAlert.addAction(UIAlertAction(title: Constants.AlertDelete, style: .Default, handler: { (action: UIAlertAction!) in
            self.performSegueWithIdentifier(Constants.DeletePhotoSegue, sender: nil)
        }))
        deleteAlert.addAction(UIAlertAction(title: Constants.AlertCancel, style: .Cancel, handler: nil))
        presentViewController(deleteAlert, animated: true, completion: nil)
    }

    @IBAction func closeClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
