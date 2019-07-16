import Foundation

protocol LikesManagable {
    var likesManager: LikesManager! { get }
}

struct LikesManager: NumberManagable {
    func like(numberOfLikes: inout Int?) {
        increase(number: &numberOfLikes)
    }
    
    func deleteLike(numberOfLikes: inout Int?) {
        decrease(number: &numberOfLikes)
    }
    
    func dislike(numberOfDislikes: inout Int?) {
        increase(number: &numberOfDislikes)
    }
    
    func deleteDislike(numberOfDislikes: inout Int?) {
        decrease(number: &numberOfDislikes)
    }
    
    func shouldSendPush(numberOfLikes: Int?) -> Bool {
        return closest(to: numberOfLikes)
    }
    
    func shouldSendPush(numberOfDislikes: Int?) -> Bool {
        return closest(to: numberOfDislikes)
    }
}
