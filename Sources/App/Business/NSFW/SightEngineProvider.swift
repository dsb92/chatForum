import Vapor
import Fluent

struct SightEngineProvider: NSFWContentProvider {
    func checkNudity(on request: Request, file: File) throws -> Future<NSFWMediaResponse> {
        return try sightEnginePostDetectNudity(on: request, file: file).map { response in
            guard let response = response else {
                throw Abort(HTTPStatus.badRequest)
            }
            
            if let error = response.error {
                return NSFWMediaResponse(detectedNudity: false, error: error)
            }
            
            guard let nudity = response.nudity else {
                throw Abort(HTTPStatus.badRequest)
            }
            
            return NSFWMediaResponse(detectedNudity: nudity.raw >= max(nudity.partial, nudity.safe) || nudity.partial >= max(nudity.raw, nudity.safe), error: nil)
        }
    }
    
    private func sightEnginePostDetectNudity(on request: Request, file: File) throws -> Future<SightEngineNudityDetectionResponse?> {
        guard let apiUser = Environment.get("SIGHT_ENGINE_API_USER_KEY") else {
            print("No sight engine api user key in enviroment")
            return Future.map(on: request) { return nil }
        }
        
        guard let apiSecret = Environment.get("SIGHT_ENGINE_API_SECRET_KEY") else {
            print("No sight engine api secret key in enviroment")
            return Future.map(on: request) { return nil }
        }
        let client = try request.make(Client.self)
        var headers = HTTPHeaders()
        headers.add(name: "api_user", value: apiUser)
        headers.add(name: "api_secret", value: apiSecret)
        let response = client.post("https://api.sightengine.com/1.0/nudity.json", headers: headers) { req in
            try req.content.encode(SightEngineFile(media: file), as: .formData)
        }
        
        let data = response.flatMap(to: SightEngineNudityDetectionResponse.self) { response in
            return try response.content.decode(SightEngineNudityDetectionResponse.self)
        }
        
        return data.flatMap { data in
            return Future.map(on: request) {
                return data
            }
        }
    }
}
