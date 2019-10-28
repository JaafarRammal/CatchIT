# CatchIT

## What CatchIT is

CatchIT is a fusion between Snapchat and Pokemon Go, with the purpose of saving the environment. This project won first place in the 2019 Google GBN Hackathon in London.

Users earn points by picking litter up off the ground and taking a quick photo of them holding the piece of trash before binning it. Computer vision machine learning models are used to identify what the object is (Metal can, wrapping plastic, etc) and award points based on the classification.

These points can then be redeemed for vouchers offered by small local businesses. This way, people are motivated to clean streets up and growing businesses get the oppertunity to promote themselves.

>Watch the attatched `Demo.mov` for an overview of the app's capabilities.


## Running CatchIT

This is an iOS app, so you would need Xcode to deploy it onto your smartphone.

To activate objects recognition API, please include a google services plist file with a Firebase (personal key not inlcuded in the project of course). Use `com.pineapple.CatchIT` as the company reference in the firebase console.