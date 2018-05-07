//
//  Operators.swift
//  ComponentStudio
//
//  Created by devin_abbott on 7/31/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

infix operator ?=

func ?=<T> (left: inout T?, right: T) {
    if left == nil {
        left = right
    }
}
