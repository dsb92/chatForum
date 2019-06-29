import Foundation

protocol CommentsManagable {
    var commentsManager: CommentsManager! { get }
}

struct CommentsManager: NumberManagable {
    func comment(numberOfComments: inout Int?) {
        increase(number: &numberOfComments)
    }
}
