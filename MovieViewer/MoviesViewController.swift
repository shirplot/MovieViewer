//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Shirley Plotnik on 1/24/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    
    var movies: [NSDictionary]?
    var data: [String]?
    var overviewData: [String]?
    var posterData: [String]?
    var filteredData: [String]!
    var filteredOverviewData: [String]!
    var filteredPosters: [String]!
    var totalIndexes: [Int]?
    var filteredIndexes: [Int]!
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HideCells()
        ShowCells()
       
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
    collectionView.dataSource = self
    collectionView.delegate = self
    searchBar.delegate = self
    //filteredData = data
        
       flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        
        
        
        
        

        // Do any additional setup after loading the view.
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                // Hide HUD once the network request comes back (must be done on main UI thread)
                
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //print("response: \(responseDictionary)")
                            
                            self.movies = (responseDictionary["results"] as? [NSDictionary])
                            var MovieTitles: [String] = []
                            var MovieOverview: [String] = []
                            var MoviePosters: [String] = []
                            var MovieIndexes: [Int] = []
                            for var index = 0; index < self.movies!.count; ++index {
                                let MovieInfo = self.movies![index] as NSDictionary
                                MovieTitles.append(MovieInfo["title"] as! String)
                                MovieOverview.append(MovieInfo["overview"] as! String)
                                MoviePosters.append(MovieInfo["poster_path"] as! String)
                                MovieIndexes.append(index)
                            
                    }
                            self.data = MovieTitles
                            self.filteredData = self.data
                            
                            self.overviewData = MovieOverview
                            self.filteredOverviewData = self.overviewData
                            
                            self.posterData=MoviePosters
                            self.filteredPosters = self.posterData
                            
                            self.totalIndexes = MovieIndexes
                            self.filteredIndexes = self.totalIndexes
                            
                            self.collectionView.reloadData()
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                }
                
        })
        task.resume()
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredData = filteredData {
            networkErrorLabel.hidden = true
            return filteredData.count
        } else {
            networkErrorLabel.hidden = false
            return 0
        }
    }
    
    
    /*func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        if let movies = movies {
            return movies.count
        } else{ return 0}*/
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    
        return 2
    }
        
        
        
        
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell1", forIndexPath: indexPath) as! MovieCell1
        let posterPath = filteredPosters[indexPath.row]
        let baseUrl = "http://image.tmdb.org/t/p/w342"
        let imageUrl = NSURL( string: baseUrl + posterPath)
       // cell.titleLabel.text = filteredData[indexPath.row]
        //cell.overviewLabel.text = filteredOverviewData[indexPath.row]
        cell.PosterView.setImageWithURL(imageUrl!)
        let imageRequest = NSURLRequest(URL: imageUrl!)
        //let title = movie["title"] as! String
       // let overview = movie["overview"] as! String
        
        //cell.titleLabel.text = title
        //cell.overviewLabel.text = overview
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.grayColor()
        cell.selectedBackgroundView = backgroundView
    

cell.PosterView.setImageWithURLRequest(imageRequest,
    placeholderImage: nil,
    success: { (imageRequest, imageResponse, image) -> Void in
        
        // imageResponse will be nil if the image is cached
        if imageResponse != nil {
            print("Image was NOT cached, fade in image")
            cell.PosterView.alpha = 0.0
            cell.PosterView.image = image
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                cell.PosterView.alpha = 1.0
            })
        } else {
            print("Image was cached so just update the image")
            cell.PosterView.image = image
        }
    },
    failure: { (imageRequest, imageResponse, error) -> Void in
        // do something for the failure condition
})


        print("row \(indexPath.row)")
        return cell

    }
    
    // MARK: UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let totalwidth = collectionView.bounds.size.width;
        let numberOfCellsPerRow = 3
        let oddEven = indexPath.row / numberOfCellsPerRow % 2
        let dimensions = CGFloat(Int(totalwidth) / numberOfCellsPerRow)
        if (oddEven == 0) {
            return CGSizeMake(dimensions, dimensions)
        } else {
            return CGSizeMake(dimensions, dimensions / 2)
        }
    }

func refreshControlAction(refreshControl: UIRefreshControl) {
    
    // ... Create the NSURLRequest (myRequest) ...
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
    let request = NSURLRequest(
        URL: url!,
        cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
        timeoutInterval: 10)
    
    // Configure session so that completion handler is executed on main UI thread
    let session = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate:nil,
        delegateQueue:NSOperationQueue.mainQueue()
    )
    
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
        completionHandler: { (data, response, error) in
            
            // ... Use the new data to update the data source ...
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
    });
    task.resume()
    
    
}



// This method updates filteredData based on the text in the Search Box
func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    // When there is no text, filteredData is the same as the original data
    if searchText.isEmpty {
        filteredData = data
        filteredOverviewData = overviewData
        filteredPosters = posterData
        filteredIndexes = totalIndexes
        
    } else {
        // The user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        
        
        var tempTitleList: [String] = []
        var tempPosterList: [String] = []
        var tempOverviewList: [String] = []
        // Go through each element in data
        for var filterIndex = 0; filterIndex < data!.count; ++filterIndex {
            
            // For each that matches the filter
            
            if data![filterIndex].containsString(searchText) {
                // Add index to temporary list
                tempPosterList.append(posterData![filterIndex])
                tempTitleList.append(data![filterIndex])
                tempOverviewList.append(overviewData![filterIndex])
                
                print("a match!")
            }
        }
        // Change filtered list to temporary list
        filteredData = tempTitleList
        filteredPosters = tempPosterList
        filteredOverviewData = tempOverviewList
        
    }
    collectionView.reloadData()
}
func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    self.searchBar.showsCancelButton = true
}
func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.text = ""
    searchBar.resignFirstResponder()
}

func ShowCells(){
    UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations:{
        self.collectionView.alpha = 1
        }, completion: nil)
}

func HideCells(){
    UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations:{
        self.collectionView.alpha = 0
        }, completion: nil)
}






    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue")
    
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}



