//
//  SimonGameViewController.swift
//  WakeUp
//

import UIKit
import CoreData

class SimonGameViewController: UIViewController {
    var gameState : SimonGame = SimonGame(score: 0, sequence: [], sequenceCount: 0, playerCount: 0, lastButton: nil)
    let delayTime: Double = 1.23
    let buttonDelayTime: Double = 0.5
    var managedObjectContext: NSManagedObjectContext? = nil
    var managedObject: NSManagedObject? = nil
    var highScore: Int = 0
    
    @IBOutlet var gameButtons: [UIButton]!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var scoreTextLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var systemLabel: UILabel!
    
    @IBAction func tapColor(sender: UIButton) {
        if (gameState.playerCount < gameState.sequence.count){
            let result = checkPlayerTurn(sender)
            if (result) {
                gameState.playerCount = gameState.playerCount + 1
                if (gameState.playerCount == gameState.sequence.count) {
                    disableButtons()
                    scoreLabel.text = String(gameState.playerCount)
                    systemLabel.text = "WATCH ME"
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayTime, execute: {
                        self.createSequence()
                        self.showSequence()
                    })
                }
            } else {
                systemLabel.text = "WRONG!"
                let score = gameState.sequenceCount - 1
                if (score > highScore) {
                    saveScore(score: score)
                    scoreTextLabel.text = "NEW HIGH SCORE"
                }
                disableButtons()
                DispatchQueue.main.asyncAfter(deadline: .now() + (delayTime * 3), execute: {
                    self.resetGame()
                })
            }
        }
    }
    
    @IBAction func tapStart(_ sender: UIButton) {
        startButton.setTitle(nil, for: .normal)
        startButton.isEnabled = false
        systemLabel.text = "WATCH ME"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime, execute : {
            self.startGame()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initHighScore()
        disableButtons()
    }
    
    
    func initHighScore() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Game")
        
        do {
            var managedObjects = try managedObjectContext!.fetch(fetchRequest)
            
            if (managedObjects.isEmpty) {
                let entity = NSEntityDescription.entity(forEntityName: "Game", in: managedObjectContext!)!
                let game = NSManagedObject(entity: entity, insertInto: managedObjectContext!)
                game.setValue(0, forKey: "highScore")
                
                do {
                    try managedObjectContext!.save()
                } catch let saveError as NSError {
                    print("Could not save. \(saveError)")
                }
                
                managedObjects = try managedObjectContext!.fetch(fetchRequest)
            }
            
            managedObject = managedObjects[0]
        } catch let fetchError as NSError {
            print("Could not fetch. \(fetchError)")
        }
        
        highScore = managedObject!.value(forKey: "highScore") as! Int
        highScoreLabel.text = "HIGH SCORE: " + String(highScore)
    }
    
    func saveScore(score: Int) {
        managedObject!.setValue(score, forKey: "highScore")
            
        do {
            try managedObjectContext!.save()
        } catch let saveError as NSError {
            print("Coud not save. \(saveError)")
        }
        
        highScoreLabel.text = "HIGH SCORE: " + String(score)
    }
    
    func startGame() {
        createSequence();
        showSequence();
    }
    
    func resetGame() {
        gameState =  SimonGame(score: 0, sequence: [], sequenceCount: 0, playerCount: 0, lastButton: nil)
        
        for button in gameButtons {
            button.isEnabled = false
            button.isHighlighted = false
        }
        
        scoreTextLabel.text = "SCORE"
        scoreLabel.text = String(gameState.playerCount)
        startButton.setTitle("TAP TO START", for: .normal)
        startButton.isEnabled = true
        systemLabel.text = ""
    }
    
    func createSequence() {
        let random = Int.random(in: 0...3)
        let button = gameButtons[random]
        gameState.sequence.append(button)
    }
    
    func showSequence() {
        gameState.sequenceCount = 0
        turnOnNextButton()
    }
    
    func turnOnNextButton() {
        let button = gameState.sequence[gameState.sequenceCount]
        UIView.transition(with: button,
                          duration: buttonDelayTime,
                   options: .transitionCrossDissolve,
                   animations: {
                        button.isEnabled = true
                        button.isHighlighted = true
                   },
                   completion: turnOffPreviousButton)
    }
    
    func turnOffPreviousButton(_ : Bool) -> Void {
        let button = gameState.sequence[gameState.sequenceCount]
        UIView.transition(with: button,
                          duration: buttonDelayTime,
                   options: .transitionCrossDissolve,
                   animations: {
                        button.isHighlighted = false
                        button.isEnabled = false
                   },
                   completion: increaseSequenceCount)
    }
    
    func increaseSequenceCount(_ : Bool) -> Void {
        gameState.sequenceCount = gameState.sequenceCount + 1
        if (gameState.sequenceCount < gameState.sequence.count) {
            turnOnNextButton()
            return
        }
        playerTurn()
    }
    
    func playerTurn() {
        gameState.playerCount = 0
        enableButtons()
        systemLabel.text = "YOUR TURN!"
    }
    
    func checkPlayerTurn(_ button: UIButton) -> Bool {
        return button == gameState.sequence[gameState.playerCount]
    }
    
    func enableButtons() {
        for button in gameButtons {
            button.isEnabled = true
        }
    }
    
    func disableButtons() {
        for button in gameButtons {
            button.isEnabled = false
        }
    }
    
    // Do any additional setup after loading the view.
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

