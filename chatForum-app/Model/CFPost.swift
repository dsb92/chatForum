//
//	CFPost.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper
import SwiftyJSON

class CFPost : NSObject, NSCoding, Mappable{

	var id : String?
	var text : String?
	var updatedAt : String?
    var backgroundColorHex : String?

	class func newInstance(map: Map) -> Mappable?{
		return CFPost()
	}
	required init?(map: Map){}
    override init(){}

	func mapping(map: Map)
	{
		id <- map["id"]
		text <- map["text"]
		updatedAt <- map["updatedAt"]
		backgroundColorHex <- map["backgroundColorHex"]
	}
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].stringValue
        text = json["text"].stringValue
        updatedAt = json["updatedAt"].stringValue
        backgroundColorHex = json["backgroundColorHex"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if id != nil{
            dictionary["id"] = id
        }
        if text != nil{
            dictionary["text"] = text
        }
        if updatedAt != nil{
            dictionary["updatedAt"] = updatedAt
        }
        if backgroundColorHex != nil{
            dictionary["backgroundColorHex"] = backgroundColorHex
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         id = aDecoder.decodeObject(forKey: "id") as? String
         text = aDecoder.decodeObject(forKey: "text") as? String
         updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as? String
        backgroundColorHex = aDecoder.decodeObject(forKey: "backgroundColorHex") as? String
	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if text != nil{
			aCoder.encode(text, forKey: "text")
		}
		if updatedAt != nil{
			aCoder.encode(updatedAt, forKey: "updatedAt")
		}
        if backgroundColorHex != nil{
            aCoder.encode(backgroundColorHex, forKey: "backgroundColorHex")
        }
	}
}
