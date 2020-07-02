//
//  NewsTableViewController.swift
//  WakeUp
//

import UIKit

private let reuseIdentifier = "articleCell"

class ArticleTableViewCell: UITableViewCell {
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleDescriptionTextView: UITextView!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleSourceLabel: UILabel!
}

/*
extension UIImageView {
    func loadImage(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
*/

class ArticleTableViewController: UITableViewController {
    let newsAPI = NewsAPI()
    var news = News()
    var newsCountry: String = "us"
    var newsCategory: String = "General"
    
    var customNewsCategories: [String] = []
    var customNews: [Article] = []
    var results: Int = 0
    let totalResults: Int = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        fillNews()
    }
    
    func fillNews() {
        if (customNewsCategories.count > 1) {
            let group = DispatchGroup()
            for category in customNewsCategories {
                group.enter()
                newsAPI.fetchTopHeadlines(in: newsCountry, newsCategory: category) { (data) in
                    //let dataString = String(data: data, encoding: .utf8) ?? ""
                    //print(dataString)
                    if let news = self.decodeNews(from: data) {
                        let newsFromCategory = (self.results < news.articles.count) ? Array(news.articles[0...self.results]) : news.articles
                        for article in newsFromCategory { self.customNews.append(article) }
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                print(self.customNews.count)
                self.customNews = self.customNews.shuffled()
                self.news = News(self.customNews)
                self.filterNews()
                print(self.news.articles.count)
                self.loadImages()
                self.tableView.reloadData()
            }
        } else {
            newsAPI.fetchTopHeadlines(in: newsCountry, newsCategory: newsCategory) { (data) in
                //let dataString = String(data: data, encoding: .utf8) ?? ""
                //print(dataString)
                if let news = self.decodeNews(from: data) {
                    self.news = news
                    self.filterNews()
                    //self.printNews()
                }
                self.loadImages()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func decodeNews(from jsonData: Data) -> News?{
        var news: News?
        let decoder = JSONDecoder()
        do {
            news = try decoder.decode(News.self, from: jsonData)
        } catch {
            print(error)
            news = nil
        }
        return news
    }
    
    func printNews() {
        for article in self.news.articles{
            if let source = article.source, let title = article.title, let description = article.description {
                print("\n\(source): \n\(title): \n\(description)")
            }
        }
    }
    
    func filterNews() {
        self.news.articles.removeAll(where: {$0.title == "" || $0.description == "" || $0.urlToImage == ""})
    }
    
    func loadImages(){
        for i in 0..<(self.news.articles.count){
            let myURL = getSecuriedConnection(url: &self.news.articles[i].urlToImage!)
            if let url = URL(string: myURL) {
                if let data = try? Data (contentsOf: url){
                    if let image = UIImage(data: data) {
                        self.news.articles[i].image = image
                    }
                }
            }
        }
    }
    
    func getSecuriedConnection(url: inout String) -> String {
        guard let index = url.firstIndex(of: ":") else {
            url = "https:" + url
            return url
        }
        var transferProtocol = String(url[..<index])
        let endofURL = String(url[index...])
        
        if transferProtocol == "http" {
            transferProtocol = "https"
            url = transferProtocol + endofURL
        }
        return url;
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ArticleTableViewCell

        let article = news.articles[indexPath.row]

        cell.articleTitleLabel?.text = article.title
        cell.articleDescriptionTextView?.text = article.description
        cell.articleImageView?.image = article.image
        cell.articleSourceLabel?.text = "Source: " + article.source!
        
        //let url: URL! = URL(string: article.urlToImage!)
        //cell.articleImageView?.loadImage(url: url)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = backgroundView

        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toArticleWebPage" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let article = news.articles[indexPath.row]
                let articleWebPageViewController = segue.destination as! ArticleWebPageViewController
                articleWebPageViewController.article = article
            }
        }
    }
}
