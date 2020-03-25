# StreamableVideo
StreamableVideo is a simple Swift wrapper for the [Streamable API](https://streamable.com/documentation).

## Installation
---
Copy **StreamableVideo.swift** into your project.

## Usage
---
StreamableVideo abstracts out Streamable API calls and uses the `shared` singleton design pattern. It provides completion block-style methods similar to `URLRequest` to access Streamable video assets, thumbnails, and titles. Each method takes a Streamable video shortcode as a parameter and returns the requested resource(s) as parameters to the completion block.


### Authenticate
---
All requests to the Streamable API must be authenticated using Basic Auth. See https://streamable.com/documentation for more information. To provide your credentials to StreamableVideo, call
```swift
StreamableVideo.shared.authenticate(username: “user@email.com”, password: “Pa$$word”)
```
The StreamableVideo singleton will hold on to these credentials, so this only needs to be called once in your app’s lifecycle!


### Get Thumbnail
---
```swift
func getThumbnail(shortcode:String, completion: @escaping (UIImage?) -> ())
```
Takes a Streamabale shortcode and passes the associated thumbnail to the completion block as a `UIImage`.

##### Example
```swift
StreamableVideo.shared.getThumbnail(shortcode: "moo") { image in
    DispatchQueue.main.async {
        let imageView = UIImageView(image: image)
        self.view.addSubview(imageView)
    }
}
```

### Get Thumbnail and Title
---
```swift
func getTitleAndThumbnail(shortcode:String, completion: @escaping (_ title:String?, _ thumbnail:UIImage?) -> ())
```
Takes a Streamabale shortcode and passes the associated title and thumbnail to the completion block as a `String` and `UIImage`.

##### Example
```swift
StreamableVideo.shared.getTitleAndThumbnail(shortcode: "moo") { (title, image) in
    DispatchQueue.main.async {
    	let videoTitle = title ?? "blank"
        print("the title is \(videoTitle)")

        let imageView = UIImageView(image: image)
        self.view.addSubview(imageView)
    }
}
```

### Get Video Item
---
```swift
func getVideoItem(shortcode:String, completion: @escaping (AVPlayerItem?) -> ())
```
Takes a Streamabale shortcode and passes the associated video to the completion block as an `AVPlayerItem`.

##### Example
```swift
StreamableVideo.shared.getVideoItem(shortcode: "moo") { item in
    if let item = item {
        DispatchQueue.main.async {
            let player = AVPlayer(playerItem: playerItem)
            // ...
        }
    }
}
```

### Get Video URL
---
```swift
func getVideoURL(shortcode:String, completion: @escaping (URL?) -> ())
```
Takes a Streamabale shortcode and passes the associated URL to the completion block as a `URL`.

##### Example
```swift
StreamableVideo.shared.getVideoURL(shortcode: "moo") { url in
    if let url = url {
        DispatchQueue.main.async {
            // work with url ...
        }
    }
}
```

### Get Video Resource
---
```swift
func getVideoResource(shortcode:String, completion: @escaping (StreamableVideoResource?) -> ())
```
Takes a Streamabale shortcode and passes a `StreamableVideoResource` struct to the completion handler.
`StreamableVideoResource` is a struct that wraps the JSON response from the Streamable API.

##### Example
```swift
StreamableVideo.shared.getVideoResource(shortcode: "moo") { response in
    if let response = response {
    	// work with StreamableVideoResource API response info as needed ...
    }
}
```