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


`reloadItems` on diffable data sources takes in the old identifier.
```swift
/// reload the collection view at an index path.
func update(at indexPath: IndexPath, with metadata: PhotoMetadata) {
    guard let existingPhoto = dataSource.itemIdentifier(for: indexPath) else { return }
    var snapshot = dataSource.snapshot()
    snapshot.reloadItems([existingPhoto]) /// reload!
    dataSource.apply(snapshot)
}
```

So, you must get the up-to-date item inside `makeDataSource`'s closure.

```swift
/// get the current up-to-date photo first.
guard let photo = self.model.photos.first(where: { $0 == cachedPhoto }) else { return cell }
```


Calling `updateHighlightColors` crashes the app when the colors are changed from slides. So, update inside `transitionWillStart` instead.
```swift
model.updateSearchCollectionView?()
updateHighlightColors()
```

The error:
```
2022-03-14 12:02:52.735420-0700 Find-New[2346:1292593] [error] precondition failure: attribute failed to set an initial value: 2106424, ForEachChild<Array<Highlight>, UUID, HighlightView>
dyld4 config: DYLD_ROOT_PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot DYLD_LIBRARY_PATH=/Users/aheze/Library/Developer/Xcode/DerivedData/Find-cgxoislhsfjnddaeuqparoqndoef/Build/Products/Debug-iphonesimulator:/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/system/introspection DYLD_INSERT_LIBRARIES=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/libBacktraceRecording.dylib:/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/libMainThreadChecker.dylib:/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/Developer/Library/PrivateFrameworks/DTDDISupport.framework/libViewDebuggerSupport.dylib DYLD_FRAMEWORK_PATH=/Users/aheze/Library/Developer/Xcode/DerivedData/Find-cgxoislhsfjnddaeuqparoqndoef/Build/Products/Debug-iphonesimulator:/Users/aheze/Library/Developer/Xcode/DerivedData/Find-cgxoislhsfjnddaeuqparoqndoef/Build/Products/Debug-iphonesimulator/PackageFrameworks
CoreSimulator 783.5 - Device: iPhone 13 Pro Max (F1EC12A7-4B5F-4462-AC9C-ED54E50CD0C2) - Runtime: iOS 15.2 (19C51) - DeviceType: iPhone 13 Pro Max
AttributeGraph precondition failure: attribute failed to set an initial value: 2106424, ForEachChild<Array<Highlight>, UUID, HighlightView>.
```

`itemIdentifier` is unreliable and sometimes gives huge numbers (`9223372036854775807`)
```swift
guard let existingPhoto = dataSource.itemIdentifier(for: indexPath) else { return }
var snapshot = dataSource.snapshot()
snapshot.reloadItems([existingPhoto])
dataSource.apply(snapshot)
```

