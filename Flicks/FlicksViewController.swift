//
//  FlicksViewController.swift
//  Flicks
//
//  Created by Nguyen T Do on 3/8/16.
//  Copyright © 2016 Nguyen Do. All rights reserved.
//
//  Follow the walkthrough videos
//  Part 1: Create a tableview
//  Part 2: Populate data to that tableview (TMDB API, Network Request, Load data into the tableview)
//  Part 3: Create a Custom tableview Cell
//  Part 4 (the final): 3rd party lib cocoapods
//  Reference: http://cocoapods.wantedly.com

import UIKit
// Command + Shift + K to clean the file
// Then Command + B to build 
// Just to make things talk together and auto-completion to happen for the below import statement
import AFNetworking
import MBProgressHUD

class FlicksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    var dateFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self  // still need to init ourselves
        tableView.delegate = self
        
        /*
        Understanding a UIRefreshControl

        The UIRefreshControl is a subclass of UIView, and consequently a view, so it can be added as a subview to another view. It's behavior and interaction is already built in. UIRefreshControl is a subclass of UIControl, and pulling down on the parent view will initiate a UIControlEventValueChanged event. When the event is triggered, a binded action will be fired. In this action, we update the data source and reset the UIRefreshControl.
        */
        let refreshControl = UIRefreshControl()  // Initialize a UIRefreshControl
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        // Set the name of UINavigationItem correspond to the selected UITab.
        if endpoint == "now_playing" {
            self.navigationItem.title = "Now Playing"
        } else {
            self.navigationItem.title = "Top Rated"
        }
        
        // Set the Navigation Bar background image.
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.setBackgroundImage(UIImage(named: ""), forBarMetrics: .Default)    // Need a better image
            navigationBar.tintColor = UIColor(red: 0.25, green: 0.5, blue: 0.25, alpha: 0.8)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(18),
                NSForegroundColorAttributeName : UIColor(red: 0.5, green: 0.15, blue: 0.15, alpha: 0.8),
                NSShadowAttributeName : shadow
            ]
        }
        
        // Network request: default session + data task.
        let apiKey = "c1f842f9d9837533ecc5b6f71c4b34a9"  // Yes this is my own one.
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made.
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            // Hide HUD once the network request comes back (must be done on main UI thread).
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.networkErrorView.hidden = true
                    }
                }
                else {
                    // Failure case
                    self.networkErrorView.hidden = false
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
        });
        task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {  // movies is an optional.
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        if let posterPath = movie["poster_path"] as? String {   // Just in case no image at all
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageURL = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageURL!)
        }
        
        print("row \(indexPath.row)")
        // print("section \(indexPath.section)")  // only 1 section, when do we have more than 1?

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as UIViewController
        if segue.identifier == "movieDetailsSegue" {  // Eventhough there's only one segue at this time. The segue needs to be named first.
            destinationVC.title = "Details"  // Can also be set in NavigationItem of the destinationVC.
            
            let cell = sender as! UITableViewCell   // The cell the user touched.
            let indexPath = tableView.indexPathForCell(cell)   // Retrive indexPath as it's not in the method in a UITableView protocol.
            let movie = movies![indexPath!.row]
            
            let moviDetailsViewController = destinationVC as! MovieDetailsViewController   // Will moviDetailsViewController be a copy of destinationVC?
            moviDetailsViewController.movieSelectedByUser = movie
            
            // No color when the user selects cell
            cell.selectionStyle = .None
        }
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let apiKey = "c1f842f9d9837533ecc5b6f71c4b34a9"  // Yes this is my own one
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)

        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            // Reload the tableView now that there is new data
                            self.tableView.reloadData()
                            
                            self.networkErrorView.hidden = true
                            
                            // update "last updated" title for refresh control
                            let now = NSDate()
                            let updateString = "Last Updated on " + self.dateFormatter.stringFromDate(now)
                            refreshControl.attributedTitle = NSAttributedString(string: updateString)
                    }
                } else {
                    // Failure case
                    self.networkErrorView.hidden = false
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
    });
        task.resume()
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
