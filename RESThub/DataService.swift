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


    func fetchGists(completion: @escaping(Result<Any, Error>) -> Void){
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
        componentURL.path = "/gists/public"

        guard let validURL = componentURL.url else {
            print("URL creation failed... - \(#file) - \(#function) - \(#line)")
            return
        }

        URLSession.shared.dataTask(with: validURL) { (data, response, error) in


            if let httpResponse = response as? HTTPURLResponse {
                print("API status: \(httpResponse.statusCode)")
            }
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }

//            print(String(data: validData, encoding: .utf8))

            do {

                let json = try JSONSerialization.jsonObject(with: validData, options: [])
                print(json)
                completion(.success(json))

            } catch  let serializationError {
                print("\(serializationError.localizedDescription) - \(#file) - \(#function) - \(#line)")
                completion(.failure(error!))
            }


        }.resume()

    }
}
