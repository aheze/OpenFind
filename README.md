#  Find

Find 1.3 is separated into targets. Inside each target, if there is a `Controller`, make one by just calling the initializer. If there is only a view controller, use the static `make` function.

Example:

```swift
/// The Photos target has a `PhotosController`. 
lazy var photos = PhotosController(model: photosViewModel, toolbarViewModel: toolbarViewModel, realmModel: realmModel)

/// The `SearchBar` target only has `SearchViewController`. 
lazy var searchViewController = SearchViewController.make(searchViewModel: searchViewModel, realmModel: realmModel)
```

SearchNavigationController's transitions are inside `SearchNC+ViewTransitioning.swift`. If there is a custom animator, you must call the search bar hide/show methods.

TODO: Check presenting a different way. Below it only works for Lists Details.
```swift
/// check if is presenting
if viewController is ListsDetailViewController {
    self.showDetailsSearchBar(true)
} else {
    self.showDetailsSearchBar(false)
}
```

`SearchViewModel`'s `highlightingAddWordField` can result in unwanted side effects in getting a target offset for scrolling. Make sure to set this to false first.
