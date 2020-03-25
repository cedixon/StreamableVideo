# StreamableVideo
StreamableVideo is a simple Swift wrapper for the [Streamable API](https://streamable.com/documentation).

## Installation
Copy **StreamableVideo.swift** into your project.

## Usage
StreamableVideo abstracts out Streamable API calls and uses the singleton design pattern. It provides completion block-style methods similar to the `URLRequest` framework to easily access Streamable video assets, thumbnails, and titles. Each method takes a Streamable video shortcode as a parameter and returns the requested resource(s) as parameters to the completion block.

### Authenticate
All requests to the Streamable API must be authenticated using Basic Auth. See https://streamable.com/documentation for more information. To provide your credentials to StreamableVideo, call
```swift
StreamableVideo.shared.authenticate(username: “user@email.com”, password: “Pa$$word”)
```
The StreamableVideo singleton will hold on to these credentials, so this only needs to be called once in your app’s lifecycle!

### Get Thumbnail
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