
import Foundation
import SQLite3


protocol ManageDBErrorProtocol {
    func manageDBError()
}

class SQLite{
    var db:OpaquePointer?
    let TABLE_NAME : String = "DaengDaengTable"
    var delegate: ManageDBErrorProtocol!
    
    func databaseOpen() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("DaengDaengDB.sqlite")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            dbError()
        }
    }
    func createTable(){
        databaseOpen()
        let CREATE_QUERY_TEXT : String = "CREATE TABLE IF NOT EXISTS \(TABLE_NAME) (no INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, contents TEXT, targetDate TEXT NOT NULL, submitDate TEXT, deleteDate TEXT)"
        if sqlite3_exec(db, CREATE_QUERY_TEXT, nil, nil, nil) != SQLITE_OK {
            dbError()
        }
    }
    func insert(_ title : String,_ contents : String, _ targetDate : String, _ submitDate : String) -> Bool{
        var stmt : OpaquePointer?
        databaseOpen()
        let strTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let strContents = contents.trimmingCharacters(in: .whitespacesAndNewlines)
        let strTargetDate = targetDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let strSubmitDate = submitDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let INSERT_QUERY_TEXT : String = "INSERT INTO \(TABLE_NAME) (title, contents, targetDate, submitDate) Values (?,?,?,?)"
        if sqlite3_prepare(db, INSERT_QUERY_TEXT, -1, &stmt, nil) != SQLITE_OK {
            dbError()
            return false
        }
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_bind_text(stmt, 1, strTitle, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return false
        }
        if sqlite3_bind_text(stmt, 2, strContents, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return false
        }
        if sqlite3_bind_text(stmt, 3, strTargetDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return false
        }
        if sqlite3_bind_text(stmt, 4, strSubmitDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return false
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            dbError()
            return false
        }
        return true
    }
    func update(_ no:Int, _ title : String,_ contents : String, _ targetDate : String) -> Bool{
        databaseOpen()
        
        let strTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let strContents = contents.trimmingCharacters(in: .whitespacesAndNewlines)
        let strTargetDate = targetDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let UPDATE_QUERY = "UPDATE \(TABLE_NAME) Set title = ?, contents = ?, targetDate= ? WHERE no = \(no)"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, UPDATE_QUERY, -1, &stmt, nil) != SQLITE_OK{
            dbError()
            return false
        }
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_bind_text(stmt, 1, strTitle, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return false
        }
        if sqlite3_bind_text(stmt, 2, strContents, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return false
        }
        if sqlite3_bind_text(stmt, 3, strTargetDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return false
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            dbError()
            return false
        }
        
        return true
    }
    func delete(_ no: Int, _ deleteDate:String) -> Bool{
        databaseOpen()
        let strdeleteDate = deleteDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let DELETE_QUERY = "UPDATE \(TABLE_NAME) Set deleteDate = '\(strdeleteDate)' WHERE no = \(no)"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare_v2(db, DELETE_QUERY, -1, &stmt, nil) != SQLITE_OK{
            dbError()
            return false
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            dbError()
            return false
        }
        sqlite3_finalize(stmt)
        return true
    }
    
    func selectByMonth(year: String, month: String, lastDateOfMonth: String) -> [ToDoModel]{
        databaseOpen()
        
        var resultArr: [ToDoModel] = []
        
        let SELECT_ALL_QUERY = "SELECT * FROM \(TABLE_NAME) WHERE targetDate BETWEEN '\(year)-\(month)-01' AND '\(year)-\(month)-\(lastDateOfMonth)' AND deleteDate IS NULL"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, SELECT_ALL_QUERY, -1, &stmt, nil) != SQLITE_OK{
            dbError()
            return resultArr
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let no = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let contents = String(cString: sqlite3_column_text(stmt, 2))
            let targetDate = String(cString: sqlite3_column_text(stmt, 3))
            let submitDate = String(cString: sqlite3_column_text(stmt, 4))
            
            let toDoListModel = ToDoModel(no: Int(no), title: title, contents: contents, targetDate: targetDate, submitDate: submitDate)
            resultArr.append(toDoListModel)
        }
        
        return resultArr
    }
    
    func getLastOne() -> ToDoModel?{
        var toDoListModel:ToDoModel? = nil
        
        let SELECT_LAST_NO = "SELECT * FROM \(TABLE_NAME) ORDER BY ROWID DESC LIMIT 1"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, SELECT_LAST_NO, -1, &stmt, nil) != SQLITE_OK{
            dbError()
            return toDoListModel
        }
        if sqlite3_step(stmt) == SQLITE_ROW {
            let no = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let contents = String(cString: sqlite3_column_text(stmt, 2))
            let targetDate = String(cString: sqlite3_column_text(stmt, 3))
            let submitDate = String(cString: sqlite3_column_text(stmt, 4))
            
            toDoListModel = ToDoModel(no: Int(no), title: title, contents: contents, targetDate: targetDate, submitDate: submitDate)
        }
        sqlite3_finalize(stmt);
        return toDoListModel
    }
    
    func insertAndReturn(_ title : String,_ contents : String, _ targetDate : String, _ submitDate : String) -> ToDoModel?{
        var stmt : OpaquePointer?
        databaseOpen()
        let strTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let strContents = contents.trimmingCharacters(in: .whitespacesAndNewlines)
        let strTargetDate = targetDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let strSubmitDate = submitDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let INSERT_QUERY_TEXT : String = "INSERT INTO \(TABLE_NAME) (title, contents, targetDate, submitDate) Values (?,?,?,?)"
        if sqlite3_prepare(db, INSERT_QUERY_TEXT, -1, &stmt, nil) != SQLITE_OK {
            dbError()
            return nil
        }
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_bind_text(stmt, 1, strTitle, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return nil
        }
        if sqlite3_bind_text(stmt, 2, strContents, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return nil
        }
        if sqlite3_bind_text(stmt, 3, strTargetDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return nil
        }
        if sqlite3_bind_text(stmt, 4, strSubmitDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            dbError()
            return nil
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            dbError()
            return nil
        }
        sqlite3_finalize(stmt);
        
        return getLastOne()
    }
    
    
    func dbError(){
        DispatchQueue.main.sync(execute: {() -> Void in
            self.delegate.manageDBError()
        })
        
    }
}
