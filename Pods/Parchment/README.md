<p align="center">
  <img src="https://rechsteiner-parchment.s3.eu-central-1.amazonaws.com/parchment-title-3.png" width="240" height="70" />
</p>

<p align="center">
    <strong><a href="#getting-started">Getting Started</a></strong> |
    <strong><a href="#customization">Customization</a></strong> |
    <strong><a href="#installation">Installation</a></strong>
</p>

<p align="center">
  <a href="https://circleci.com/gh/rechsteiner/Parchment"><img src="https://circleci.com/gh/rechsteiner/Parchment/tree/master.svg?style=shield&circle-token=8e4da6c8bf09271f72f32bf3c7a7c9d743ff50fb" /></a>
  <a href="https://cocoapods.org/pods/Parchment"><img src="https://img.shields.io/cocoapods/v/Parchment.svg" /></a>
  <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg" /></a>
</p>

<br/>

<p align="center">
  <img src="https://rechsteiner-parchment.s3.eu-central-1.amazonaws.com/parchment-delegate.gif" alt="Cities Example" />
  <img src="https://rechsteiner-parchment.s3.eu-central-1.amazonaws.com/parchment-unplash.gif" alt="Unsplash Example" />
  <img src="https://rechsteiner-parchment.s3.eu-central-1.amazonaws.com/parchment-calendar.gif" alt="Calendar Example" />
</p>

## Features

Parchment is a very flexible paging view controller. It let’s you page between view controllers while showing any type of generic indicator that scrolls along with the content. Here are some benefits of using Parchment:

* **Memory-efficient**: <br/> Parchment only allocates view controllers when they’re needed, meaning if you have a lot of view controllers you don’t have to initialize them all up-front.

* **Infinite scrolling**: <br /> Because view controllers are only allocated as you are scrolling, you can create data sources that are infinitely large. This is perfect for things like [calendars](Documentation/infinite-data-source.md).

* **Highly customizable** <br/> The menu items are built using
  `UICollectionView`, which means you can display pretty much whatever you want. You can even subclass the layout to create completely custom behaviours.

## Getting Started

### Basic usage

The easiest way to use Parchment is to use the `FixedPagingViewController` subclass. Just
pass in an array of view controllers and Parchment will generate menu items for each view controller using their
`title` property:

```Swift
let firstViewController = UIViewController()
let secondViewController = UIViewController()

let pagingViewController = FixedPagingViewController(viewControllers: [
  firstViewController,
  secondViewController
])
```

See: [Using FixedPagingViewController](Documentation/fixed-view-controller.md)

### Data source

Using `FixedPagingViewController` is fine in most cases, but if you have more than a few view controllers you probably don't want to allocate them all up-front. If you're going to display a fixed number of view controllers, you can setup your own data source by implementing `PagingViewControllerDataSource`:

```Swift
extension ViewController: PagingViewControllerDataSource {

    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int {
        return 10
    }

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        return ItemViewController(index: index)
    }

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> PagingItem {
        return PagingIndexItem(index: index, title: "View \(index)")
    }
}
```

Then you need to set the `dataSource` property and select the initial item:

```Swift
let pagingViewController = PagingViewController()
pagingViewController.dataSource = self
pagingViewController.select(index: 0)
```

Using the data source means Parchment will only allocate view controllers for the currently selected item and any of its siblings. This is a lot more memory efficient than using `FixedPagingViewController` if you have many view controllers.

See: [Using custom data source](Documentation/data-source.md)

### Infinite data source

Using the `PagingViewControllerDataSource` protocol means you need to know how many view controllers to display. If you’re creating something like a calendar, the number of view controllers can be infinitely large. In that case you can use the `PagingViewControllerInfiniteDataSource` protocol:

```Swift
extension ViewController: PagingViewControllerInfiniteDataSource {

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForPagingItem pagingItem: T) -> UIViewController {
    return ItemViewController(item: pagingItem)
  }

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemBeforePagingItem pagingItem: T) -> T? {
    guard let item = pagingItem as? IndexedPagingItem else { return nil }
    return Item(index: item.index - 1)
  }

  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemAfterPagingItem pagingItem: T) -> T? {
    guard let item = pagingItem as? IndexedPagingItem else { return nil }
    return Item(index: item.index + 1)
  }
}
```

