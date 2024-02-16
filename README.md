# Dynamically Sized Sheets

## Basic Formula
The key to doing this seems to be in a few steps:
1. Setup your basic sheet display logic. - Something like `.sheet(isPresented:content:)` would work fine.
2. Create a modifiable variable to hold the dynamic height of your content. - `@State private var sheetHeight: CGFloat = .zero`
3. Set the presentationDetent with the modifiable height variable. You want to give a default in case it is not calculated yet - `.presentationDetents(sheetHeight == .zero ? [.medium] : .height(sheetHeight)`
4. Calculate the height change - This is, of course, done with the GeometryReader. Most of what I've seen online will calculate the background or overlay height of `Color.clear` on the sheet content and update the `sheetHeight` with the value. The couple of ways I've seen this are with a `.task` or with a `.onPreferenceChange` on the `Color.clear`. [Implementation of `onPreferenceChange`](DynamicallySizedSheets/Helpers/View+HeightChangePreference.swift).
5. Update the `sheetHeight` sheet with whatever was calculated - I did this like `<SheetContent>.heightChangePreference { sheetHeight = $0 }`
6. Thats it! 🎉 

While this will get the basics done, I want to stress test this implementation and see how it interacts with the views that take up all available room like NavigationStacks, GeometryReaders, and ScrollViews.

## Playing with Navigation Stacks