The log:
```
2022-03-15 17:48:38.532792-0700 Find-New[55662:2060180] *** Assertion failure in -[UICollectionViewData indexPathForItemAtGlobalIndex:], UICollectionViewData.mm:779
2022-03-15 17:48:38.585254-0700 Find-New[55662:2060180] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'request for index path for global index 9223372036854775807 when there are only 48 items in the collection view'
*** First throw call stack:
(
    0   CoreFoundation                      0x00000001803e1188 __exceptionPreprocess + 236
    1   libobjc.A.dylib                     0x0000000180193384 objc_exception_throw + 56
    2   Foundation                          0x0000000180746648 _userInfoForFileAndLine + 0
    3   UIKitCore                           0x00000001844b9c3c -[UICollectionViewData indexPathForItemAtGlobalIndex:] + 216
    4   UIKitCore                           0x00000001844bbb0c -[UICollectionViewData layoutAttributesForGlobalItemIndex:] + 28
    5   UIKitCore                           0x0000000184494920 -[UICollectionView _viewAnimationsForCurrentUpdateWithCollectionViewAnimator:] + 4452
    6   UIKitCore                           0x000000018449a5bc __102-[UICollectionView _updateWithItems:tentativelyForReordering:propertyAnimator:collectionViewAnimator:]_block_invoke.2082 + 248
    7   UIKitCore                           0x00000001852f46a8 +[UIView(Animation) performWithoutAnimation:] + 96
    8   UIKitCore                           0x000000018449967c -[UICollectionView _updateWithItems:tentativelyForReordering:propertyAnimator:collectionViewAnimator:] + 3184
    9   UIKitCore                           0x0000000184492da8 -[UICollectionView _endItemAnimationsWithInvalidationContext:tentativelyForReordering:animator:collectionViewAnimator:] + 11672
    10  UIKitCore                           0x000000018449bafc -[UICollectionView _performBatchUpdates:completion:invalidationContext:tentativelyForReordering:animator:animationHandler:] + 548
    11  UIKitCore                           0x000000018443d73c __179-[_UIDiffableDataSourceViewUpdater _performUpdateWithCollectionViewUpdateItems:dataSourceSnapshot:updateHandler:completion:viewPropertyAnimator:customAnimationsProvider:animated:]_block_invoke.30 + 248
    12  UIKitCore                           0x00000001844ab538 -[UICollectionView _performInternalBatchUpdates:] + 48
    13  UIKitCore                           0x00000001844ab378 -[UICollectionView _performDiffableUpdate:] + 96
    14  UIKitCore                           0x000000018443d174 -[_UIDiffableDataSourceViewUpdater _performUpdateWithCollectionViewUpdateItems:dataSourceSnapshot:updateHandler:completion:viewPropertyAnimator:customAnimationsProvider:animated:] + 588
    15  UIKitCore                           0x000000018443518c -[__UIDiffableDataSource _commitUpdate:snapshot:animated:completion:] + 856
    16  UIKitCore                           0x0000000184434a14 __122-[__UIDiffableDataSource _applyDifferencesFromSnapshot:viewPropertyAnimator:customAnimationsProvider:animated:completion:]_block_invoke.235 + 184
    17  UIKitCore                           0x0000000184434adc __122-[__UIDiffableDataSource _applyDifferencesFromSnapshot:viewPropertyAnimator:customAnimationsProvider:animated:completion:]_block_invoke.245 + 68
    18  libdispatch.dylib                   0x0000000109b61694 _dispatch_client_callout + 16
    19  libdispatch.dylib                   0x0000000109b7119c _dispatch_lane_barrier_sync_invoke_and_complete + 144
    20  UIKitCore                           0x0000000184434314 -[__UIDiffableDataSource _applyDifferencesFromSnapshot:viewPropertyAnimator:customAnimationsProvider:animated:completion:] + 960
    21  UIKitCore                           0x0000000184433a64 -[__UIDiffableDataSource applyDifferencesFromSnapshot:animatingDifferences:completion:] + 116
    22  libswiftUIKit.dylib                 0x00000001b64f9130 $s5UIKit34UICollectionViewDiffableDataSourceC5apply_20animatingDifferences10completionyAA010NSDiffableeF8SnapshotVyxq_G_SbyycSgtFTm + 196
    23  Find-New                            0x0000000105105034 $s8Find_New20PhotosViewControllerC13updateResults2at4withySi_AA13PhotoMetadataVtF + 1676
    24  Find-New                            0x0000000105116a40 $s8Find_New20PhotosViewControllerC13listenToModelyyFy10Foundation9IndexPathVSg_SiSgAA13PhotoMetadataVtcfU0_ + 904
    25  Find-New                            0x00000001051f7fdc $s8Find_New15PhotosViewModelC19updatePhotoMetadata5photo8metadata10reloadCellyAA0G0V_AA0gH0VSbtF + 2704
    26  Find-New                            0x000000010511a5d8 $s8Find_New23PhotosSlidesToolbarViewV10toggleStaryyF + 1176
    27  Find-New                            0x000000010511a134 $s8Find_New23PhotosSlidesToolbarViewV4bodyQrvg7SwiftUI05TupleF0VyAA0E10IconButtonV_AE6SpacerVAikikItGyXEfU_yycfU0_ + 32
    28  SwiftUI                             0x00000001b937fcc0 $s7SwiftUI18WrappedButtonStyle33_AEEDD090E917AC57C12008D974DC6805LLV8makeBody13configurationQrAA09PrimitivedE13ConfigurationV_tFyycAHcfu_yycfu0_TA + 20
    29  SwiftUI                             0x00000001b9835da4 $s7SwiftUI25PressableGestureCallbacksV8dispatch5phase5stateyycSgAA0D5PhaseOyxG_SbztFyycfU_ + 36
    30  SwiftUI                             0x00000001b947bc84 $sIeg_ytIegr_TR + 20
    31  SwiftUI                             0x00000001b947bca0 $sytIegr_Ieg_TR + 20
    32  SwiftUI                             0x00000001b947bc84 $sIeg_ytIegr_TR + 20
    33  SwiftUI                             0x00000001b94596ac $s7SwiftUI6UpdateO3endyyFZ + 504
    34  SwiftUI                             0x00000001b9528960 $s7SwiftUI19EventBindingManagerC4sendyySDyAA0C2IDVAA0C4Type_pGF + 188
    35  SwiftUI                             0x00000001b99e857c $s7SwiftUI18EventBindingBridgeC4send_6sourceySDyAA0C2IDVAA0C4Type_pG_AA0cD6Source_ptFTf4nen_nAA22UIKitGestureRecognizerC_Tg5 + 1840
    36  SwiftUI                             0x00000001b99e6cd0 $s7SwiftUI22UIKitGestureRecognizerC4send025_062C14327F4C9197D92807A7H6DF7F3BLL7touches5event5phaseyShySo7UITouchCG_So7UIEventCAA10EventPhaseOtF + 72
    37  SwiftUI                             0x00000001b99e7378 $s7SwiftUI22UIKitGestureRecognizerC12touchesBegan_4withyShySo7UITouchCG_So7UIEventCtFToTm + 160
    38  UIKitCore                           0x00000001848b9078 -[UIGestureRecognizer _componentsEnded:withEvent:] + 224
    39  UIKitCore                           0x0000000184e24dd0 -[UITouchesEvent _sendEventToGestureRecognizer:] + 660
    40  UIKitCore                           0x00000001848af2e8 __47-[UIGestureEnvironment _updateForEvent:window:]_block_invoke + 80
    41  UIKitCore                           0x00000001848aefd8 -[UIGestureEnvironment _updateForEvent:window:] + 456
    42  UIKitCore                           0x0000000184dd995c -[UIWindow sendEvent:] + 4324
    43  UIKitCore                           0x0000000184db1be0 -[UIApplication sendEvent:] + 788
    44  UIKit                               0x00000001b6705f9c -[UIApplicationAccessibility sendEvent:] + 96
    45  UIKitCore                           0x0000000184e3e078 __dispatchPreprocessedEventFromEventQueue + 7576
    46  UIKitCore                           0x0000000184e4010c __processEventQueue + 6792
    47  UIKitCore                           0x0000000184e380ec __eventFetcherSourceCallback + 184
    48  CoreFoundation                      0x00000001803502c0 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 24
    49  CoreFoundation                      0x00000001803501c8 __CFRunLoopDoSource0 + 200
    50  CoreFoundation                      0x000000018034f554 __CFRunLoopDoSources0 + 256
    51  CoreFoundation                      0x0000000180349b9c __CFRunLoopRun + 744
    52  CoreFoundation                      0x00000001803493a8 CFRunLoopRunSpecific + 572
    53  GraphicsServices                    0x000000018c03c5ec GSEventRunModal + 160
    54  UIKitCore                           0x0000000184d937ac -[UIApplication _run] + 992
    55  UIKitCore                           0x0000000184d982e8 UIApplicationMain + 112
    56  libswiftUIKit.dylib                 0x00000001b64f6f9c $s5UIKit17UIApplicationMainys5Int32VAD_SpySpys4Int8VGGSgSSSgAJtF + 100
    57  Find-New                            0x0000000105021a44 $sSo21UIApplicationDelegateP5UIKitE4mainyyFZ + 104
    58  Find-New                            0x00000001050219cc $s8Find_New11AppDelegateC5$mainyyFZ + 44
    59  Find-New                            0x0000000105021ac4 main + 28
    60  dyld                                0x00000001099d9ca0 start_sim + 20
    61  ???                                 0x0000000000000001 0x0 + 1
)
libc++abi: terminating with uncaught exception of type NSException
dyld4 config: DYLD_ROOT_PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot DYLD_LIBRARY_PATH=/Users/aheze/Library/Developer/Xcode/DerivedData/Find-cgxoislhsfjnddaeuqparoqndoef/Build/Products/Debug-iphonesimulator:/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/system/introspection DYLD_INSERT_LIBRARIES=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/libBacktraceRecording.dylib:/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/libMainThreadChecker.dylib:/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/Developer/Library/PrivateFrameworks/DTDDISupport.framework/libViewDebuggerSupport.dylib DYLD_FRAMEWORK_PATH=/Users/aheze/Library/Developer/Xcode/DerivedData/Find-cgxoislhsfjnddaeuqparoqndoef/Build/Products/Debug-iphonesimulator:/Users/aheze/Library/Developer/Xcode/DerivedData/Find-cgxoislhsfjnddaeuqparoqndoef/Build/Products/Debug-iphonesimulator/PackageFrameworks
*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'request for index path for global index 9223372036854775807 when there are only 48 items in the collection view'
terminating with uncaught exception of type NSException
CoreSimulator 783.5 - Device: iPhone 13 Pro Max (F1EC12A7-4B5F-4462-AC9C-ED54E50CD0C2) - Runtime: iOS 15.2 (19C51) - DeviceType: iPhone 13 Pro Max

```