Then set the `infiniteDataSource` property and select the initial item:

```Swift
let pagingViewController = PagingViewController()
pagingViewController.infiniteDataSource = self
pagingViewController.select(pagingItem: Item(index: 0))
```

This pattern is very similar to the
[UIPageViewControllerDataSource](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIPageViewControllerClassReferenceClassRef/)
protocol. The main difference is that instead of returning view controllers directly, you have to return an instance conforming to the `PagingItem` protocol. Parchment will recursively call these methods for the selected `PagingItem` until the available space is filled up.

See: [Using infinite data source](Documentation/infinite-data-source.md)

## Selecting items

You can select items programatically using:

```Swift
func select(pagingItem: PagingItem, animated: Bool = false)
```

Or if you have set the `dateSource` property, you can select items based on their index:

```Swift
func select(index: Int, animated: Bool = false)
```

## Reload data

You can reload data using this method:

```Swift
func reloadData()
```

This will keep the previously selected item if it's still part of the
updated data. If not, it will select the first item in the list. It
will also reload the view controllers displayed in the page view
controller. If you only want to reload the menu items, you can use
this method:

```Swift
func reloadMenu()
```

Calling `reloadData()` will not work when using
`PagingViewControllerInfiniteDataSource`, as we then need to know what
the initial item should be. In that case you should use this method:

```Swift
func reloadData(around: PagingItem)
```

This will mark the given paging item as selected and generate new items around it.

## Delegate

Parchment provides delegate methods for every step of the transition process through the `PagingViewControllerDelegate` protocol. You can also use this to manually control the width of your menu items.

```Swift
protocol PagingViewControllerDelegate: class {

  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    isScrollingFromItem currentPagingItem: T,
    toItem upcomingPagingItem: T?,
    startingViewController: UIViewController,
    destinationViewController: UIViewController?,
    progress: CGFloat)

  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    willScrollToItem pagingItem: T,
    startingViewController: UIViewController,
    destinationViewController: UIViewController)

  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    didScrollToItem pagingItem: T,
    startingViewController: UIViewController?,
    destinationViewController: UIViewController,
    transitionSuccessful: Bool)

  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    widthForPagingItem pagingItem: T,
    isSelected: Bool) -> CGFloat?
}
```

## Customization

