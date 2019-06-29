import Foundation

protocol NumberManagable {
    func increase(number: inout Int?)
    func decrease(number: inout Int?)
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
}
