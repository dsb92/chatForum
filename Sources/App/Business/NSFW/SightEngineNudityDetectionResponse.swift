import Foundation

// MARK: - SightEngineNudityDetectionResponse
struct SightEngineNudityDetectionResponse: Codable {
    let status: String
    let request: SightEngineRequest
    let nudity: SightEngineNudity?
    let media: SightEngineMedia?
    var error: SightEngineError?
}

// MARK: - SightEngineMedia
struct SightEngineMedia: Codable {
    let id: String
    let uri: String
}

// MARK: - SightEngineNudity
struct SightEngineNudity: Codable {
    let raw: Double
    let partial: Double
    let safe: Double
}

// MARK: - SightEngineRequest
struct SightEngineRequest: Codable {
    let id: String
    let timestamp: Double
    let operations: Int
}

// MARK: - SightEngineError
struct SightEngineError: Codable {
    let type: String
    let code: Int
    let message: String
}
