//
//  AddViewController.swift
//  pet_prototype
//
//  Created by 예쁘고 비싼 thㅡ레기 on 2021/07/25.
//

import UIKit

class AddViewController: UIViewController {
    
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfContext: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let pointColor : UIColor = UIColor.init(displayP3Red: 99/255, green: 197/255, blue: 148/255, alpha: 1)
    var realTitle: String!
    var realContext: String!
    var receiveDate: String = ""
    var changeDate : Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        receiveDay(receiveDate)
        datePicker.setDate(changeDate, animated: true)
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = UIColor.white
        tfContext.placeholder = "내용을 입력해주세요!"
        
        tfTitle.layer.borderWidth = 1
        tfTitle.layer.cornerRadius = 8.0
        tfTitle.layer.borderColor = pointColor.cgColor
        tfContext.layer.borderWidth = 1
        tfContext.layer.borderColor = pointColor.cgColor
        
    }
    
    func receiveDay(_ date: String){
        receiveDate = date
        // 날짜로 변경
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        changeDate = dateFormatter.date(from: receiveDate)!
    }
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        receiveDate = stringFormatter(datePickerView.date)
    }
    
    @IBAction func barBtnSubmit(_ sender: UIBarButtonItem) {
        let current_date_string = stringFormatter(Date())
        
        guard tfTitle.text?.isEmpty != true else {alter(message: "제목을 입력해주세요!", value: false); return
        }
        
        realTitle = tfTitle.text!
        realContext = tfContext.text!
        
        //날자값이 중복으로 들어가지 않게 evenvts에 추가하려는 일자가 없을경우만 추가하도록 수정
        let receiveDateToDate = dateHandler.StringtoDate(dateStr: receiveDate)
        if events.firstIndex(of: receiveDateToDate!) == nil{
            events.append(receiveDateToDate!)
        }
        
//        if !sqlite.insert(realTitle, realContext, receiveDate, current_date_string){
//            alter(message: "등록 실패 했습니다.", value: true)
//            return
//        } else {
//            alter(message: "+1 능력 상승 되었습니다.", value: true)
//        }
        //----------------------------
        guard let toDoModel = sqlite.insertAndReturn(realTitle, realContext, receiveDate, current_date_string) else {
            alter(message: "등록 실패 했습니다.", value: true)
            return
        }
        
        alter(message: "+1 능력 상승 되었습니다.", value: true)
        
        let splitedtagetDate = receiveDate.split(separator: "-")
        let date = Int(splitedtagetDate[2])!
//
//        guard let toDoModel = sqlite.getLastOne() else {
//            print("data load fail")
//            return
//        }
//
        if var toDoModelArr = toDoDicBySelectedDate[date] {
            toDoModelArr.append(toDoModel)
            toDoModelArr.sort(by: {$0.no > $1.no})
            toDoDicBySelectedDate[date] = toDoModelArr
            print("\(date)일에 데이터가 추가되었습니다.")
        } else {
            var newToDoModelArr = [ToDoModel]()
            newToDoModelArr.append(toDoModel)
            toDoDicBySelectedDate[date] = newToDoModelArr
            print("\(date)일에 첫번째 데이터가 추가되었습니다.")
        }
        //--------------------
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

extension UIViewController{
    func alter(message: String, value: Bool) {
        let resultAlert = UIAlertController(title: "Dogter", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {ACTION in
            if value{
                self.navigationController?.popViewController(animated: true)
            }
        })
        
        resultAlert.addAction(okAction)
        present(resultAlert, animated: true, completion: nil)
    }
    func stringFormatter(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dataString = dateFormatter.string(from: date)
        
        return dataString
    }
}
