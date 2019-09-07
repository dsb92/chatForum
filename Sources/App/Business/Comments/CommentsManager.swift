import Foundation

protocol CommentsManagable {
    var commentsManager: CommentsManager! { get }
}

struct CommentsManager: NumberManagable {
    func addComment(numberOfComments: inout Int?) {
        increase(number: &numberOfComments)
    }
    
    func deleteComment(numberOfComments: inout Int?) {
        decrease(number: &numberOfComments)
    }
}
