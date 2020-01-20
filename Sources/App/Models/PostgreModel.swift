import FluentPostgreSQL
import Foundation
import Vapor

protocol IModel: Parameter, Migration, Content, Model {}
protocol PostgreModel: IModel where Database == PostgreSQLDatabase {
    var id: UUID? { get }
}
