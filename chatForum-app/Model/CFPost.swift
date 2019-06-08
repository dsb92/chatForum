//
//	CFPost.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct CFPost : Codable {
	let backgroundColorHex : String?
	let id : String?
	let text : String?
	let updatedAt : String?
    let numberOfComments: Int?
    var numberOfLikes: Int?
    var numberOfDislikes: Int?
    var imageIds: [UUID]?
    var videoIds: [UUID]?
}
