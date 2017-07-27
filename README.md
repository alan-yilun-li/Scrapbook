# Scrapbook

<<<<<<< HEAD
-------
=======
Note: Please see ReadMe for my default branch, "CurrentDeployedVersion", for more information. <br /> 

NSKeyedArchiver was a bit too slow when my array of saved pictures, captions, and titles got too large. To solve this initially I began implementing a loading indicator to let users know "Hey, the app hasn't crashed! It's just slow!" However, I realized that what would be better is if saving wasn't slow in the first place. 
>>>>>>> switchingToCoreData

Hence, this branch is for migrating the data persistence method from NSKeyedArchiver to Core Data.
