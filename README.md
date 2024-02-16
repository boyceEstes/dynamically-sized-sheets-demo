# Dynamically Sized Sheets

## Basic Formula
The key to doing this seems to be in a few steps:
1. Setup your basic sheet display logic. - Something like `.sheet(isPresented:content:)` would work fine.
2. Create a modifiable variable to hold the dynamic height of your content. - `@State private var sheetHeight: CGFloat = .zero`
3. Set the presentationDetent with the modifiable height variable. You want to give a default in case it is not calculated yet - `.presentationDetents(sheetHeight == .zero ? [.medium] : .height(sheetHeight)`
4. Calculate the height change - This is, of course, done with the GeometryReader. Most of what I've seen online will calculate the background or overlay height of `Color.clear` on the sheet content and update the `sheetHeight` with the value. The couple of ways I've seen this are with a `.task` or with a `.onPreferenceChange` on the `Color.clear`. [Implementation of `onPreferenceChange`](DynamicallySizedSheets/Helpers/View+HeightChangePreference.swift).
5. Update the `sheetHeight` sheet with whatever was calculated - I did this like `<SheetContent>.heightChangePreference { sheetHeight = $0 }`
6. Thats it! 🎉 

When having some print statements on the `sheetHeight` variable for `willSet` and `didSet` we see something like this:
```
will change sheetHeight to 0.0 to 144.0
changed!
will change sheetHeight to 144.0 to 249.0
changed!
```

While this will get the basics done, I want to stress test this implementation and see how it interacts with the views that take up all available room like NavigationStacks, GeometryReaders, and ScrollViews.


## Playing with Navigation Stacks
Generally, you should be putting your sheets *inside* of your NavigationStacks. And Sometimes, you will want the sheet that you present to be a NavigationStack, as well.

So lets say that we add a NavigationStack to the sheet content that will be presented like:
```
NavigationStack {
    VStack {
        Text("Hello World")
            .messageBackground()
        Text("You're looking good. You come to this solar system often?")
            .messageBackground()
        Text("Thank you for noticing. I've been doing something different with my dirt")
            .messageBackground(isYou: false)
        Text("And no. Here for a little worlds-trip")
            .messageBackground(isYou: false)
    }
    .padding(.horizontal)
    .padding(.vertical)
    .background(Color.yellow)
    .navigationTitle("Hello, World")
    .navigationBarTitleDisplayMode(.inline)
}
.heightChangePreference(completion: { height in
    print("height: \(height)")
    sheetHeight = height
})
```
This will center the sheet content with the `.medium` sheet height being used. Thus losing the treasured dynamic behavior.

![Simulator Screenshot - iPhone 15 Pro - 2024-02-16 at 12 30 07](https://github.com/boyceEstes/dynamically-sized-sheets-demo/assets/7545715/a3367f51-db53-48c7-97a6-c92c71644fe5)

It looks like there is a difficult time getting the initial height of the content when it is in a NavigationStack (in the above snippet). It will see that it is 0.0 which will then set the sheet detent to `.medium` which is where the 419.33 will come from.

```
will change sheetHeight to 0.0 to 0.0
changed!
will change sheetHeight to 0.0 to 419.3333333333333
changed!
```

We could calculate the content inside of the NavigationStack, but that would not include any of the space taken up by `toolbar` items. This might be possible to do with more work.

## Playing with ScrollView & GeometryReader
Something a little more important to this feature is that I want to be able to a dynamic amount of items in the sheet. If there are more items than can fit on the screen it should take up the entire screen and be scrollable.

This works well! The important thing to note is that you want to make the `presentationDetents` modifier **inside** of the `ScrollView`. This is because a vertical scrollview will take up all available height. In order to limit this to taking the entire screen, we are utilizing `.presentationDetents` to limit the height available for the ScrollView to fill to whatever we have calculated for the content.

```
ScrollView {
    ScrollingDynamicSheet(sheetHeight: $sheetHeight)
        .presentationCornerRadius(30)
        .presentationDetents(sheetHeight == .zero ? [.medium] : [.height(sheetHeight)])
}
```

So when we calculate the content like this (little different from the beginning of the README, but you get it, changes happen midexperiment), we will get a perfectly sized _scrollable_ sheet.

```
struct ScrollingDynamicSheet: View {
    
    @Binding var sheetHeight: CGFloat
    
    var body: some View {
        
        SheetContent()
        .heightChangePreference(completion: { height in
            print("height: \(height)")
            sheetHeight = height
        })
    }
}
```

![ScrollableVersion](https://github.com/boyceEstes/dynamically-sized-sheets-demo/assets/7545715/8729263b-b57b-41bc-a5a0-37229a14a307)


### Geometry Reader
This part is short because it is essentially the same principle as the ScrollView. Since the GeometryReader takes up all available space, you want to have it outside of presentationDetents View. This will enable you to fit your GeometryReader to the size of your content rather than the size of your screen. The code looks the same as the ScrollView snippet above just with a GeometryReader instead of ScrollView.

If you want to have both. For example, if you want to make some sort of horizontally scrolling onboarding screen that dynamically shifts size. Then you can wrap the `ScrollView` in a `GeometryReader`.




