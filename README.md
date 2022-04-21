# AutoLayoutConvenience
Convenience Helpers for AutoLayout

## Introduction
This is a helper library that has helper functions for common AutoLayout operations and makes working with AutoLayout a bit more expressive. Instead of creating multiple constraints, you "simply" call one of the helper functions:

### Before:
	subview.translatesAutoresizingMaskIntoConstraints = false
	view.addSubview(subview)
	NSLayoutConstraint.activate([
		view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: subview.topAnchor, constant: -8),
		view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: -8),
		view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: subview.bottomAchor, constant: -8),
		view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -8),
	])

### After:
	view.addSubview(subview, filling: .safeArea, insets: .all(8))


## What is it?

There are 7 major AutoLayout operations:

- **filling**, you make a view fill another view and optionally inset it
- **centering**, you can make a view center in another view with an optional offset
- **pinning to a position**, you can make a view pin to a position in another view, with an optional offset
- **pinning to an edge** you can make a view pin to an edge of another view, and defining how the opposite axis should be constrained
- **aligning to an edge** you can make a view align to the edge of another view, making sure it's as big as possible, but it will never exceeds the other views edges.
- **constraining** you can constrain the **width**, **height** and **aspect ratio** of a view
- **(dis)allowing shrinking/growing**, you can determine which views can shrink/grow

And there are helpers for `UIStackView`:

- creating horizontal/vertical **stacks** with **spacing** and **insets**
- **aligning** a view horizontally / vertically by wrapping it in a stack view
- **insetting** a view by wrapping it in a stack view with insets

And `UIScrollView` helpers that make content overflow **only when needed**:

- Making a view vertically/horizontaly scrollable ,but only when needed

## Example

Given the following views:
```
let titleLabel = UILabel(text: "Title Label", textStyle: .largeTitle, alignment: .center)
let subLabel = UILabel(text: String(repeating: "Sub label with a lot of text. ", count: 10), textStyle: .body, alignment: .center)
let closeButton = UIButton(type: .close)
let backgroundView = UIView(backgroundColor: .systemGroupedBackground)
let actionButton = UIButton.platter(title: "Add More Text", titleColor: .white)
let cancelButton = UIButton.platter(title: "Revert", backgroundColor: .white)
let buttonSize = CGSize(width: 32, height: 32)
```

The following 6 lines create a view where the `titleLabel` and `subLabel`  are centered in the remaining space of
the backgroundView and follow the readable content guide;  the buttons are attached to the bottom either vertically 
or horizontally depending on vertical the size class of the device; the close button is in the top-left corner 
of the backgroundView.
The labels will automatically become scrollable when they need to.
```
let content = UIView.verticallyStacked(
	UIView.verticallyStacked(titleLabel, subLabel, spacing: 4).verticallyCentered().verticallyScrollable(),
	UIView.autoAdjustingVerticallyStacked(actionButton, cancelButton, spacing: 8)
)

backgroundView.addSubview(content, filling: .readableContent)
addSubview(backgroundView, filling: .safeArea, insets: .all(32))
backgroundView.addSubview(closeButton.constrain(size: buttonSize), pinning: .center, to: .topLeading)

```

