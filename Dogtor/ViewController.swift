
import UIKit
import FSCalendar

let formatter = DateFormatter()
var selectDate01 = ""
var events: Array<Date> = []
var toDoDicBySelectedDate = [Int: [ToDoModel]]()
let sqlite: SQLite = SQLite()
let dateHandler = DateHandling()

class ViewController: UIViewController{
    
    @IBOutlet weak var toDoTableView: UITableView!

    
    @IBOutlet weak var calendar: FSCalendar!
    
    var selectDateType = formatter.date(from: selectDate01)
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.navigationController?.navigationBar.barTintColor = UIColor.init(displayP3Red: 99/255, green: 197/255, blue: 148/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        selectDate01 = dateHandler.getToday()
        getTodoByMonth(dateFomatString: selectDate01)
        getTodoByDate()
        
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        
        calendarTextcolor()
        encodingMonth()
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.placeholderType = .none
                
        calendar.delegate = self
        calendar.dataSource = self
        
        toDoTableView.delegate = self
        toDoTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
           
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"

        calendar.reloadData()
        getTodoByMonth(dateFomatString: selectDate01)
        toDoTableView.reloadData()
            
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            let add = segue.destination as! AddViewController
            add.receiveDay(selectDate01)
            
        }else if segue.identifier == "sgDetail"{
            let detail = segue.destination as! DetailViewController
            let cell = sender as! UITableViewCell
            let indexPath = self.toDoTableView.indexPath(for: cell)
            let selectedDayToString = dateHandler.getDayToString(selectDate01)
            guard let selectedDayToDoArr = toDoDicBySelectedDate[Int(selectedDayToString)!] else {
                return
            }
            let dto = selectedDayToDoArr[indexPath!.row]
            
            detail.receiveData(dto.no, dto.title, dto.contents, selectDate01)
        }
    }
        
    func calendarTextcolor(){
            calendar.appearance.titleDefaultColor = .black
            calendar.appearance.titleWeekendColor = .red
            calendar.appearance.headerTitleColor = .systemPink
            calendar.appearance.weekdayTextColor = .orange
        }
        
    func encodingMonth(){
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.locale = Locale(identifier: "ko_KR")
    }
        
        
    func setUpEvents() {
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
    func getTodoByMonth(dateFomatString: String){
        let spiltedDate = dateFomatString.split(separator: "-")
        if spiltedDate.count != 3 {
            return
        }
        let year: String = String(spiltedDate[0])
        let month: String = String(spiltedDate[1])
        
        let lastDayByMonth: String = String(dateHandler.lastDay(ofMonth: Int(month)!, year: Int(year)!))
        
        toDoDicBySelectedDate.removeAll()
        let toDoArr = sqlite.selectByMonth(year: year, month: month, lastDateOfMonth: lastDayByMonth)
        
        for todoModel in toDoArr {
            let splitedtagetDate = todoModel.targetDate.split(separator: "-")
            let date = Int(splitedtagetDate[2])!
            
            if var toDoModelArr = toDoDicBySelectedDate[date] {
                toDoModelArr.append(todoModel)
                toDoModelArr.sort(by: {$0.no > $1.no})
                toDoDicBySelectedDate[date] = toDoModelArr
            } else {
                var newToDoModelArr = [ToDoModel]()
                newToDoModelArr.append(todoModel)
                toDoDicBySelectedDate[date] = newToDoModelArr
            }
        }
    }
    
    func getTodoByDate(){
        events = []
        for eventDate in toDoDicBySelectedDate.keys.sorted(by: { $0 < $1}){
            let eventsArr = toDoDicBySelectedDate[eventDate]
            let eventsDateStr = eventsArr![0].targetDate
            guard let eventsDate = dateHandler.StringtoDate(dateStr: eventsDateStr) else {
                continue
            }
            events.append(eventsDate)
        }
    }
    
}
    
extension ViewController: FSCalendarDelegate,FSCalendarDataSource{
        
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectDate01 = formatter.string(from: date)
        selectDateType = formatter.date(from: selectDate01)
        
        toDoTableView.reloadData()
    }
        
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if events.contains(date) {
            return 1
        } else {
            return 0
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let chamgedDate = calendar.currentPage
        let dateToString = formatter.string(from: chamgedDate)
        getTodoByMonth(dateFomatString: dateToString)
        getTodoByDate()
        calendar.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let splitedDate = selectDate01.split(separator: "-")
        let date = Int(splitedDate[2])!
        if let count = toDoDicBySelectedDate[date]?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "main_table_cell") else {
            fatalError("table load error: invalid cell")
        }
        let splitedDate = selectDate01.split(separator: "-")
        let date = Int(splitedDate[2])!
        guard let toDoModelArr = toDoDicBySelectedDate[date] else {
            return cell
        }
        if toDoModelArr.count <= 0 {
            return cell
        }
        cell.textLabel?.text = toDoModelArr[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let selectedDayToString = dateHandler.getDayToString(selectDate01)
                guard var selectedDayToDoArr = toDoDicBySelectedDate[Int(selectedDayToString)!] else {
                    return
                }
                let taget = selectedDayToDoArr[indexPath.row]
                if !sqlite.delete(taget.no, dateHandler.getToday()){
                    return
                }
                selectedDayToDoArr.remove(at: indexPath.row)
                toDoDicBySelectedDate[Int(selectedDayToString)!] = selectedDayToDoArr
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if selectedDayToDoArr.count == 0 {
                    let noneDateDate = dateHandler.StringtoDate(dateStr: selectDate01)
                    let noneDateDateIndex = events.firstIndex(of: noneDateDate!)
                    events.remove(at: noneDateDateIndex!)
                    calendar.reloadData()
                }
            }
    }
}

extension ViewController: ManageDBErrorProtocol{
    func manageDBError() {
        let alert = UIAlertController(title: "Error", message: "데이터베이스 에러, 앱을 재실행해 주세요.", preferredStyle: .alert)
        let actionDefault = UIAlertAction(title: "확인", style: .default, handler: {
            ACTION in
            exit(0)
        })
        alert.addAction(actionDefault)
        self.present(alert, animated: true, completion: nil)
    }
}
