
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
        
        let receiveDateToDate = dateHandler.StringtoDate(dateStr: receiveDate)
        if events.firstIndex(of: receiveDateToDate!) == nil{
            events.append(receiveDateToDate!)
        }
        
        guard let toDoModel = sqlite.insertAndReturn(realTitle, realContext, receiveDate, current_date_string) else {
            alter(message: "등록 실패 했습니다.", value: true)
            return
        }
        
        alter(message: "등록 성공 했습니다.", value: true)
        
        let splitedtagetDate = receiveDate.split(separator: "-")
        let date = Int(splitedtagetDate[2])!
        if var toDoModelArr = toDoDicBySelectedDate[date] {
            toDoModelArr.append(toDoModel)
            toDoModelArr.sort(by: {$0.no > $1.no})
            toDoDicBySelectedDate[date] = toDoModelArr
        } else {
            var newToDoModelArr = [ToDoModel]()
            newToDoModelArr.append(toDoModel)
            toDoDicBySelectedDate[date] = newToDoModelArr
        }
        
    }
    
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

extension AddViewController: ManageDBErrorProtocol{
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
