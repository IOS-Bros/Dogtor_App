
import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var detailDatePicker: UIDatePicker!
    
    let pointColor : UIColor = UIColor.init(displayP3Red: 99/255, green: 197/255, blue: 148/255, alpha: 1)
    
    var receiveNo:Int!
    var receiveTitle:String!
    var receiveContent:String!
    var receiveTargetDate:String!
    
    var changeDate : Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        receiveData(receiveNo, receiveTitle, receiveContent, receiveTargetDate)
        
        tfTitle.text = receiveTitle
        tvContent.text = receiveContent
        tvContent.placeholder = "내용을 입력해주세요!"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        detailDatePicker.setDate(changeDate, animated: true)
        
        tfTitle.layer.borderWidth = 1
        tfTitle.layer.cornerRadius = 8.0
        tfTitle.layer.borderColor = pointColor.cgColor
        tvContent.layer.borderWidth = 1
        tvContent.layer.borderColor = pointColor.cgColor
        
    }
    
    func receiveData(_ no: Int, _ title:String, _ content:String, _ targetDate:String){
        receiveNo = no
        receiveTitle = title
        receiveContent = content
        receiveTargetDate = targetDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        changeDate = dateFormatter.date(from: receiveTargetDate)!
    }
    
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        receiveTargetDate = stringFormatter(datePickerView.date)
    }
    
    
    @IBAction func barBtnModify(_ sender: UIBarButtonItem) {
        let sqlite = SQLite()
        
        guard tfTitle.text?.isEmpty != true else {alter(message: "제목을 입력해주세요!", value: false); return}
        
        receiveTitle = tfTitle.text!
        receiveContent = tvContent.text!
        
        let updateResult = sqlite.update(receiveNo, receiveTitle, receiveContent, receiveTargetDate)
        if updateResult{
            alter(message: "수정 성공 했습니다.", value: true)
        }else{
            alter(message: "수정 실패 했습니다.", value: true)
        }
    }
}

extension DetailViewController: ManageDBErrorProtocol{
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
