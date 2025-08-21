# IAP Badger 2 Sample Project

This is a sample app to show [IAP Badger 2](https://github.com/prairiewest/iap_badger2) in action.

You may also need [verifyreceipt](https://github.com/prairiewest/verifyreceipt) depending on the types of purchase products and the target store. You must run verifyreceipt version 4.4 only, no higher (the author removed support for Google Play above version 4.4).

This sample project will only run properly on a device if you create a new app in the appropriate app store and then deploy a test version.

* In Apple App Store this means using Testflight to deploy the app to your device.
* In Google Play Store this means creating an Internal Testing track to deploy to your device.
* In Amazon App Store this means using Live App Testing.

You must also set up your IAP products and subscriptions in the app store.

**Deploying this code directly to a device over USB will not work.**

Also please note:

* You will need to update the values in `globalData.lua`, `libraries/runtime.lua` and `config.lua`
* For Google Play please read https://prairiewest.net/2025/03/verifying-iap-subscription-receipts-for-google-play/
* For Amazon, you will need to place a copy of `AppstoreAuthenticationKey.pem` in the top level (ie: at the same level as `build.settings`)
