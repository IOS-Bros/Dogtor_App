
import Foundation

class ToDoModel{
    
    var no: Int
    var title: String
    var contents: String
    var targetDate: String
    var submitDate: String
    var deleteDate: String?
    
    init(no: Int, title: String, contents: String, targetDate: String, submitDate: String){
        self.no = no
        self.title = title
        self.contents = contents
        self.targetDate = targetDate
        self.submitDate = submitDate
    }
    
    init(no: Int, title: String, contents: String, targetDate: String, submitDate: String, deleteDate: String){
        self.no = no
        self.title = title
        self.contents = contents
        self.targetDate = targetDate
        self.submitDate = submitDate
        self.deleteDate = deleteDate
    }
}
