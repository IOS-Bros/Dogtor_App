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
    
    func StringtoDate(dateStr: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
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
