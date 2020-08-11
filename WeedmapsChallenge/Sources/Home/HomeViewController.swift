//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire


class HomeViewController: UIViewController,JSONDelegate,CLLocationManagerDelegate {


    // MARK: Properties
    
    @IBOutlet private var collectionView: UICollectionView!
	private let cellIdentifer = "cell"
	var locationManager: CLLocationManager?
    
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchResults = [Business]()
    private var searchDataTask: URLSessionDataTask?
	var jDel:JSONDelegate?

    // MARK: Lifecycle
    
	fileprivate func setupSearch() {
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search for a business"
		navigationItem.searchController = searchController

	}

	override func viewDidLoad() {
        super.viewDidLoad()
		self.jDel = self
		setupSearch()
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.requestAlwaysAuthorization()
    }

	func reloadData() {
		self.collectionView.reloadData()
	}

	@IBAction func submitPressed(_ sender: Any) {

		guard let lat = locationManager?.location?.coordinate.latitude.description,let long = locationManager?.location?.coordinate.longitude.description else{return}
			let searchQ = "term=\(searchController.searchBar.text!)&latitude=\(lat)&longitude=\(long)"

		networkCall(business: searchQ)
	}

	func networkCall(business:String){
		let endpoint = Networking.searchEndpoint + business

		let endpointUrl = URL(string: endpoint)
		let headers: HTTPHeaders = [
			"Authorization": Networking.authToken,
			"Accept": "application/json"
		]
		Alamofire.request(endpointUrl!,headers:headers).validate().responseJSON { (response) in
			guard response.error == nil else {return}
			//now here we have the response data that we need to parse
			if let jsonData = response.data{
				do{
					//created the json decoder
					let decoder = JSONDecoder()

					//using the array to put values
					let result = try decoder.decode(Root.self, from: jsonData)
					self.searchResults = result.businesses
						self.jDel?.reloadData()

				}catch let err{
					print(err)
				}
			}


		}


	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		//If the user moves from his/her location we will get the location and just print it out, could do more with this if we need to
		if let location = locations.first{
			print(location)
		}
	}


	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .denied {
			//TODO: Fire off a alert message saying we need location services for use of this
			somethingWentWrong()

		}
	}

	func somethingWentWrong(){
		let alertController = UIAlertController(title: "Alert", message: "We want to help you find your nearest store, please turn location service back on", preferredStyle: .alert)


		self.present(alertController, animated: true, completion: nil)
	}

	
}

// MARK: UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        // IMPLEMENT: Be sure to consider things like network errors
        // and possible rate limiting from the Yelp API. If the user types
        // very quickly, how will you prevent unnecessary requests from firing
        // off? Be sure to leverage the searchDataTask and use it wisely!
		guard let text = searchController.searchBar.text else { return }
    }
}

// MARK: UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {

	fileprivate func itemSelected(business:Business) {
		// IMPLEMENT:
		// 1a) Present the user with a UIAlertController (action sheet style) with options
		// to either display the Business's Yelp page in a WKWebView OR bump the user out to
		// Safari. Both options should display the Business's Yelp page details

		let alertController = UIAlertController(title: "Hey there", message: "Do you want to open this in Safari?", preferredStyle: .actionSheet)

		alertController.addAction(UIAlertAction(title: "Open Normal", style: .default, handler: { (alert) in
			//launch webView
			let detailView = HomeDetailViewController()
			detailView.configure(with: business)
			self.navigationController?.pushViewController(detailView, animated: true)
		}))

		alertController.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { (alert) in
			//Ask and then open in Safari
			if let url = URL(string: business.url) {
				UIApplication.shared.open(url)
			}
		}))


		self.present(alertController, animated: true, completion: nil)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let business = searchResults[indexPath.row]
		itemSelected(business: business)
    }
}

// MARK: UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifer, for: indexPath) as! BusinessCell
		let business = searchResults[indexPath.row]
		let defaultImage = UIImage(named: "weedMapsLogo")
		let isTheyOpen:String
		if business.is_closed {
			isTheyOpen = "Open :) "
		}else{
			isTheyOpen = "Closed :( "
		}
		cell.businessName.text = business.name
		cell.businessPhone.text = business.display_phone
		cell.businessImg.image = defaultImage
		cell.status.text = isTheyOpen

		//A little background threading for the image
		DispatchQueue.global(qos: .background).async  {
			let imageString = business.image_url

			guard let url = URL(string: imageString), let data:Data = try? Data(contentsOf: url) else{return}


			//jump to main thread
			DispatchQueue.main.async {
				//set images here
				cell.businessImg.image = UIImage(data: data)
			}
		}

        return cell
    }
}
