import Foundation

public enum PagingMenuHorizontalAlignment {
  case left
  
  // Allows all paging items to be centered within the paging menu
  // when PagingMenuItemSize is .fixed and the sum of the widths
  // of all the paging items are less than the paging menu
  case center
}