![Layout](https://user-images.githubusercontent.com/168214/116421501-2f020680-a83f-11eb-9c8e-2b6af8f5c6a7.png)
![Buttons Automatically Adjust](https://user-images.githubusercontent.com/168214/116421494-2e697000-a83f-11eb-91e9-00487df4186c.png)
![Automatically scrollable](https://user-images.githubusercontent.com/168214/116421505-2f9a9d00-a83f-11eb-93be-660689a63e1e.png)


## Usage

### Basics

The basics of this library are so called `anchorable layouts`, which define which anchors and layout guides to use. The following anchorables and layouts are available:

- `none`:  doesn't perform layout
- `default` uses the default layout (more on that later)
- `superview` anchors to the superview of the relevant view
- `relative(UIView)` anchors to a specific `UIView`
- `guide(UILayoutGuide)` anchors to a specific `UILayoutGuide`
- `safeArea` anchors to the `safeAreaLayoutGuide` of the relevant view
- `safeAreaOf(UIView)` anchors to the `safeAreaLayoutGuide` of a specific view
- `layoutMargins` anchors to the `layoutMarginsGuide` of the the relevant view
- `layoutMarginsOf(UIView)` anchors to the `layoutMarginsGuide` of a specific
- `readableContent` anchors to the `readableContentGuide` of the the relevant view
- `readableContentOf(UIView)` anchors to the `readableContentGuide` of a specific
- `scrollContent` anchors to the `contentLayoutGuide` of the relevant view if that is a `UIScrollView`, otherwise just to the view itself
- `scrollContentOf(UIView)` anchors to the `contentLayoutGuide` of a specific `UIScrollView`
- `scrollFrame` anchors to the `frameLayoutGuide` of the relevant view if that is a `UIScrollView`, otherwise just to the view itself
- `scrollFrameOf(UIView)` anchors to the `frameLayoutGuide` of a specific `UIScrollView`
- `keyboardSafeArea` anchors to the `keyboardSafeAreaLayoutGuide` of the relevant view
- `keyboardSafeAreaOf(UIView)` anchors to the `keyboardSafeAreaLayoutGuide` of a specific view
- `keyboardFrame` anchors to the `keyboardFrameLayoutGuide` of the relevant view
- `keyboardFrameOf(UIView)` anchors to the `keyboardFrameLayoutGuide` of a specific view

As you can see, there are anchorables that take a specific `UIView` and ones that don't. The ones that don't always apply to the relevant view, which usually is the subview that is being added.


There are also anchors to deal with the keyboard:

- `keyboardSafeArea[Of]` which is the safeArea minus the keyboard. In short, it's the area uncovered by the keyboard or safe area insets
- `keyboardFrame[Of]` which is the frame of the keyboard. If the keyboard is hidden, its height is 0.

Those anchors are implemented using custom `UILayoutGuide` subclasses, which respond to keyboard events. They work best with static views, since they do not track the view changing position.

### Insets

Most helper functions in the library take insets. There are convenience helpers defined on `NSDirectionalEdgeInsets` that make them a bit more semantic and shorter:

- `.all(value)` all edges are set to value
- `.top(value)` top inset only, others 0
- `.leading(value)` leading inset only, others 0
- `.trailing(value)` trailing inset only, others 0
- `.bottom(value)` bottom inset only, others 0
- `.vertical(value)` top and bottom inset only, others 0 
- `.horizontal(value)` leading and trailing inset only, others 0
- `.insets(horizontal: value, vertical: otherValue)` top and bottom to value, leading and trailing to otherValue

- `with(top:)`, `with(leading:)`, `with(bottom:)`, `with(trailing:)` changes the specified edge of some existing insets
- `with(horizontal:)`, `with(vertical:)` changes the specified edges of some existing insets
- `.with(insets1, insets2, insets3)` adds all insets together
- `adding(NSDirectionalEdgeInsets)` adds other insets to the given insets
- `multiply(value)` multiplies all edges with the given value
- `horizontallySwapped` swaps the insets of the horizontal edges
- `verticallySwapped` swaps the insets of the veetical edges
 

### Filling

![Example of Filling](https://user-images.githubusercontent.com/168214/164456459-854d667d-1711-4d33-b2d9-3ce1f912b3af.png)


Filling is done by specifying the 4 edges to constrain to (`BoxLayout`), with optionally insetting:

	// Fills the insetted by 8pts safeArea of its superview
	addSubview(subview, filling: .safeArea, insets: .all(8))
	
	// Fills the layoutMargins of another view that is in the same hierarchy
	addSubview(subview, filling: .layoutMargins(anotherView))
	
	// Fills the superview horizontally, safeArea vertically
	addSubview(subview, filling: .horizontally(.superview, vertically: .safeArea))
	
	// Fills the superview horizontally, and attached to the safeArea on top, the superview on the bottom
	addSubview(subview, filling: .horizontally(.superview, vertically: .top(.safeArea, .bottom: .superview)))
	
	// Fills the view by constraining to the specified edges
	addSubview(subview, filling: .top(.safeArea, leading: .safeArea, bottom: .layoutMargins, trailing: .readableContent))


### Centering

![Example of Centering](https://user-images.githubusercontent.com/168214/164456670-91c9b2b8-b07b-40e3-90eb-6efc33cea1f5.png)

Centering is done by specifying the x,y position (`PointLayout`) to center in, with optionally offsetting:

	// Centers the subview in the layoutMargins of its superview, ofsetted by 4pt horizontally
	addSubview(subview, centeredIn: .layoutMargins, offset: CGPoint(x: 4, y: 0))
	
	// Centers the subview horizontally in its superview, vertically in the safeArea of another view
	addSubview(subview, centeredIn: .x(.superview, y: .safeAreaOf(anotherView)))


### Pinning Positions

![Example of Pinning To Positions](https://user-images.githubusercontent.com/168214/164456835-dc52467c-f2fd-4902-9c28-717c85b2aa83.png)
![Example of Pinning Positions](https://user-images.githubusercontent.com/168214/164456980-b3e37e38-2676-4b9d-bc9a-ba42534ff911.png)

Pinning is done by specifying what to position to pin to:

- topLeading
- topCenter
- topTrailing
- leadingCenter
- center
- trailingCenter
- bottomLeading
- bottomCenter
- bottomTrailing

Relative to a x,y position (`PointLayout`).  `pinnedTo:` pins the same position in both views, `pinning:to:` pins two different positions.

	//  Pins the top center of subview to the top center of its superview, offsetted by 4pts horizontally
	addSubview(subview, pinnedTo: .topCenter, of: .superview, offset: CGPoint(x: 4, 0))
	
	// Pins bottom leading point of subview to the bottom leading point of another view
	addSubview(subview, pinnedTo: .bottomLeading, of: .relative(anotherView))
	
	// Pins the center of subview to the top leading of its superview
	adSubview(subview, pinning: .center, to: .topLeading, of: .superview)

### Pinning to Constant Rects / Points

![Example of Pinning To Rects and Points](https://user-images.githubusercontent.com/168214/164457088-876f20d6-0419-4e0f-9f44-c6971f818dca.png)

You can also pin a view to a constant rect or point, using:


	/// pins the subview to the given rect
	addSubview(subview, pinnedAt: CGRect(x: 10, y: 20, width: 100, height: 40))
	
	/// pins the subview to the given rect in another view
	addSubview(subview, pinnedAt: CGRect(x: 10, y: 20, width: 100, height: 40), in: .relative(anotherView)
	
	/// pins the subview to the given point - the view needs to have a defined width & height or an intrinsic size
	addSubview(subview, pinnedAt: CGPoint(x: 20, y: 10))
	
	/// pins the subview to the given point in the safeArea - the view needs to have a defined width & height or an intrinsic size
	addSubview(subview, pinnedAt: CGPoint(x: 20, y: 10), in: .safeArea)
	 

### Pinning Edges

Pinning edges is separated into **horizontal** and **vertical** variants, that pretty much mirror each other.

Horizontally, we can pin:

 - top
 - centerY
 - bottom
 
 ![Example of Pinning Horizontal Edges](https://user-images.githubusercontent.com/168214/164457428-34e8902c-aee5-4e95-9285-08097a73beb6.png)

Vertically, we can pin:

 - leading
 - centerX
 - trailing
 
 ![Example of Pinning Vertical Edges](https://user-images.githubusercontent.com/168214/164457238-2bd65bde-229c-4a8c-b455-cd515b0cf220.png)

Pinning edges is done by specifying the edge (`YAxisLayout` or `XAxisLayout`) and takes an optional **spacing** and 
**insets** parameter.  Furthermore, you can specify how the opposite axis is constrained:

- `.fill` (default), makes the view fill its superview on the opposite edge
- `filling(Other)` makes the view fill another layout, e.g. `filling(.safeArea)`
- `center` makes the view center in its superview
- `centered(in: Other)` makes the view center in another layout, e.g. `filling(.layoutMargins)`
- `centered(in: Other, between: Other)` makes the view center in in another layout, while being constrained to another layout, .e.g `centered(in: .superview, between: .safeArea)`
- `overflow(Other)` makes the view unconstrained: it can overflow its superview if it doesn't fit, .e.g. `.overflow(.center)`
- `attach` makes the view constrained to the view we are pinned to, instead of to its superview
- `attached(Other)` makes the view constrained to another layout in the view we are pinned to, instead of to its superview


![Example of Aligning Edges](https://user-images.githubusercontent.com/168214/164457600-0ff11145-13bc-4f7a-87ce-e58fb705bd0c.png)

Examples:

	// Pins the top edge of subview to the top edge of its superview with 4pts spacing 
	// between them. Horizontally, we center in the superview
	addSubview(pinnedTo: .top, of: .superview, horizontally: .center,spacing: 4)
	
	// Pins the leading edge of subview to the leading edge of its superview's safeArea
	// and insetting the view by 10pts. Vertically, we align to the top of the superview
	addSubview(pinnedTo: .leading, of: .superview, vertically: .top, insets: .all(10))
	
	// Pins subview so that it is below the sibblingView, while horizontally centering
	// to the sibblingView.
	addSubview(subview, pinningBelow: sibblingView, horizontally: .attached(.center))
	
	// Makes subview fill the remaing space below sibblingView
	addSubview(subview, fillingRemainingSpaceBelow: sibblingView)
	
	
There's also a helper to pin a bunch of views to the superview and each other, much like a UIStackView, except without its overhead:

	// this stacks viewA, viewB, viewC and viewD along side the vertical axis,
	// pinning:
	//	- viewA 40pts to the top edge of the superview
	// 	- viewB to viewA
	//	- viewC to viewB 
	//	- and viewD 40pts from the bottom edge of the superview
	//
	// The spacing between the views will be 8pts and on the horizontal axis,
	// the views will be centered
	addSubviewsVertically(viewA, viewB, viewC, viewD, horizontally: .center, insets: .all(40), spacing: 8)
	
	// same, but the views are now pinned to the safeArea instead of the superview and no insets or spacing
	addSubviewsVertically(viewA, viewB, viewC, viewD, in: .safeArea)
	
	// same, but the views are stacked horizontally
	addSubviewsHorizontally(viewA, viewB, viewC, viewD, vertically: .center, insets: .all(40), spacing: 8)

### Aligning Edges

Aligning is like pinning, except that it will make sure that the view respects the boundaries of its superview. If you want to have a view that is as big as it should be, but never exceed the boundaries of its superview, this will do it for you.

When aligning, you specify how both the **vertical** and **horizontal** edges are constrained:


#### Horizontally:

- `.fill` (default), makes the view fill its superview horizontally
- `filling(Other)` makes the view fill another layout, e.g. `filling(.safeArea)`
- `center` makes the view center horizontally in its superview
- `centered(in: Other)` makes the view center in another layout, e.g. `filling(.layoutMargins)`
- `centered(in: Other, between: Other)` makes the view center in in another layout, while being constrained to another layout, .e.g `centered(in: .superview, between: .safeArea)`
- `overflow(Other)` makes the view unconstrained: it can overflow its superview if it doesn't fit, .e.g. `.overflow(.center)`
- `.leading` makes the view align to the leading edge horizontally and taking as much space as needed, but not past the trailing edge
- `.leading` makes the view align to the trailing edge horizontally and taking as much space as needed, but not past the leading edge

#### Vertically:

- `.fill` (default), makes the view fill its superview vertically
- `filling(Other)` makes the view fill another layout, e.g. `filling(.safeArea)`
- `center` makes the view center vertically in its superview
- `centered(in: Other)` makes the view center in another layout, e.g. `filling(.layoutMargins)`
- `centered(in: Other, between: Other)` makes the view center in in another layout, while being constrained to another layout, .e.g `centered(in: .superview, between: .safeArea)`
- `overflow(Other)` makes the view unconstrained: it can overflow its superview if it doesn't fit, .e.g. `.overflow(.center)`
- `.top` makes the view align to the top edge vertically and taking as much space as needed, but not past the bottom edge
- `.bottom` makes the view align to the bottom edge vertically and taking as much space as needed, but not past the top edge

Examples:

	// This makes subview align to the top of its superview.
	// subview will never grow past the bottom edge of its superview,
	// but if its smaller it will not fill until the bottom edge:
	//
	// You can think of this as: bottom edge < superviews.bottom edge  
	//
	// Horizontally, the view will fill its superview
	addSubview(subview, aligningVerticallyTo: .top)
	
	
	// this makes subview align to the horizontal center of its superviews 
	// layoutMargins, while never growing past the layout margins if it needs to be bigger/
	//
	// Vertically, the view will fill its superview
	addSubview(subview, aligningHorizontallyTo: .center(in: .layoutMargins))
	
	//this will make the subview align vertically to its superview and horizontally to the bottom.
	// subview will not extend past the edges of its superview insetted by 10 pts.
	addSubview(subview, aligningVerticallyTo: .center, horizontally: .bottom, insets: .all(10))


### Constraining

 Examples of constraining width/height:
 
	view.constrain(width: 100)
	view.constrain(height: 20)
	view.constrain(width: 100, height: 20)
	view.constrain(size: (CGSize(width: 100, height: 20))
	
	view.constrain(width: .atMost(100)) // not wider than 100
	view.constrain(width: .atLeast(50)) // not smaller than 50
	view.constrain(width: .exactly(100)) // exactly 100 wide
	
	// not bigger than 100x30, but with defaultLow priority
	view.constrain(size: .atMost(CGSize(width: 100, height: 30), priority: .defaultLow))
	
	// the width should be at least 10 and smaller than 20
	view.constrain(widthBetween: 10..<20)
	
	// the height should be at least 10 and at most 20
	view.constrain(heightBetween: 10...20)
	
	/// removing existing width constraints and setting a new width constraint
	view.removeWidthConstraints().constrain(width: 100)
	
	// removing existing height constraints and setting a new height constraint
	view.removeHeightConstraints().constrain(height: 100)
	
	/// removing existing size constraints and setting a new size constraint
	view.removeSizeConstraints().constrain(size: CGSize(width: 100, height: 100))
	
	
### Constraining to other layouts

   Examples of constraining width/height:
	addSubview(otherView, centeredIn: .superview)
	addSubview(view, pinnedTo: .topCenter)
	
	// Note that this must be called after the view has been added to the hierarchy already,
	// since it creates cross-view constraints.
	view.constrain(width: .exactly(.relative(otherView)), height: .atLeast(.safeAreaOf(otherView))
	
	// short hand for constraining to views directly
	view.constrain(width: .exactly(as: otherView), height: .atLeast(halfOf: otherView))
	

Examples of constraining aspect ratio:
	
	// the width will be twice the height
	view.constrainAspectRatio(2.0)
	
	// the width will have the same aspect ratio as the given size
	view.constrainAspectRatio(for: CGSize(width: 200, height: 100))
	
### (Dis)allowing growing / shrinking

There are some chainable helpers for `setContentCompressionResistancePriority()` and  `setContentHuggingPriority()`:

#### Shrinking:
- `allowVerticalShrinking()` sets the vertical compression resistance priority to `.defaultLow`
- `allowHorizontalShrinking()` sets the horizontal compression resistance priority to `.defaultLow`
- `allowShrinking()` sets the compression resistance priority to `.defaultLow`

- `disallowVerticalShrinking()` sets the vertical compression resistance priority to `.required`
- `disallowHorizontalShrinking()` sets the horizontal compression resistance priority to `.required`
- `disallowShrinking()` sets the compression resistance priority to `.required`

#### Growing:
- `allowVerticalGrowing()` sets the vertical hugging priority to `.defaultLow`
- `allowHorizontalGrowing()` sets the horizontal hugging priority to `.defaultLow`
- `allowGrowing()` sets the hugging priority to `.defaultLow`

- `disallowVerticalGrowing()` sets the vertical hugging priority to `.required`
- `disallowHorizontalGrowing()` sets the horizontal hugging priority to `.required`
- `disallowGrowing()` sets the hugging priority to `.required`

#### Shrinking and Growing:
- `prefersExactHorizontalSize()` sets the horizontal compression resistance and hugging priority to `.required`
- `prefersExactVerticalSize()` sets the vertical compression resistance and hugging priority to `.required`
- `prefersExactHorizontalSize()` sets the compression resistance and hugging priority to `.required` on both axis


### UIStackView

There are several helpers for working with (wrapper) UIStackViews:

- `UIStackView` has a convenience initializer that takes views, axis, alignment, distribution, spacing and insets
- `addArrangedSubviews()` to add a bunch of views to a stack view at once
- `reallyRemoveArrangedSubview()` which removes it also from the view

#### Factories:

All these methods take optional `spacing` and `insets` parameters.

#####  Stacking:
 - `verticallyStacked()`  vertically stacks the given views, horizontal `alignment` defaults to `.fill`
 - `horizontallyStacked()` horizontally stacks the given views, vertical `alignment` defaults to `.fill`
- `stacked(views, axis: ...)`  stacks the view along side the specified axis

##### Aligning:
- `horizontally(aligned: )` embeds a view in a horizontally aligned stack view
- `vertically(aligned: )` embeds a view in a vertically aligned stack view
- `aligned(horizontally:vertically)` embeds a view in two stack views, one horizontally aligned, the other vertically aligned

All these functions also have **static** variants, for easy composing.
	
##### Centering:
- `horizontallyCentered()` embeds a view in a horizontally centered stack view
- `verticallyCentered()` embeds a view in a vertically centered stack view
- `centered()` embeds a view in two stack views, both centered in their respective axis

All these functions also have **static** variants, for easy composing.


##### Insetting:
- `insetted(by:)` embeds a view in a stack view with specific insets

This function also has a **static** variant, for easy composing.

#### Auto Adjusting

There are two `UIStackView` subclasses that automatically switches their axis based on the compactness of the opposing axis:
- `AutoAdjustingHorizontalStackView`
- `AutoAdjustingVerticalStackView`

##### Helper factories:
 - `autoAdjustingVerticallyStacked()` vertically stacks the given views, adjusting to horizontal if needed
 - `autoAdjustingHorizontallyStacked()` horizontally stacks the given views, adjusting to vertical if needed

### ScrollView

There are two `UIScrollView` subclasses that participate in AutoLayout and become scrollable when needed:
- `VerticalOverflowScrollView`
- `HorizontalOverflowScrollView`


### Keyboard Avoidance:
`VerticalOverflowScrollView` can avoid the keyboard by setting `isAdjustingForKeyboard = true`.


##### Factories:
- `verticallyScrollable()` embeds the view in a vertical scrollview that becomes scrollable when needed. Pass `avoidsKeyboard: true` to make the scrollview automatically adjust for the keyboard.
- `horizontallyScrollable()` embeds the view in a vertical scrollview that becomes scrollable when needed

These functions both have parameters for the opposing axis and also both have **static** variants, for easy composing.

### FixedFrameLayoutGuide

A helper `UILayoutGuide` that has a fixed frame in its owning view. Useful to combine AutoLayout and manual calculations.

Example:

	let layoutGuide = FixedFrameLayoutGuide()
	view.addLayoutGuide(layoutGuide)
	
	otherView.addSubview(label, pinnedTo: .center, of: .guide(layoutGuide))
	
	layoutGuide.frame = CGRect(x: 100, y: 50, width: 100, height: 30)


### AutoSizingTableHeaderFooterView

UITableView's `tableHeaderView` and `tableFooterView` don't work nicely with AutoLayout: you need to pre-size these views before assigning them, and then keeping track of changes and re-assign the views to update its size in the table view. Another issue is that you need to manually size them when the table view change size, for example on rotation.

There's a helper class you can use to have auto sizing `tableHeaderView`'s and `tableFooterView`s with UITableView. Use `AutoSizingTableHeaderFooterView(view:)` as a header or footer and it will automatically update the view when the intrinsic contentSize changes, with animation (which can be disabled).

There are helpers on UITableView to easily set this as well.

Examples:

	// the tableHeaderView will automatically be updated to the correct size when myAutoLayoutHeaderView
	// changes its size, with animation. 
	tableView.tableHeaderView = AutoSizingTableHeaderFooterView(view: myAutoLayoutHeaderView)
	DispatchQueue.main.asyncAfter(deadline: .now() + 1) { myAutoLayoutHeaderView.somethingThatUpdatesTheContentHeightOfThisView()  }
	
	// this is a shortcut for  tableHeaderView = AutoSizingTableHeaderFooterView(view: view)
	tableView.selfSizingTableHeaderView = myAutoLayoutHeaderView
	
	// you can also disable animations on size updates
	let headerView = AutoSizingTableHeaderFooterView(view: myAutoLayoutHeaderView)
	headerView.automaticallyAnimateChanges = false
	tableView.tableHeaderView = headerView
	
	// And of course, all of these methods have a footer view equivalent:
	tableView.selfSizingTableFooterView = myAutoLayoutFooterView


	// if you have a view that uses manual layout, you can use 
	// `manualLayoutAutoSizingTableHeaderView` to have it size automatically.
	// You need to call the update() method or invalidate the intrinsic content size
	// to update changes.
	let manualLayoutView = MyManualLayoutViewImplementingSizeThatFits()
	tableView.manualLayoutAutoSizingTableHeaderView = manualLayoutView
	DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
		manualLayoutAutoSizingTableHeaderView.somethingThatUpdatesTheContentHeightOfThisView()
		tableView.updateAutoSizingTableHeader()
	}
}
