//
//  SQLite.swift
//  pet_prototype
//
//  Created by SeungYeon on 2021/07/29.
//

import Foundation
import SQLite3
class SQLite{
    var db:OpaquePointer?
    let TABLE_NAME : String = "DaengDaengTable"
    
    func databaseOpen() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("DaengDaengDB.sqlite")
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("table not exsist")
        }
    }
    func createTable(){
        databaseOpen()
        //  title, contents, targetDate, submitDate, deleteDate
        let CREATE_QUERY_TEXT : String = "CREATE TABLE IF NOT EXISTS \(TABLE_NAME) (no INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, contents TEXT, targetDate TEXT NOT NULL, submitDate TEXT, deleteDate TEXT)"
        if sqlite3_exec(db, CREATE_QUERY_TEXT, nil, nil, nil) != SQLITE_OK {
            let errMsg = String(cString:sqlite3_errmsg(db))
            print("db table create error : \(errMsg)")
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
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert:v1 \(errMsg)")
            return false
        }
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_bind_text(stmt, 1, strTitle, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding title: \(errMsg)")
            return false
        }
        if sqlite3_bind_text(stmt, 2, strContents, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding content: \(errMsg)")
            return false
        }
        if sqlite3_bind_text(stmt, 3, strTargetDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding target: \(errMsg)")
            return false
        }
        if sqlite3_bind_text(stmt, 4, strSubmitDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding submit: \(errMsg)")
            return false
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("insert fail :: \(errMsg)")
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
        print(UPDATE_QUERY)
        if sqlite3_prepare(db, UPDATE_QUERY, -1, &stmt, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing update: v1\(errMsg)")
            return false
        }
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_bind_text(stmt, 1, strTitle, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding title: \(errMsg)")
            return false
        }
        if sqlite3_bind_text(stmt, 2, strContents, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding content: \(errMsg)")
            return false
        }
        if sqlite3_bind_text(stmt, 3, strTargetDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding target: \(errMsg)")
            return false
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("update fail :: \(errMsg)")
            return false
        }
//        sqlite3_finalize(stmt)
        print("update success")
        return true
    }
    func delete(_ no: Int, _ deleteDate:String) -> Bool{
        databaseOpen()
        let strdeleteDate = deleteDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let DELETE_QUERY = "UPDATE \(TABLE_NAME) Set deleteDate = '\(strdeleteDate)' WHERE no = \(no)"
        var stmt:OpaquePointer?
        
        print(DELETE_QUERY)
        if sqlite3_prepare_v2(db, DELETE_QUERY, -1, &stmt, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing delete: v1\(errMsg)")
            return false
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("delete fail :: \(errMsg)")
            return false
        }
        sqlite3_finalize(stmt)
        print("delete success")
        return true
    }
    func selectValue(_ targetDate : String){
        databaseOpen()
        // 초기 작업 필요: 데이터 지워주기 어디서 하징
    //    studentsList.removeAll()
        let strTargetDate = targetDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let SELECT_QUERY = "SELECT * FROM \(TABLE_NAME) WHERE targetDate= '\(strTargetDate)' AND deleteDate IS NULL"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, SELECT_QUERY, -1, &stmt, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: v1\(errMsg)")
            return
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let no = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let contents = String(cString: sqlite3_column_text(stmt, 2))
            let targetDate = String(cString: sqlite3_column_text(stmt, 3))
            let submitDate = String(cString: sqlite3_column_text(stmt, 4))
            print("read value no : \(no) title : \(title) contents : \(contents) targetDate : \(targetDate) submitDate : \(submitDate) ")
        }
    }
    
    func selectByMonth(year: String, month: String, lastDateOfMonth: String) -> [ToDoModel]{
        databaseOpen()
        
        print("selectByMonth 시작")
        var resultArr: [ToDoModel] = []
        
        let SELECT_ALL_QUERY = "SELECT * FROM \(TABLE_NAME) WHERE targetDate BETWEEN '\(year)-\(month)-01' AND '\(year)-\(month)-\(lastDateOfMonth)' AND deleteDate IS NULL"
        print("query : \(SELECT_ALL_QUERY) " )
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, SELECT_ALL_QUERY, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error preparing  select \(errmsg)")
            return resultArr
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let no = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let contents = String(cString: sqlite3_column_text(stmt, 2))
            let targetDate = String(cString: sqlite3_column_text(stmt, 3))
            let submitDate = String(cString: sqlite3_column_text(stmt, 4))
            
            let toDoListModel = ToDoModel(no: Int(no), title: title, contents: contents, targetDate: targetDate, submitDate: submitDate)
            toDoListModel.printData()
            resultArr.append(toDoListModel)
        }
        
        return resultArr
    }
    
    func getLastOne() -> ToDoModel?{
        var toDoListModel:ToDoModel? = nil
        print("getLastNo 시작")
        
        let SELECT_LAST_NO = "SELECT * FROM \(TABLE_NAME) ORDER BY ROWID DESC LIMIT 1"
        print("query : \(SELECT_LAST_NO) " )
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, SELECT_LAST_NO, -1, &stmt, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: v1\(errMsg)")
            return toDoListModel
        }
        if sqlite3_step(stmt) == SQLITE_ROW {
            let no = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let contents = String(cString: sqlite3_column_text(stmt, 2))
            let targetDate = String(cString: sqlite3_column_text(stmt, 3))
            let submitDate = String(cString: sqlite3_column_text(stmt, 4))
            
            toDoListModel = ToDoModel(no: Int(no), title: title, contents: contents, targetDate: targetDate, submitDate: submitDate)
            toDoListModel!.printData()
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
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert:v1 \(errMsg)")
            return nil
        }
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_bind_text(stmt, 1, strTitle, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding title: \(errMsg)")
            return nil
        }
        if sqlite3_bind_text(stmt, 2, strContents, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding content: \(errMsg)")
            return nil
        }
        if sqlite3_bind_text(stmt, 3, strTargetDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding target: \(errMsg)")
            return nil
        }
        if sqlite3_bind_text(stmt, 4, strSubmitDate, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding submit: \(errMsg)")
            return nil
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("insert fail :: \(errMsg)")
            return nil
        }
        sqlite3_finalize(stmt);
        
        return getLastOne()
    }
}
