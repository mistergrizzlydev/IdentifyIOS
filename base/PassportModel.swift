//
//  PassportModel.swift
//  IDCardPassportNFCReader
//
//  Created by AliOzdem on 10.06.2020.
//  Copyright © 2020 AliMert. All rights reserved.
//

import Foundation
import UIKit

public class PassportModel {

    public var documentImage: UIImage = UIImage()
    public var documentType: String = ""
    public var countryCode: String = ""
    public var surnames: String = ""
    public var givenNames: String = ""
    public var documentNumber: String = ""
    public var nationality: String = ""
    public var birthDate: Date? = Date()
    public var sex: String = ""
    public var expiryDate: Date? = Date()
    public var personalNumber: String = ""

    public init() { }

    public init(documentNumber: String, birthDate: Date, expiryDate: Date) {
        self.documentNumber = documentNumber
        self.birthDate = birthDate
        self.expiryDate = expiryDate
    }

}

public class IdentifyCard: Codable {
    var ident_id: String?
    var name: String?
    var surname: String?
    var personalNumber: String?
    var birthDate: String?
    var expireDate: String?
    var serialNumber: String?
    var nationality: String?
    var docType: String?
    var authority: String?
    var gender: String?
    var image: String?
    var mrzInfo: String?
    
    public init(ident_id: String?, name: String?, surname: String?, personalNumber: String?, birthdate: String?, expireDate: String?, serialNumber: String?, nationality: String?, docType: String?, authority: String?, gender: String?, image: String?, mrzInfo: String?) {
        self.ident_id = ident_id
        self.name = name
        self.surname = surname
        self.personalNumber = personalNumber
        self.birthDate = birthdate
        self.expireDate = expireDate
        self.serialNumber = serialNumber
        self.nationality = nationality
        self.docType = docType
        self.authority = authority
        self.gender = gender
        self.image = image
        self.mrzInfo = mrzInfo
    }
    
    init() {}
    
}
