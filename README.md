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


In Photos, applying a snapshot can be time-consuming when updating highlight colors on the fly. So **don't** call:

```swift
func updateResults(animate: Bool = true) {
```

Instead, just get the current find photo inside the cell provider.

```swift
guard let findPhoto = self.model.resultsState?.findPhotos.first(where: { $0.photo == cachedFindPhoto.photo }) else { return cell }
```


Angles rotation | Change the highlight length based on angle
--- | ---
![Angles](Assets/Angles.jpg) | ![Angles](Assets/AnglesLength.jpg)


Make sure to configure the window if using safe areas

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let _ = (scene as? UIWindowScene) else { return }
    
    /// here!
    ConstantVars.configure(window: window)
    if let window = window {
        Global.window = window
    }
}
```
