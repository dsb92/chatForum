//
//	CFComment.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper
import SwiftyJSON

class CFComment : NSObject, NSCoding, Mappable{

	var comment : String?
	var id : String?
	var postID : String?
	var updatedAt : String?


	class func newInstance(map: Map) -> Mappable?{
		return CFComment()
	}
	required init?(map: Map){}
    override init(){}

	func mapping(map: Map)
	{
		comment <- map["comment"]
		id <- map["id"]
		postID <- map["postID"]
		updatedAt <- map["updatedAt"]
		
	}
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        comment = json["comment"].stringValue
        id = json["id"].stringValue
        postID = json["postID"].stringValue
        updatedAt = json["updatedAt"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if comment != nil{
            dictionary["comment"] = comment
        }
        if id != nil{
            dictionary["id"] = id
        }
        if postID != nil{
            dictionary["postID"] = postID
        }
        if updatedAt != nil{
            dictionary["updatedAt"] = updatedAt
        }
        return dictionary
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
