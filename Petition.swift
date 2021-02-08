//
//  Petition.swift
//  project7
//
//  Created by Arnold Mitricã on 23/10/2020.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
struct Petitions: Codable {
    var results: [Petition]
}
