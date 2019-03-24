//
//	CFColor.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class CFColor : NSObject, NSCoding, Mappable{

	var hexString : String?
	var id : String?


	class func newInstance(map: Map) -> Mappable?{
		return CFColor()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		hexString <- map["hexString"]
		id <- map["id"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         hexString = aDecoder.decodeObject(forKey: "hexString") as? String
         id = aDecoder.decodeObject(forKey: "id") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if hexString != nil{
			aCoder.encode(hexString, forKey: "hexString")
		}
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}

	}

}