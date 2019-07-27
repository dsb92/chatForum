import Foundation

protocol NumberManagable {
    func increase(number: inout Int?)
    func decrease(number: inout Int?)
    func closest(to number: Int?) -> Bool
}

extension NumberManagable {
    func increase(number: inout Int?) {
        guard var no = number else {
            number = 1
            return
        }
        
        no += 1
        number = no
    }
    
    
    func decrease(number: inout Int?) {
        guard var no = number else {
            number = 0
            return
        }
        
        no -= 1
        
        if no < 0 {
            no = 0
        }
        
        number = no
    }
    
    func closest(to number: Int?) -> Bool {
        guard let number = number, number > 0 else { return false }
        
        var values = [Int]()
        for n in 1...20 {
            values.append(Int(5.0 / 2.0 * Double((n^^2 - n + 2))))
        }
        
        let closest = findClosest(values, number)
        
        return number % closest == 0
    }
}

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

func findClosest(_ values: [Int], _ givenValue: Int) -> Int {
    
    let sorted = values.sorted()
    
    guard let over = sorted.first(where: { $0 >= givenValue }) else { return givenValue }
    guard let under = sorted.last(where: { $0 <= givenValue }) else { return over }
    
    let diffOver = over - givenValue
    let diffUnder = givenValue - under
    
    return (diffOver < diffUnder) ? over : under
}
