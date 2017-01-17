# Scrapbook

Scrapbook is a "virtual scrapbook" application for iOS, made for my girlfriend (and others)
who don't have the time or effort to print, cut-out, glue, and organize pictures and captions together 
in an actual scrapbook. 

It features a “table of contents” as its central view, in which entries comprising of photos, their titles, 
and their captions are packaged in a separate rows, starting with the most recent additions at the top. 
In addition, each caption has been embedded in a scroll-view inside its enclosing table-cell
to make each entry fully readable from the “table of contents” view.

New entries can be saved and old entries viewed more closely or modified via another view,
fully connected using navigation interfaces and segues. 
Scrapbook was made using Swift 3.0 and Xcode 8.0 and heavily used Apple’s Cocoa Touch Framework 
— more specifically the UIKit Framework.

-------

This being my first major Swift project, and being self-taught in the language, 
I should acknowledge Apple’s “Start Developing iOS Apps” Swift 2.0 tutorial (linked below) for much assistance 
and inspiration. [Many many stack-exchange pages and other tutorials were also consulted but none so heavily used.]

Deviations from the tutorial project start with having replaced the RatingControl object with a UITextView
for the caption. Additional changes that this required were implementing fluid scrolling based on keyboard notifications,
as the keyboard would cover the caption (UITextView) during input otherwise. This involved wrapping views in many
scrollviews and enabling and disabling scrolling programmatically given multiple cases of use. 

Other changes were also made, such as changing the position in the array of entries in which entries were added
reverse the order of the array (to correct the chronology), correcting the availability of the save button to make entries
unsaveable when no picture has been chosen, to make entries immediately saveable when editing, and etcetera. 

Start Developing iOS Apps: https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/

-------

I am currently working on adding a PageViewController and the required navigation to display entries in 
a PageView when pressed on, so that entries can be flipped through chronologically like an actual book. I came upon 
this idea when reading the Apple recommendations on intuitive UI design (which I completely agree with). 

That being said, I am currently troubleshooting difficulties with generating an array of ViewControllers based on my current array of 
entries that I am using for my TableViewController. I hope to make more progress on it soon!

Other ideas for expanding upon Scrapbook's functionality in the future include adding a song for each entry, so
that users can have a "soundtrack" for their life. [I haven't looked into this too much but I would probably use Apple's API,
such as the MediaPlayer framework or Apple Music API.]
