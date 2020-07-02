//
//  ArticleWebPageViewController.swift
//  WakeUp
//

import UIKit
import WebKit

class ArticleWebPageViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    var url: String!
    
    var article: Article? {
        didSet {
            configureURL()
        }
    }
    
    override func loadView() {
        let webConfig = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.uiDelegate = self
        view = webView
    }
    
    func configureURL() {
        if let article = self.article {
            url = article.url
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureURL()
        
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
