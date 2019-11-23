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


    func fetchGists(completion:
        //@escaping(Result<Any, Error>) // way 1 - using JSONSerialization.jsonObject
        @escaping(Result<[Gist], Error>) //way 2 - using JSONDecoder().decode and codable
        -> Void){
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

                //There are two ways to deserializate um data object

                //way 1 - Deserialization using JSONSerialization.jsonObject
               // let json = try JSONSerialization.jsonObject(with: validData, options: [])

                //way 2 - Using JSONDecoder and a codable struct or class

                let gists = try JSONDecoder().decode( [Gist].self, from: validData)
                completion(.success(gists))

            } catch  let serializationError {
                print("\(serializationError.localizedDescription) - \(#file) - \(#function) - \(#line)")
                completion(.failure(error!))
            }


        }.resume()

    }


    func createNewGist(completion: @escaping(Result<Any, Error>) -> Void){
        let postComponents = createURLComponents(path: "/gists")
        guard let composedURL = postComponents.url else {
            print("URL creation failed...")
            completion(.failure(CustomError.urlFailed))
            return
        }



        var postRequest = URLRequest(url: composedURL)
        postRequest.httpMethod = "POST"

        let authString =
//        "luizramospe@hotmail.com:.Lucas2014"
        "de0f1f28817a1b69589bf184b5ee3305fb662fb7"
        var authStringBase64 = ""

        if let authData = authString.data(using: .utf8) {
            authStringBase64 = authData.base64EncodedString()
        }

        postRequest.setValue("token \(authString)", forHTTPHeaderField: "Authorization")
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")



        let newGist = Gist(id: nil, isPublic: true, description: "A brand new gist", files: ["test_file.txt": File(content: "hello")])

        do {
            let gistData = try JSONEncoder().encode(newGist)
            postRequest.httpBody = gistData
        } catch  {
            print("Gist encoding failed")
            completion(.failure(error))
        }
        URLSession.shared.dataTask(with: postRequest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                print(httpResponse.debugDescription)
                print(httpResponse.description)
            }

            guard let validData = data, error == nil else {
                completion(.failure(error!))
                print("\(error!.localizedDescription) - \(#file) - \(#function) - \(#line)")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: validData, options: [])
                completion(.success(json))
            } catch let serializationError{
                print("\(serializationError.localizedDescription) - \(#file) - \(#function) - \(#line)")
                completion(.failure(serializationError))
            }

        }.resume()
    }

    func createURLComponents(path: String) -> URLComponents{
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        return components
    }
}

enum CustomError : Error {
    case urlFailed

}
