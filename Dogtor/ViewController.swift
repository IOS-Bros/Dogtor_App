//
//  ViewController.swift
//  pet_prototype
//  Created by 예쁘고 비싼 thㅡ레기 on 2021/07/24.
//  Modified by GR on 21/07/29 : removed old Calendar, adjust FSCalendar

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
        
        //최초는 오늘날자를 구함
        selectDate01 = dateHandler.getToday()
        //오늘날자를 대입해 이번달 기준 toDoModel을 탐색한다
        getTodoByMonth(dateFomatString: selectDate01)
        //events 값 입력
        getTodoByDate()
        
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        
        calendarTextcolor()
        encodingMonth()
        
        // 필요에 따라서 사용하기
        //초기 세팅 >> 0.2 >> 1은 가장 선명하게
        // 년월에 흐릿하게 보이는 애들 없애기
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.placeholderType = .none
                
        // extension
        calendar.delegate = self
        calendar.dataSource = self
        
        //하단 테이블 값 입력
        toDoTableView.delegate = self
        toDoTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
           
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy-MM-dd"
    //        events.append(selectDateType!)
            print("Reload")
            if events.contains(selectDateType!){
                print(events[events.count - 1])
            }else{
                print("No Data")
            }
//            calendar.delegate = self
//            calendar.dataSource = self
    //        calendar.setCurrentPage(selectDateType! + 2592000, animated: true)
            calendar.reloadData()
            getTodoByMonth(dateFomatString: selectDate01)
            toDoTableView.reloadData()
            
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            let add = segue.destination as! AddViewController
            add.receiveDay(selectDate01)
//            events.append(selectDateType!)
//            print(events[0])
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
            // 달력의 평일 날짜 색깔
            calendar.appearance.titleDefaultColor = .black
            // 달력의 토,일 날짜 색깔
            calendar.appearance.titleWeekendColor = .red
            // 달력의 맨 위의 년도, 월의 색깔
            calendar.appearance.headerTitleColor = .systemPink
            // 달력의 요일 글자 색깔
            calendar.appearance.weekdayTextColor = .orange
        }
        
    func encodingMonth(){
        // 달력의 년월 글자 바꾸기
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        // 달력의 요일 글자 바꾸는 방법 1
        calendar.locale = Locale(identifier: "ko_KR")
        // 달력의 요일 글자 바꾸는 방법 2
        //        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        //        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        //        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        //        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        //        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        //        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        //        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
            }
        
        
    func setUpEvents() {
                
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
            
    }
    
    //입력한 테이타 포맷의 월에 해당하는 데이터를 toDoArr에 입력
    func getTodoByMonth(dateFomatString: String){
        //날자포맷 스플릿해 년/월/일로 분해
        print("입력받은 날자 : \(dateFomatString)")
        let spiltedDate = dateFomatString.split(separator: "-")
        if spiltedDate.count != 3 {
            print("getTodoByMonth error, count : \(spiltedDate.count)" )
            return
        }
        let year: String = String(spiltedDate[0])
        let month: String = String(spiltedDate[1])
        //마지막 날 구하기
        let lastDayByMonth: String = String(dateHandler.lastDay(ofMonth: Int(month)!, year: Int(year)!))
        print("\(year)년 \(month)월의 마지막 날자는 \(lastDayByMonth)")
        //입력전 초기화
        toDoDicBySelectedDate.removeAll()
        let toDoArr = sqlite.selectByMonth(year: year, month: month, lastDateOfMonth: lastDayByMonth)
        
        //toDoArr 순회하며 dic에 값 입력
        for todoModel in toDoArr {
            let splitedtagetDate = todoModel.targetDate.split(separator: "-")
            let date = Int(splitedtagetDate[2])!
            
            if var toDoModelArr = toDoDicBySelectedDate[date] {
                toDoModelArr.append(todoModel)
                //넘버순으로 정렬이 아니라 tagetdate 순으로 정렬 : date값 초로 변롼해서 정렬할것
                toDoModelArr.sort(by: {$0.no > $1.no})
                toDoDicBySelectedDate[date] = toDoModelArr
                print("\(date)일에 데이터가 추가되었습니다.")
            } else {
                var newToDoModelArr = [ToDoModel]()
                newToDoModelArr.append(todoModel)
                toDoDicBySelectedDate[date] = newToDoModelArr
                print("\(date)일에 첫번째 데이터가 추가되었습니다.")
            }
        }
        
        //디버그용 로그
        for (key, value) in toDoDicBySelectedDate {
            print("[\(key)일의 데이터는 아래와 같습니다]")
            for i in value {
                print("no : \(i.no), title: \(i.title)")
            }
        }
    }
    
    //이번달의 toDoModel이 있는 일자를 [String]으로 변환해 events에 대입
    func getTodoByDate(){
        events = []
        //단, key값을 오름차순으로 정렬해 탐색한다.
        for eventDate in toDoDicBySelectedDate.keys.sorted(by: { $0 < $1}){
            let eventsArr = toDoDicBySelectedDate[eventDate]
            //해당일자가 필요한거지 값이 필요한게 아니므로 날자만 획득
            let eventsDateStr = eventsArr![0].targetDate
            //혹시모르는 null값 대비
            guard let eventsDate = dateHandler.StringtoDate(dateStr: eventsDateStr) else {
                continue
            }
            events.append(eventsDate)
        }
    }
    
}
    
extension ViewController: FSCalendarDelegate,FSCalendarDataSource{
        
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(formatter.string(from: date) + " 선택됨")
        selectDate01 = formatter.string(from: date)
        selectDateType = formatter.date(from: selectDate01)
        
        //선택된 일자로 하단 테이블 갱신
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
        print("교체된 날자 : \(calendar.currentPage)")
        let chamgedDate = calendar.currentPage
        let dateToString = formatter.string(from: chamgedDate)
        print("교체된 날자를 string으로 : \(dateToString)")
        getTodoByMonth(dateFomatString: dateToString)
        //events 값 입력
        getTodoByDate()
        calendar.reloadData()
    }
        
        /* 특정 날짜에 텍스트 표시하기
        func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
                
                switch formatter.string(from: date) {
                case formatter.string(from: Date()):
                    return "오늘"
                case "2021-07-22":
                    return "출근"
                case "2021-08-23":
                    return "지각"
                case "2021-08-24":
                    return "결근"
                default:
                    return nil
                }
            }
        */
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    //셀 개수 지정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let splitedDate = selectDate01.split(separator: "-")
        let date = Int(splitedDate[2])!
        if let count = toDoDicBySelectedDate[date]?.count {
            print("테이블에 출력할 데이터는 \(count)개 입니다.")
            return count
        }
        print("테이블에 출력할 데이터가 없습니다.")
        return 0
    }
    
    //셀 내용 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "main_table_cell") else {
            fatalError("table load error: invalid cell")
        }
        //dic의 value는 이미 내림차순으로 출력되어 있으므로 그냥 출력
        let splitedDate = selectDate01.split(separator: "-")
        let date = Int(splitedDate[2])!
        guard let toDoModelArr = toDoDicBySelectedDate[date] else {
            print("테이블에 출력될 내용이 업습니다.")
            return cell
        }
        if toDoModelArr.count <= 0 {
            print("테이블에 출력될 내용이 업습니다.")
            return cell
        }
        print("테이블에 출력될 내용은 \(toDoModelArr[indexPath.row].title)입니다.")
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
    
    //MARK: - Table view cell data source
    func toDoArrInit(){
        
    }
}
