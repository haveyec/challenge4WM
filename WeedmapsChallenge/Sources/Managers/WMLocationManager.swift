//
//  LocationManager.swift
//  WeedmapsChallenge
//
//  Created by Havic on 8/8/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import UIKit
import CoreLocation

class WMLocationManager: UIViewController,  CLLocationManagerDelegate{
	var locationManager: CLLocationManager?

	override func viewDidLoad() {
		super.viewDidLoad()
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.requestAlwaysAuthorization()
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
