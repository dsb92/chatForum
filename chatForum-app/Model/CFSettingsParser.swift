//
//	CFSettingsParser.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper


class CFSettingsParser : NSObject, NSCoding, Mappable{

	var colors : [CFColor]?


	class func newInstance(map: Map) -> Mappable?{
		return CFSettingsParser()
	}
	required init?(map: Map){}
	private override init(){}

	func mapping(map: Map)
	{
		colors <- map["colors"]
		
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         colors = aDecoder.decodeObject(forKey: "colors") as? [CFColor]

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if colors != nil{
			aCoder.encode(colors, forKey: "colors")
		}

	}

}
