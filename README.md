# IAP Badger 2 Sample Project

This sample project will only run properly on a device if you create a new app in the appropriate app store and then deploy a test version.

* In Apple App Store this means using Testflight to deploy the app to your device.
* In Google Play Store this means creating an Internal Test track to deploy to your device.
* In Amazon App Store this means using Live App Testing.

You must also set up your IAP and subscriptions in the app store.

**Deploying this code directly to a device over USB will not work.**

Also please note:

* You will need to update the values in 
* For Amazon, you will need to place a copy of `AppstoreAuthenticationKey.pem` in the top level (ie: at the same level as `build.settings`)
