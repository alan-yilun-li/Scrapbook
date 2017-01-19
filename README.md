# Scrapbook

Scrapbook is a "virtual scrapbook" application for iOS, made for my girlfriend (and others)
who don't have the time or effort to print, cut-out, glue, and organize pictures and captions together 
in an actual scrapbook. 

With Scrapbook, users can submit page-entries comprising of photos, their titles, 
and their captions. These are fully navigable via a UIPageViewController, though there is also a “table of contents” as its central view, in which entries are documented reverse-chronologicaly and can be readily accessed without needing to do any page flipping. In addition, each caption has been embedded in a scroll-view inside its enclosing table-cell
to make each entry fully readable from the “table of contents” view.

Scrapbook was made using Swift 3.0 and Xcode 8.0 and heavily used Apple’s Cocoa Touch Framework 
— more specifically the UIKit Framework.

-------

This being my first major Swift project, and being self-taught in the language, 
I should acknowledge Apple’s “Start Developing iOS Apps” Swift 2.0 tutorial (linked below) for much assistance 
and inspiration. [Many many stack-exchange pages and other tutorials were also consulted but none so heavily used.]

To document it a little, some deviations from the tutorial include quality of life fixes including: making the photo displays
compatible with non-square photos, scrolling UITextViews / UITextFields based on keyboard visibility (and 
scrolling the frame back when input is copmlete), implementing embedded UIScrollViews into the table cells, changing the 
order in which entries were added to the UITableView (reversing the array) and ensuring making sure saving and scrolling was enabled or disabled given certain input cases, etc. 

Major changes involved and revolve around having implemented a UIPageViewController in which all entries are displayed in, can be navigated to and edited from (with saving, of course), and working with a UITextView for the caption instead of a rating object.

Start Developing iOS Apps: https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/

-------
Next Steps:

Other ideas for expanding upon Scrapbook's functionality in the future include adding a song for each entry, so
that users can have a "soundtrack" for their life. [I haven't looked into this too much but I would probably use Apple's API,
such as the MediaPlayer framework or Apple Music API.]


Accomplished as of January 19th, 2017: 
(though some bugfixing still has to happen)

~~I am currently working on adding a PageViewController and the required navigation to display entries in 
a PageView when pressed on, so that entries can be flipped through chronologically like an actual book. I came upon 
this idea when reading the Apple recommendations on intuitive UI design (which I completely agree with).

That being said, I am currently troubleshooting difficulties with generating an array of ViewControllers based on my current array of entries that I am using for my TableViewController. I hope to make more progress on it soon!~~