Parchment is built to be very flexible. All customization is handled by the properties listed below. The menu items are displayed using `UICollectionView`, so they can display pretty much whatever you want (see: [`menuItemClass`](#`menuItemClass`)). If you need any further customization you can even subclass the collection view layout.

#### `menuItemSize`

The size for each of the menu items.

```Swift
enum PagingMenuItemSize {
  case fixed(width: CGFloat, height: CGFloat)

  // Tries to fit all menu items inside the bounds of the screen.
  // If the items can't fit, the items will scroll as normal and
  // set the menu items width to `minWidth`.
  case sizeToFit(minWidth: CGFloat, height: CGFloat)
}
```

_Default: `.sizeToFit(minWidth: 150, height: 40)`_

#### `menuHorizontalAlignment`

```Swift
enum PagingMenuHorizontalAlignment {
  case `default`

  // Allows all paging items to be centered within the paging menu
  // when PagingMenuItemSize is .fixed and the sum of the widths
  // of all the paging items are less than the paging menu
  case center
}
```

_Default: `.default`_

#### `menuTransition`

Determine the transition behaviour of menu items while scrolling the content.

```Swift
enum PagingMenuTransition {
  // Update scroll offset based on how much the content has
  // scrolled. Makes the menu items transition smoothly as you scroll.
  case scrollAlongside

  // Animate the menu item position after a transition has completed.
  case animateAfter
}
```

_Default: `.scrollAlongside`_

#### `menuInteraction`

Determine how users can interact with the menu items.

```Swift
enum PagingMenuInteraction {
  case scrolling
  case swipe
  case none
}
```

_Default: `.scrolling`_

#### `menuItemClass`

The class type for the menu item. Override this if you want your own custom menu items.

_Default: `PagingTitleCell.self`_

#### `menuItemSpacing`

The spacing between the menu items.

_Default: `0`_

#### `menuInsets`

The insets around all of the menu items.

_Default: `UIEdgeInsets()`_

#### `selectedScrollPosition`

The scroll position of the selected menu item:

```Swift
enum PagingSelectedScrollPosition {
  case left
  case right

  // Centers the selected menu item where possible. If the item is
  // to the far left or right, it will not update the scroll position.
  // Effectivly the same as .centeredHorizontally on UIScrollView.
  case preferCentered
}
```

_Default: `.preferCentered`_

#### `indicatorOptions`

Add a indicator view to the selected menu item. The indicator width will be equal to the selected menu items width. Insets only apply horizontally.

```Swift
enum PagingIndicatorOptions {
  case hidden
  case visible(
    height: CGFloat,
    zIndex: Int,
    spacing: UIEdgeInsets,
    insets: UIEdgeInsets)
}
```

_Default:_

```Swift
.visible(
  height: 4,
  zIndex: Int.max,
  spacing: UIEdgeInsets.zero,
  insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
```

#### `indicatorClass`

The class type for the indicator view. Override this if you want your use your own subclass of `PagingIndicatorView`.

_Default: `PagingIndicatorView.self`_

#### `indicatorColor`

The background color for the indicator view.

_Default: `UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)`_

#### `borderOptions`

Add a border at the bottom of the menu items. The border will be as wide as all the menu items. Insets only apply horizontally.

```Swift
enum PagingBorderOptions {
  case hidden
  case visible(
    height: CGFloat,
    zIndex: Int,
    insets: UIEdgeInsets)
}
```

_Default:_

```Swift
.visible(
  height: 1,
  zIndex: Int.max - 1,
  insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
```

#### `borderClass`

The class type for the border view. Override this if you want your use your own subclass of `PagingBorderView`.

_Default: `PagingBorderView.self`_

#### `borderColor`

The background color for the border view.

_Default: `UIColor(white: 0.9, alpha: 1)`_

#### `includeSafeAreaInsets`

Updates the content inset for the menu items based on the `.safeAreaInsets` property.

_Default: `true`_

#### `font`

The font used for title label on the menu items.

_Default: `UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)`_

#### `selectedFont`

The font used for title label on the currently selected menu item.

_Default: `UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)`_

#### `textColor`

The color of the title label on the menu items.

_Default: `UIColor.black`_

#### `selectedTextColor`

The text color for the currently selected menu item.

_Default: `UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)`_

#### `backgroundColor`

The background color for the menu items.

_Default: `UIColor.white`_

#### `menuBackgroundColor`

The background color for the view behind the menu items.

_Default: `UIColor.white`_

## Installation

Parchment will be compatible with the lastest public release of Swift.

### CocoaPods

Parchment is available through [CocoaPods](https://cocoapods.org). To install it, add the following to your `Podfile`:

`pod 'Parchment'`

### Carthage

Parchment also supports [Carthage](https://github.com/Carthage/Carthage). To install it, you need to do the following steps:

1. Add `github "rechsteiner/Parchment"` to your `Cartfile`
2. Run `carthage update`
3. Link `Parchment.framework` with you target
4. Add `$(SRCROOT)/Carthage/Build/iOS/Parchment.framework` to your
   `copy-frameworks` script phase

See [this guide](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for more details on using Carthage.

## Requirements

* iOS 8.2+
* Xcode 8.0+

## Acknowledgements

* Parchment uses [`EMPageViewController`](https://github.com/emalyak/EMPageViewController) as a replacement for `UIPageViewController`.

## Changelog

This can be found in the CHANGELOG file.

## Licence

Parchment is released under the MIT license. See LICENSE for details.
