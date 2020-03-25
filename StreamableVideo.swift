//
//  StreamableVideo.swift
//

import Foundation
import AVKit

class StreamableVideo {
    static let shared = StreamableVideo()
    
    private var username:String = ""
    private var password:String = ""
    
    func authenticate(username:String, password:String) {
        self.username = username
        self.password = password
    }
    
    // getThumbnail takes a Streamable shortcode. The completion block is executed with a UIImage parameter after receiving the API response.
    func getThumbnail(shortcode:String, completion: @escaping (UIImage?) -> ()){
        getVideoResource(shortcode: shortcode) { response in
            if let response = response {
                guard let url = URL(string: "https:\(response.thumbnailURL)") else {
                    completion(nil)
                    return
                }
                do {
                    let imageData = try Data(contentsOf: url)
                    let image = UIImage(data: imageData)
                    completion(image)
                } catch {
                    completion(nil)
                }
            }
            else{
                completion(nil)
            }
        }
    }
    
    // getTitleAndThumbnail takes a Streamable shortcode. The completion block is executed with String (title) and UIImage (thumbnail) parameters after receiving the API response.
    func getTitleAndThumbnail(shortcode:String, completion: @escaping (_ title:String?, _ thumbnail:UIImage?) -> ()){
        getVideoResource(shortcode: shortcode) { response in
            if let response = response {
                guard let url = URL(string: "https:\(response.thumbnailURL)") else {
                    completion(response.title, nil)
                    return
                }
                do {
                    let imageData = try Data(contentsOf: url)
                    let image = UIImage(data: imageData)
                    completion(response.title, image)
                } catch {
                    print("Couldn't get thumbnail for video \(shortcode)")
                    completion(response.title, nil)
                }
            }
            else{
                completion(nil, nil)
            }
        }
    }
    
    // getVideoItem takes a Streamable shortcode. The completion block is executed with a AVPlayerItem parameter after receiving the API response.
    func getVideoItem(shortcode:String, completion: @escaping (AVPlayerItem?) -> ()) {
        getVideoResource(shortcode: shortcode) { response in
            if let response = response, let path = response.files.mp4.url {
                guard let url = URL(string: "https:\(path)") else {
                    completion(nil)
                    return
                }
                let item = AVPlayerItem(url: url)
                completion(item)
            }
            else{
                completion(nil)
            }
        }
    }
    
    // getVideoItem takes a Streamable shortcode. The completion block is executed with a URL parameter after receiving the API response.
    func getVideoURL(shortcode:String, completion: @escaping (URL?) -> ()) {
        getVideoResource(shortcode: shortcode) { response in
            if let response = response, let path = response.files.mp4.url {
                let url = URL(string: "https:\(path)")
                completion(url)
            }
            else{
                completion(nil)
            }
        }
    }
    
    // getVideoItem takes a Streamable shortcode. The completion block is executed with a StreamableVideoResource parameter after receiving the API response.
    func getVideoResource(shortcode:String, completion: @escaping (StreamableVideoResource?) -> ()) {
        let url = URL(string: "https://api.streamable.com/videos/\(shortcode)")!
        var request = URLRequest(url: url)
        
        let loginString = "\(self.username):\(self.password)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            completion(nil)
            return
        }
        let base64LoginString = loginData.base64EncodedString(options: [])
        
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("couldnt get")
                print(error?.localizedDescription ?? "No data")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(StreamableVideoResource.self, from: data)
                completion(json)
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                completion(nil)
            }
        }

        task.resume()
    }
}

// MARK: - StreamableVideoResource
// StreamableVideoResource is a struct that wraps the JSON response from the Streamable API.
struct StreamableVideoResource: Codable {
    let status, percent: Int
    let url, embedCode, thumbnailURL, title: String
    let message, source: JSONNull?
    let files: StreamableFiles

    enum CodingKeys: String, CodingKey {
        case status, percent, url
        case embedCode = "embed_code"
        case message, files
        case thumbnailURL = "thumbnail_url"
        case title, source
    }
}

// MARK: - Files
struct StreamableFiles: Codable {
    let mp4, original: MP4
}

// MARK: - MP4
struct MP4: Codable {
    let status: Int?
    let url: String?
    let framerate, height, width, bitrate: Int
    let size, duration: Int
}

// MARK: - JSONNull Encode and Decode helper

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

