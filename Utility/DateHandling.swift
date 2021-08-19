//
//  DateHandling.swift
//  pet_prototype
//
//  Created by 윤재필 on 2021/07/29.
//

import Foundation

class DateHandling{
    
    func getToday() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date_string = formatter.string(from: Date())
       
        return current_date_string
    }
    
    func lastDay(ofMonth m: Int, year y: Int) -> Int {
        let cal = Calendar.current
        var comps = DateComponents(calendar: cal, year: y, month: m)
        comps.setValue(m + 1, for: .month)
        comps.setValue(0, for: .day)
        let date = cal.date(from: comps)!
        
        return cal.component(.day, from: date)
    }
    
    func StringtoDate(dateStr: String) -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //현재 이게 없어야 정상적으로 찍히는데 이유는 모르겠음 달력 날자랑 연관되있나? 싶음
        //dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: dateStr) {
            return date
        } else {
            return nil
        }
    }

    
    func splitedDateStr(dateStr: String) -> [String]{
        var result = [String]()
        for i in dateStr.split(separator: "-") {
            result.append(String(i))
        }
        return result
    }
    
    func getDayToString(_ date: String) -> String{
        let spiltedDate = date.split(separator: "-")
        return String(spiltedDate[2])
    }
    
    
}
