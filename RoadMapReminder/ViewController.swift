
import UIKit
import CoreLocation
import NotificationCenter

enum NotifyType {
    case timer
    case calendar
    case location
}

class ViewController: UIViewController {
    
    let notificationCenter = UNUserNotificationCenter.current()
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var timerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func timerButtonPressed(_ sender: Any) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let id = UUID().uuidString
        scheduleNotification(trigger: trigger, id: id, notifyType: .timer)
    }
    
    @IBAction func calendarButtonPressed(_ sender: Any) {
        getAlert()
    }
    @IBAction func locationButtonPressed(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    private func getAlert() {
        let alertViewController = UIAlertController(title: "Введите время", message: nil, preferredStyle: .alert)
        alertViewController.addTextField { textField in
            textField.placeholder = "Часы"
        }
        alertViewController.addTextField { textField in
            textField.placeholder = "Минуты"
        }
        
        let okAction = UIAlertAction(title: "Сохранить", style: .default) {_ in
            self.addCalendarNotify(hours: alertViewController.textFields?[0].text ?? "", minutes: alertViewController.textFields?[1].text ?? "")
        }
        alertViewController.addAction(okAction)
        
        present(alertViewController, animated: true)
    }
    
    private func addCalendarNotify(hours: String, minutes: String) {
        guard let hour = Int(hours), let minute = Int(minutes) else { return }
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let id = UUID().uuidString
        
        scheduleNotification(trigger: trigger, id: id, notifyType: .calendar)
    }
    
    private func scheduleNotification(trigger: UNNotificationTrigger, id: String, notifyType: NotifyType) {
        var content = UNMutableNotificationContent()
        switch notifyType {
        case .timer:
            content = createTimerNotifyContent(id: id)
        case .calendar:
            content = createCalendarNotifyContent(id: id)
        case .location:
            content = createTimerNotifyContent(id: id)
        }
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if error != nil {
                print("fail")
            }
        }
    }
    
    private func createTimerNotifyContent(id: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "🚨Напоминание"
        content.body = "Daily начнется через 15 минут"
        content.sound = .default
        
        let urlString = Bundle.main.url(forResource: "RoadMapScreen", withExtension: "png")
        let attachment = try? UNNotificationAttachment(identifier: id, url: urlString ?? URL(fileURLWithPath: ""))
        
        if let attachment = attachment {
            content.attachments = [attachment]
        }
        
        let okButton = UNNotificationAction(identifier: "Ok", title: "Хорошо, буду", options: .foreground, icon: UNNotificationActionIcon.init(systemImageName: "horn.blast.fill"))
        let sportButton = UNNotificationAction(identifier: "Ok", title: "+25 отжиманий", options: .destructive , icon: UNNotificationActionIcon.init(systemImageName: "figure.strengthtraining.functional"))
        
        let category = UNNotificationCategory(identifier: content.categoryIdentifier, actions: [okButton, sportButton], intentIdentifiers: [])
        notificationCenter.setNotificationCategories([category])
        
        return content
    }
    
    private func createCalendarNotifyContent(id: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Запланирован лайфкодинг"
        content.body = "Возьмите с собой чайеу☕️"
        content.sound = .default
        
        let urlString = Bundle.main.url(forResource: "megamozg", withExtension: "jpg")
        let attachment = try? UNNotificationAttachment(identifier: id, url: urlString ?? URL(fileURLWithPath: ""))
        
        if let attachment = attachment {
            content.attachments = [attachment]
        }
        
        let okButton = UNNotificationAction(identifier: "Ok", title: "Участвую!", options: .foreground)
        let sportButton = UNNotificationAction(identifier: "Ok", title: "Просто гляну", options: .destructive)
        
        let category = UNNotificationCategory(identifier: content.categoryIdentifier, actions: [okButton, sportButton], intentIdentifiers: [])
        notificationCenter.setNotificationCategories([category])
        
        return content
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let region = CLCircularRegion(center: location.coordinate, radius: CLLocationDistance(1000), identifier: UUID().uuidString)
            region.notifyOnExit = true
            region.notifyOnEntry = true
            
            let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
            let id = UUID().uuidString
            scheduleNotification(trigger: trigger, id: id, notifyType: .location)
            
            let alertViewController = UIAlertController(title: "Вы добавили уведомление", message: "Оно сработает как только вы окажетесь в выбранной зоне", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alertViewController, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
