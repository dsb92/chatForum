import Vapor
import Fluent

protocol NSFWContentProvider {
    func checkNudity(on request: Request, file: File) throws -> Future<NSFWMediaResponse>
}

protocol NSFWContentManagable {
    var nsfwContentProvider: NSFWContentProvider! { get }
}
