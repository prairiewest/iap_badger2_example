local M = {}

M.settings = {}
M.settings["currentscene"] = ""
M.settings["games_this_session"] = 0;
M.settings["language"] = "en"
M.sceneCallback = nil

M.settings["debug"] = false
M.subscriptionGraceSeconds = 86400 -- 1 day, in case someone loses their subcription without network to resub

M.APP_PACKAGE = "com.example.iapbadger2"
M.APP_API_KEY = "REPLACEME"
M.API_BASE = "https://api.example.com"
M.API_RECEIPT_VERIFY = M.API_BASE .. "/verifyreceipt/"

M.log = function(msg)
    if M.settings["debug"] then
        print(msg)
    end
end

local model = system.getInfo("model")
M.log("Model: " .. model)
M.log("Target app store: " .. system.getInfo("targetAppStore"))

M.onDevice = true
M.settings["privacypolicy"] = "https://example.com/privacy/"
M.settings["termsofuse"] = nil

if system.getInfo("environment") == "simulator" then
    M.settings["platform"] = "simulator"
    M.settings["showstore"] = true
    M.settings["showotherapps"] = true
    M.settings["showratebutton"] = false
    M.settings["otherappsurl"] = "http://www.example.com/applications.php"
    M.settings["admob"] = {}
    M.settings["termsofuse"] = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    M.onDevice = false

else
    if string.sub(model,1,2) == "iP" or system.getInfo("targetAppStore") == "apple" or system.getInfo("platform") == "ios" then
        -- iPhone, iPod or iPad
        M.settings["platform"] = "apple"
        M.settings["showstore"] = true
        M.settings["showotherapps"] = true
        M.settings["showratebutton"] = true
        M.settings["otherappsurl"] = "https://itunes.apple.com/"
        M.settings["iOSAppId"] = "REPLACEME"
        M.settings["managesubsurl"] = "https://apps.apple.com/account/subscriptions"
        M.settings["termsofuse"] = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

    elseif system.getInfo("targetAppStore") ~= "amazon" and (system.getInfo("platform") == "android" or system.getInfo("targetAppStore") == "google") then
        -- Android
        M.settings["platform"] = "android"
        M.settings["showstore"] = true
        M.settings["showotherapps"] = true
        M.settings["showratebutton"] = true
        M.settings["otherappsurl"] = "https://play.google.com/store/apps/developer?id=com.example"
        M.settings["managesubsurl"] = "https://play.google.com/store/account/subscriptions"

    elseif model == "WFJWI" or string.sub(model,1,2) == "KF" or string.sub(model,1,6) == "Kindle" or system.getInfo("targetAppStore") == "amazon" then
        -- Amazon
        M.settings["platform"] = "amazon"
        M.settings["showstore"] = false
        M.settings["showotherapps"] = true
        M.settings["showratebutton"] = true
        M.settings["otherappsurl"] = "amzn://apps/android?p=com.example.iapbadger2&showAll=1"
        M.settings["managesubsurl"] = "amzn://apps/library/subscriptions"
        M.settings["admob"] = nil

    else
        M.settings["platform"] = "unknown"
        M.settings["showstore"] = false
        M.settings["showotherapps"] = true
        M.settings["showratebutton"] = false
        M.settings["otherappsurl"] = "https://www.example.com/"
        M.settings["admob"] = nil
        
    end
end

M.topInset, M.leftInset, M.bottomInset, M.rightInset = display.getSafeAreaInsets()
if M.leftInset == 0 then
  M.leftInset = 5
end
if M.rightInset == 0 then
  M.rightInset = 5
end


M.FONTS = {
  TEXT = "fonts/Galindo-Regular.ttf"
}

M.COLORS = {
  shadow = {0.3, 0.3, 0.3},
  Black = {0, 0, 0},
  Clear = {1, 1, 1, 0.01},
  DarkGray = {0.15, 0.15, 0.15},
  DarkRed = {0.6, 0, 0},
  Gray = {0.5, 0.5, 0.5},
  RedOrange = {1, 0.3, 0.2},
  Silver = {0.75, 0.75, 0.75},
  White = {1, 1, 1}
}

M.SOUNDS = {
  select = audio.loadSound('sounds/select.mp3')
}

return M