#  Find

Find 1.3 is separated into targets. Inside each target, if there is a `Controller`, make one by just calling the initializer. If there is only a view controller, use the static `make` function.

Example:

```swift
/// The Photos target has a `PhotosController`. 
lazy var photos = PhotosController(model: photosViewModel, toolbarViewModel: toolbarViewModel, realmModel: realmModel)

/// The `SearchBar` target only has `SearchViewController`. 
lazy var searchViewController = SearchViewController.make(searchViewModel: searchViewModel, realmModel: realmModel)
```
