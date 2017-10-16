//
//  TableViewEnum.swift
//  NerdJokes
//
//  Created by Nicholas Lash on 10/16/17.
//  Copyright © 2017 Id Raja. All rights reserved.
//

import UIKit

protocol TableViewEnum: RawRepresentable {
    var cellIdentifier: String { get }
    var height: CGFloat { get }
    var name: String { get }
    static var registrationCells: [Self] { get }
}
