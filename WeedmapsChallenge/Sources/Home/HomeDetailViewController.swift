//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit
import WebKit


class HomeDetailViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet private var webView: WKWebView!
	
    
    // MARK: Control
    
    func configure(with business: Business) {
        // IMPLEMENT
		let frame = CGRect(x: 0.0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
		webView = WKWebView(frame: frame, configuration: WKWebViewConfiguration())
		super.viewDidLoad()
		view.addSubview(webView)
		if let url = URL(string: business.url) {
			let request = URLRequest(url: url)
			webView.load(request)
		}


    }
}
