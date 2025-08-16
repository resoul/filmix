##

PHP:

```php
$data = new StreamProvider(url: "https://filmix.my/path/to/video.html")->getStreamData();
```

Swift:

```swift
if let sp = StreamProvider(url: "https://filmix.my/film/triller/173398-v-megan-k-vashim-uslugam-2024.html") {
    sp.getStreamData { stream in
        print("Stream data: \(stream)")
    }
}
```