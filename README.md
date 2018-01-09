# Scrapbook

-------

Scrapbooks is a secure photo-journal app -- all your intimate photos and captions, your daily ramblings, are saved on your device and your device only. 

## Support

Please email me at alan.yilun.li@gmail.com for any concerns regarding the app. 

## Dev Notes (Jan 8th, 2018) 

Version 1.0 has been up on the App Store for three months now. Looking back on 2017, the times working on this app were definitely really fun; two of my favourite features to implement being: 

##### Migrated Over to Core Data and Using the File-System instead of Blobs
After learning some more tips and tricks at my internship over the summer I finally braved through and switched from the entirely unsuitable NSKeyedArchiver data-persistence model to Core Data for saving moment entries. Many tutorials were read and an unfortunate (read: > 1) number of git resets were made, but it's all set up now and I learned a lot along the way. 

Using the filesystem to save photos and learning about different kinds of storage was also incredibly rewarding. 

##### Local Authentication / Touch ID 
This one was probably one of the flashiest Apple features I've added to my apps before. It was a lot of writing UIAlertControllers and callbacks -- nothing too complicated, especially as the setup was very well documented. Most thought was actually in making the locking / unlock mechanism look smooth and blurring the images properly, even after the user rearranges / deletes scrapbooks.

### Further Features 
That being said, there are several key features I still want to implement before publicizing more. 

##### Onboarding 
The foremost problem in terms of getting more users is the onboarding process. While the app is nice, pretty, and useful when the user has consistently been using it, it's quite literally empty when first downloaded. 

Adding an onboarding process where users can do a mass-import of photos may be helpful to making the app have more staying power and lessen the friction of adding multiple photos one-by-one. An onboarding process could also include a tutorial for showing users where hard to find features are accessed (though ideally all features should be easy and clear to find). 

##### UI Changes 
I realized the date may be in an inconvenient location (firstly you have to scroll down to access it). Furthermore, with the addition of the iPhone X and how the bottom bar is of more importance, using swipe gestures to change the date near the bottom could be inconvenient.  

##### Reminders
Since ultimately this app is meant to be a photo-diary I would like to add a feature that sends push-notifications at regular time intervals that the user sets (once a day, once a week, etc.) to prompt the user to add an entry. 

With school I'm not sure how quickly I'll be able to set up a server and get push-notifications going, but it is definitely planned. When the server is up it'll also pave way for being able to save things on the cloud as well if there is a desire for that later. 
