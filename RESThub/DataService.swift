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
    let customSession: URLSession  = {
        let customConfig = URLSessionConfiguration.default

        //To download or upload while the app is suspended is necessary to use backgroundSession
//        let backgroundSession = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        customConfig.networkServiceType = .video
        customConfig.allowsCellularAccess = true
        return URLSession(configuration: customConfig)
    }()

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



        postRequest.setValue("token \(createAuthCredential())", forHTTPHeaderField: "Authorization")
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

    func starnUnstarGist(id: String, star: Bool, completion: @escaping(Bool) -> Void) {
        let starComponents = createURLComponents(path: "/gists/\(id)/star")
        guard let composedURL = starComponents.url else {
            print("Component composition failed... -\(#file) - \(#function) - \(#line)")
            return
        }
        var starRequest = URLRequest(url: composedURL)
        starRequest.httpMethod = star == true ? "PUT" : "DELETE"
        starRequest.setValue("0", forHTTPHeaderField: "Content-Lenght")
        starRequest.setValue("token \(createAuthCredential())", forHTTPHeaderField: "Authorization")
        starRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        starRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: starRequest) { (data, response, error) in

            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 204 {
                    completion(true)
                } else {
                    completion(false)
                }

            }
        }.resume()

    }

    func createAuthCredential() -> String {
        let authString = "65f1330f0ad79f4c87e592f84bb0f091bd7db730"
        //In this case we are using the token, so the next lines are commented
//        var authStringBase64 = ""
//
//        if let authData = authString.data(using: .utf8) {
//            authStringBase64 = authData.base64EncodedString()
//        }
        return authString
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
