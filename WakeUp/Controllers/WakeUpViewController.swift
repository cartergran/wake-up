//
//  WakeUpViewController.swift
//  WakeUp
//

import UIKit
import CoreData

private let reuseIdentifier = "categoryCell"

class NewsCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var newsCategoryImageView: UIImageView!
    @IBOutlet weak var newsCategoryLabel: UILabel!
    
    override var isSelected: Bool {
        didSet{
            if isSelected{
                self.layer.borderColor = UIColor.blue.cgColor
                self.layer.borderWidth = 1

            } else {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 1
            }
        }
    }
}

class WakeUpViewController: UIViewController {
    @IBOutlet weak var newsCategoryCollectionView: UICollectionView!
    
    @IBOutlet weak var featureView: UIView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var gameImageView: UIImageView!
    
    var newsCategories = [NewsCategory]()
    var customNewsCategories: [String] = []
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var managedObjects: [NSManagedObject] = []
    var savedNewsCategories: [String] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCV()
        setUpFeatures()
        fillCategories()
        fillSavedCategories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearSavedCategories()
        saveCustomCategories()
    }
    
    func setUpCV() {
        newsCategoryCollectionView.allowsMultipleSelection = true
    }
    
    func setUpFeatures() {
        let frameSize = featureView.frame.size.width / 2.5
        
        weatherImageView.image = UIImage(named: "weather")
        weatherImageView.frame.size.width = frameSize
        weatherImageView.frame.size.height = frameSize
        
        let xWeather = featureView.frame.size.width / 4
        let yWeather = featureView.frame.size.height / 2
        weatherImageView.center = CGPoint(x: xWeather, y: yWeather)
        
        weatherImageView.layer.cornerRadius = 20
    
        gameImageView.image = UIImage(named: "questionMark")
        gameImageView.frame.size.width = frameSize
        gameImageView.frame.size.height = frameSize
        
        let xGame = (featureView.frame.size.width / 4) * 3
        let yGame = featureView.frame.size.height / 2
        gameImageView.center = CGPoint(x: xGame, y: yGame)
        
        gameImageView.layer.cornerRadius = 20
    }
    
    func fillCategories() {
        let categories = [NewsCategory(name: "Sports", image: UIImage(named: "sportsCategory")),
                          NewsCategory(name: "Business", image: UIImage(named: "businessCategory")),
                          NewsCategory(name: "Technology", image: UIImage(named: "technologyCategory")),
                          NewsCategory(name: "Entertainment", image: UIImage(named: "entertainmentCategory")),
                          NewsCategory(name: "Science", image: UIImage(named: "scienceCategory")),
                          NewsCategory(name: "Health", image: UIImage(named: "healthCategory"))]
        
        newsCategories = categories.compactMap {$0}
    }
    
    func fillSavedCategories() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        do {
            managedObjects = try managedObjectContext!.fetch(fetchRequest)
        } catch let fetchError as NSError {
            print("Could not fetch. \(fetchError)")
        }
        
        if (!managedObjects.isEmpty) {
            for managedObject in managedObjects {
                let category = managedObject.value(forKey: "name") as! String
                savedNewsCategories.append(category)
            }
        }
        
        for category in savedNewsCategories {
            print(category)
        }
    }
    
    func clearSavedCategories() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext?.execute(request)
            do {
                try managedObjectContext!.save()
            } catch let saveError as NSError {
                print("Could not save deleted entities. \(saveError)")
            }
        } catch let deleteError as NSError {
            print("Could not delete entities. \(deleteError)")
        }
    }
    
    func saveCustomCategories() {
        if (!customNewsCategories.isEmpty) {
            for category in customNewsCategories {
                let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedObjectContext!)!
                let categoryEntity = NSManagedObject(entity: entity, insertInto: managedObjectContext!)
                categoryEntity.setValue(category, forKey: "name")
                
                do {
                    try managedObjectContext!.save()
                } catch let saveError as NSError {
                    print("Could not save. \(saveError)")
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCustomNewsFeed" {
            let articleTableViewController = segue.destination as! ArticleTableViewController
            
            for topic in customNewsCategories {
                print(topic)
            }
            
            if let indexPaths = newsCategoryCollectionView.indexPathsForSelectedItems {
                if (!indexPaths.isEmpty) {
                    let indexPath = indexPaths[0]
                    let newsCategory = newsCategories[indexPath.row].name
                    articleTableViewController.newsCategory = newsCategory
                }
            }
            
            if (customNewsCategories.count > 1) {
                articleTableViewController.customNewsCategories = customNewsCategories
                articleTableViewController.results = articleTableViewController.totalResults / customNewsCategories.count
            }
        } else if segue.identifier == "toGameOfTheWeek" {
            let simonGameViewController = segue.destination as! SimonGameViewController
            simonGameViewController.managedObjectContext = self.managedObjectContext
        } 
    }
    
}

// MARK: UICollectionViewDataSource
extension WakeUpViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NewsCategoryCollectionViewCell
        
        cell.newsCategoryImageView.image = newsCategories[indexPath.row].image
        cell.newsCategoryImageView.layer.cornerRadius = 40
        cell.newsCategoryLabel.text = newsCategories[indexPath.row].name
        
        if (savedNewsCategories.contains(cell.newsCategoryLabel.text!)) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            
            customNewsCategories.append(cell.newsCategoryLabel.text!)
            savedNewsCategories = savedNewsCategories.filter() { $0 != cell.newsCategoryLabel.text }
        }
    
        return cell
    }
}

extension WakeUpViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3
        let height = collectionView.frame.height / 2
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? NewsCategoryCollectionViewCell
        customNewsCategories.append(cell!.newsCategoryLabel.text!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? NewsCategoryCollectionViewCell
        customNewsCategories = customNewsCategories.filter() { $0 != cell!.newsCategoryLabel.text }
    }
}


    


