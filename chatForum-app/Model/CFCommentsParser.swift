//
//	CFCommentsParser.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper
import SwiftyJSON

class CFCommentsParser : NSObject, NSCoding, Mappable{

	var comments : [CFComment]?


	class func newInstance(map: Map) -> Mappable?{
		return CFCommentsParser()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		comments <- map["comments"]
		
	}
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        comments = [CFComment]()
        let commentsArray = json["comments"].arrayValue
        for commentsJson in commentsArray{
            let value = CFComment(fromJson: commentsJson)
            comments?.append(value)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if comments != nil{
            var dictionaryElements = [[String:Any]]()
            for commentsElement in comments! {
                dictionaryElements.append(commentsElement.toDictionary())
            }
            dictionary["comments"] = dictionaryElements
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         comments = aDecoder.decodeObject(forKey: "comments") as? [CFComment]

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if comments != nil{
			aCoder.encode(comments, forKey: "comments")
		}

	}

}
