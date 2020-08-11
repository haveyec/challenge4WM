//
//  NetworkLayer.swift
//  WeedmapsChallenge
//
//  Created by Havic on 8/9/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation
import Alamofire

protocol JSONDelegate {
	func reloadData()
}

struct Networking {
	static let authToken = "Bearer SpHp4B1tIRGSzhA9IWUCVbfCqHTRwJNTGxIvRR8TA9eP_-m-jm4-HInj2P6OGwW8DrqsFk6SKtXh_DS0aERIecNPPh0m1SoBXQRYUTKLFQUGLvfpHe5kw-EgWNa4XHYx"
	static let searchEndpoint = "https://api.yelp.com/v3/businesses/search?"
}
