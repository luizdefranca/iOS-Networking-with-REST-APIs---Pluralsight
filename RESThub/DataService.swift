//
//  DataService.swift
//  RESThub
//
//  Created by Luiz on 11/22/19.
//  Copyright © 2019 Harrison. All rights reserved.
//

import Foundation

class DataService {

    static let shared = DataService()
    fileprivate let baseURLString = "https://api.github.com"


    func fetchGists(){
        //Differents ways to create a url path

        //1 - Using URL for the baseURL and appendPathComponent to add a new path
        /*
        var baseURL = URL(string: baseURLString)
        baseURL?.appendPathComponent("/somePath")
        */

        //2 - Using URL(string:, relativeTo:) method to add the new path component to a baseURL
//        let compusedURL = URL(string: "/somePath" , relativeTo: baseURL)


        //3 - Using URLComponents
        var componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "api.github.com"
        componentURL.path = "/somePath"


//        print(baseURL!)
//        print(compusedURL?.absoluteString ?? "Relative URL failed")
        print(componentURL.url!)
    }
}
