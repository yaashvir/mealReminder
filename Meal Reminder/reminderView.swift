//
//  ViewController.swift
//  Meal Reminder
//
//  Created by Yash Walia on 03/02/19.
//  Copyright © 2019 Yash Walia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UserNotifications

struct meal {
    let name : String
    let time : String
}

struct diet {
    let day : String
    var meals : [meal]
}

class reminderView : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var myDiet : [diet] = []
    
    var mydate : Date?
    
    let titleLabel : UILabel = {
        let label = UILabel()
        
        let myShadow = NSShadow()
        myShadow.shadowBlurRadius = 3
        myShadow.shadowOffset = CGSize(width: 3, height: 3)
        myShadow.shadowColor = UIColor.gray
        
        var attributedText = NSMutableAttributedString(string: "My ", attributes: [NSAttributedString.Key.font : UIFont(name: "Chalkduster", size: 20)!, NSAttributedString.Key.foregroundColor : UIColor.red, NSAttributedString.Key.shadow: myShadow])
        attributedText.append(NSMutableAttributedString(string: "Meal Reminders", attributes: [NSAttributedString.Key.font : UIFont(name: "Chalkduster", size: 20)!, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.shadow: myShadow]))
        label.attributedText = attributedText
        label.textAlignment = .center
        return label
    }()
    
    let myTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        setupTableView()
        setupLayout()
        
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "color")
        myTableView.tableFooterView = UIView()
        myTableView.allowsSelection = false
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in }
        let mealReminder = UNNotificationCategory(identifier: "mealReminder", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([mealReminder])
        exampleInstantNotification()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return myDiet.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = myDiet[section].day
        label.textAlignment = .center
        label.layer.cornerRadius = 20
        label.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDiet[section].meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "color", for: indexPath)
        let nameLabel = UILabel()
        let timeLabel = UILabel()
        cell.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 20).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: cell.frame.width - 140).isActive = true
        nameLabel.font = UIFont.boldSystemFont(ofSize: 13)
        cell.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant : 40).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
        timeLabel.textColor = .darkGray
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        
        nameLabel.text = myDiet[indexPath.section].meals[indexPath.row].name
        timeLabel.text = myDiet[indexPath.section].meals[indexPath.row].time
        generateNotification(name: myDiet[indexPath.section].meals[indexPath.row].name, day: myDiet[indexPath.section].day, time: myDiet[indexPath.section].meals[indexPath.row].time)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    
    func fetchData(){
        let url = "https://naviadoctors.com/dummy/"
        
        Alamofire.request(url).responseJSON { response in
            if response.result.isSuccess{
                let json = JSON(response.result.value!)
                
                self.myDiet.append(diet(day: "Monday", meals: []))
                let mondayFoodCount = json["week_diet_data"]["monday"].arrayValue.count - 1
                for i in 0...mondayFoodCount{
                    self.myDiet[0].meals.append(meal(name: json["week_diet_data"]["monday"][i]["food"].stringValue, time: json["week_diet_data"]["monday"][i]["meal_time"].stringValue))
                }
                
                self.myDiet.append(diet(day: "Wednesday", meals: []))
                let wednesdayFoodCount = json["week_diet_data"]["wednesday"].arrayValue.count - 1
                for i in 0...wednesdayFoodCount{
                    self.myDiet[1].meals.append(meal(name: json["week_diet_data"]["wednesday"][i]["food"].stringValue, time: json["week_diet_data"]["wednesday"][i]["meal_time"].stringValue))
                }

                self.myDiet.append(diet(day: "Thursday", meals: []))
                let thursdayFoodCount = json["week_diet_data"]["thursday"].arrayValue.count - 1
                for i in 0...thursdayFoodCount{
                    self.myDiet[2].meals.append(meal(name: json["week_diet_data"]["thursday"][i]["food"].stringValue, time: json["week_diet_data"]["thursday"][i]["meal_time"].stringValue))
                }
                self.myTableView.reloadData()
            }
            else{
                print(response.result.error!)
            }
        }
    }
    
    func setupTableView(){
        myTableView.delegate = self
        myTableView.dataSource = self
        view.addSubview(myTableView)
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
    
    func setupLayout(){
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func generateNotification(name : String, day : String, time: String){

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        if day == "Monday"{
            mydate = formatter.date(from: "2019/02/04 \(time)")
        }
        else if day == "Wednesday"{
            mydate = formatter.date(from: "2019/02/06 \(time)")
        }
        else{
            mydate = formatter.date(from: "2019/02/07 \(time)")
        }
        
        mydate = mydate?.addingTimeInterval(-300)                                                                           // 5 minutes before meal
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = "mealReminder"
            content.title = name
            content.body = "It's your meal time in 5 minutes."
            content.sound = UNNotificationSound.default
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.mydate!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            print("Notification for \(name) meal on \(day) at \(time) is scheduled.")
        }
    }
    
    func exampleInstantNotification(){
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = "mealReminder"
            content.title = "Example Notification"
            content.body = "Just to check all notifications are scheduled or not."
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }

    }

}

