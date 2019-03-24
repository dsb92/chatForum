import Vapor
import Fluent

struct ColorResponse: Codable {
    var colors: [Color]
}

extension ColorResponse: Content { }

final class ColorController: RouteCollection {
    // Register all 'users' routes
    func boot(router: Router) throws {
        let colors = router.grouped("colors")
        
        // Regiser each handler
        colors.post(Color.self, use: postColor)
        colors.put(Color.self, use: putColor)
        colors.get(use: getColors)
        colors.get(Color.parameter, use: getColor)
        colors.delete(Color.parameter, use: deleteColor)
    }
    
    // GET COLORS
    func getColors(_ request: Request)throws -> Future<ColorResponse> {
        let val = Color.query(on: request).all()
        return val.flatMap { colors in
            let all = ColorResponse(colors: colors)
            return Future.map(on: request) { return all }
        }
    }
    
    // GET COLOR
    func getColor(_ request: Request)throws -> Future<Post> {
        return try request.parameters.next(Post.self)
    }
    
    // POST COLOR
    func postColor(_ request: Request, _ color: Color)throws -> Future<Color> {
        return color.create(on: request)
    }
    
    // UPDATE COLOR
    func putColor(_ request: Request, color: Color)throws -> Future<Color> {
        return color.update(on: request)
    }
    
    // DELETE COLOR
    func deleteColor(_ request: Request)throws -> Future<HTTPStatus> {
        return try request.parameters.next(Color.self).delete(on: request).transform(to: .noContent)
    }
}
