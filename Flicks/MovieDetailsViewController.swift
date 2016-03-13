//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Nguyen T Do on 3/11/16.
//  Copyright © 2016 Nguyen Do. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var posterView: UIImageView!   // The image will be set 'aspect to fill' which means will be likely cropted.
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movieSelectedByUser: NSDictionary!   // The movie that user touched from the other view.
    
    func heightForLabelView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.bounds.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let title = movieSelectedByUser["title"] as! String
        titleLabel.text = title
        titleLabel.sizeToFit()   // Some space reserved.
        let overview = movieSelectedByUser["overview"] as! String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        infoView.sizeToFit()

        if let posterPath = movieSelectedByUser["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageURL = NSURL(string: baseUrl + posterPath)
            posterView.setImageWithURL(imageURL!)
            let posterViewHeight = posterView.bounds.height
            print("The poster height is \(posterViewHeight)")
        }

        // overviewLabel height
        let overviewFont = UIFont(name: "Helvetica", size: 17.0)  // Helvetica is acceptable by Nguyen :)
        let text = overviewLabel.text
        let width = overviewLabel.bounds.width
        let overviewLableHeight = heightForLabelView(text!, font: overviewFont!, width: width)
        print("overview label height is \(overviewLableHeight)")
        
        // titleLabel height
        let titleFont = UIFont(name: "Helvetica", size: 19.0)  // Helvetica is acceptable by Nguyen :)
        let titleLabelHeight = heightForLabelView(titleLabel.text!, font: titleFont!, width: titleLabel.bounds.width)
        print("title label height is \(titleLabelHeight)")

        /*
        scrollView width is bounds.width
        scrollView height = posterView + titleLabel + overviewLabel
        Further practice may consider the use of addsubview to solve the unwanted space after the titleLabel.
        
        It's better to create subviews in the scrollview programatically. Try it later on.
        */
        
        scrollView.contentSize = CGSizeMake(scrollView.bounds.width, scrollView.bounds.height + titleLabelHeight * 2 + overviewLableHeight + 45.0)   // Adding an extra 45.0 to make it a better look :)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
