# 💬 WhatsApp TXT chats viewer
 A cross-platform desktop Flutter app to easily view old `.txt`-backed up chats from WhatsApp, in a familiar WhatsApp UI.
 
 ## Why?
 A couple years ago, I switched from an Android phone to an iPhone. Although it is now possible to [transfer chats from Android to iPhone](https://faq.whatsapp.com/686469079565350), it was not possible back then. Since it is still impossible to merge backed up chats from an old Andorid backup to my new iPhone backup, I needed a way to view my old chats, which, thankfully, I had exported to `.txt` files via WhatsApp right before I switched. This is where this little app comes in!
 
 ## Usage and features
 Simply drag and drop your `.txt` files and type your name, as it appears on the files, on the top right text field, then press the lock icon.
 All the parsing of the (very messy) WhatsApp generated file is done by the app. You will also be able to search messages and by clicking the result, you will automatically scroll to the message. 
 
 ## Other features to make the app look good 😃
 1. Automatically detects if the chat is a group or single chat and assign the icon accordingly
 2. In a group chat, all the names have different colors, just like on WhatsApp
 3. The app takes care of Alert messages (such as encryption, group and number changes) all automatically
 
 ## Screenshots
 Drag and drop screen:
![SCR-20230321-whd](https://user-images.githubusercontent.com/44927443/226762637-a66c20c3-75d2-4fc2-8851-2c0a02e342b5.png)

Main screen, with chats and search field:
![SCR-20230321-whv](https://user-images.githubusercontent.com/44927443/226763592-6a526ffc-f1e4-482e-b6fd-692d55b6dba7.png)

Search function at work:
![SCR-20230321-wim](https://user-images.githubusercontent.com/44927443/226763671-141ac5ac-fe75-43d7-9290-232e7035c182.png)

## What's next?
I would like to add a few features, as soon as I have some time to work on this project a bit more. The main ones are:
1. Highlighting of the searched message once the chat is opened
2. Possibility to save the chats so they don't have to be imported each time the app is opened
3. Add a searchbar within each chat to search messages in a single chat
