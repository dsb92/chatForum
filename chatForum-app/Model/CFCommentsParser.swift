//
//	CFCommentsParser.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


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