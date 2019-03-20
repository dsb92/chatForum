//
//	CFComment.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class CFComment : NSObject, NSCoding, Mappable{

	var comment : String?
	var id : String?
	var postID : String?
	var updatedAt : String?


	class func newInstance(map: Map) -> Mappable?{
		return CFComment()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		comment <- map["comment"]
		id <- map["id"]
		postID <- map["postID"]
		updatedAt <- map["updatedAt"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         comment = aDecoder.decodeObject(forKey: "comment") as? String
         id = aDecoder.decodeObject(forKey: "id") as? String
         postID = aDecoder.decodeObject(forKey: "postID") as? String
         updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if comment != nil{
			aCoder.encode(comment, forKey: "comment")
		}
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if postID != nil{
			aCoder.encode(postID, forKey: "postID")
		}
		if updatedAt != nil{
			aCoder.encode(updatedAt, forKey: "updatedAt")
		}

	}

}