In `PhotosSlidesVC+Listen`, make sure to check `percentageShowing`.
```swift
/// if showing, that means Find is currently scanning, so don't scan a second time.
if !self.searchNavigationProgressViewModel.percentageShowing {
    self.startFinding(for: findPhoto)
}
```

Otherwise, if typing fast, this error might show up:

```
SWIFT TASK CONTINUATION MISUSE: find(in:visionOptions:findOptions:) leaked its continuation!
2022-03-16 20:47:57.193100-0700 Find-New[19880:285440] SWIFT TASK CONTINUATION MISUSE: find(in:visionOptions:findOptions:) leaked its continuation!
_Concurrency/CheckedContinuation.swift:164: Fatal error: SWIFT TASK CONTINUATION MISUSE: find(in:visionOptions:findOptions:) tried to resume its continuation more than once, returning <VNRecognizeTextRequest: 0x6000012798f0> VNRecognizeTextRequestRevision2 ROI=[0, 0, 1, 1]!

2022-03-16 20:47:57.591709-0700 Find-New[19880:285440] _Concurrency/CheckedContinuation.swift:164: Fatal error: SWIFT TASK CONTINUATION MISUSE: find(in:visionOptions:findOptions:) tried to resume its continuation more than once, returning <VNRecognizeTextRequest: 0x6000012798f0> VNRecognizeTextRequestRevision2 ROI=[0, 0, 1, 1]!
```
