local json = require 'json'

local GD = {
  freeTrialGames = 10,
  gamesPlayed = 0,
  languagesetfromos = false;
  language = "en",
  permanentUnlock = false,
  soundOn = true,
  subscriptionActive = false,
  subscriptionEndDate = 0,
  subscriptionGrace = false,
}

GD.storeProductPurchased = function(product, transaction)
  print("[GD] Product purchased: " .. product)
  if product == "unlock" then
    GD.permanentUnlock = true
  end
  if product == "subMonthly" then
    local currentTime = os.time()
    print("[GD] Sub end date: " .. transaction.subscriptionEndDate)
    print("[GD] Current date: " .. currentTime)
    if transaction.subscriptionEndDate >= currentTime then
      GD.subscriptionActive = true
      GD.subscriptionEndDate = transaction.subscriptionEndDate
    else
      GD.subscriptionActive = false
    end
  end
  GD:saveSettings()
  if _G.storeCallback ~= nil then
    _G.storeCallback(product, "purchase")
  end
end

GD.storeProductRefunded = function(product, transaction)
  print("[GD] Product refunded: " .. product)
  if product == "unlock" then
    GD.permanentUnlock = false
  end
  if product == "subMonthly" then
    GD.subscriptionEndDate = 0  -- prevent the code in Menu doing a restore
    GD.subscriptionActive = false
    GD.subscriptionGrace = false
  end
  GD:saveSettings()
  if _G.storeCallback ~= nil then
    _G.storeCallback(product, "refund")
  end
end

GD.IAP = {
  --Information about the product on the app stores
  products = {
    unlock = {
      productNames = {
        apple="com.example.iapbadger2.unlock",
        google="com.example.iapbadger2.unlock",
        amazon="com.example.iapbadger2.unlock"
      },
      productType = "non-consumable",
      onPurchase=GD.storeProductPurchased,
      onRefund=GD.storeProductRefunded
    },
    subMonthly = {
      productNames = {
        apple="com.example.iapbadger2.submonthly",
        google="com.example.iapbadger2.submonthly",
        amazon="com.example.iapbadger2.sub.monthly"
      },
      productType = "non-consumable",
      isSubscription = true,
      onPurchase=GD.storeProductPurchased,
      onRefund=GD.storeProductRefunded
    }
  }
}

local settingsFile = system.pathForFile('settings.json', system.DocumentsDirectory)

function GD:loadSettings()
  print("[GD] Loaded settings")
  local file, msg = io.open(settingsFile, 'r')
  if file then
    local contents = file:read('*a')
    io.close(file)
    local settings = json.decode(contents)
    if settings.soundOn ~= nil then
      self.soundOn = settings.soundOn
    end
    if settings.languagesetfromos ~= nil then
      self.languagesetfromos = settings.languagesetfromos
    end
    if settings.language ~= nil then
      self.language = settings.language
    end
    if settings.permanentUnlock ~= nil then
      self.permanentUnlock = settings.permanentUnlock
    end
    if settings.subscriptionActive ~= nil then
      self.subscriptionActive = settings.subscriptionActive
    end
    if settings.subscriptionEndDate ~= nil then
      self.subscriptionEndDate = settings.subscriptionEndDate
    end
    if settings.gamesPlayed ~= nil then
      self.gamesPlayed = settings.gamesPlayed
    end
  end
end

function GD:saveSettings()
  local settings = {
    gamesPlayed = self.gamesPlayed,
    languagesetfromos = self.languagesetfromos,
    language = self.language,
    permanentUnlock = self.permanentUnlock,
    soundOn = self.soundOn,
    subscriptionActive = self.subscriptionActive,
    subscriptionEndDate = self.subscriptionEndDate
  }
  local file, msg = io.open(settingsFile, 'w')
  if file then
    file:write(json.encode(settings, {indent=true}))
    io.close(file)
  end
  print("[GD] Saved settings")
end

return GD
