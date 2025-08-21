local composer = require('composer')
local scene = composer.newScene()
local globalData = require 'globalData'
local Util = require 'libraries.Util'
local runtime = require 'libraries.runtime'
local T = require"libraries.translator"
local iap = require 'libraries.iap_badger2'

runtime.settings["currentscene"] = "GameStore"

local buttonGroup, sceneGroup, bgGroup, headerGroup, textGroup, backRect
local backButton, button_restore, text_restore, showBuyButtons, showTrialGames, showGameUnlocked
local button_buy1, text_buy1, text_detail1
local button_buy2, text_buy2, text_detail2
local button_privacy, text_privacy, button_terms, text_terms
local button_managesub, text_managesub, legalText
local cancelTimeoutTimer, setTimeoutWithCallback, timeoutTimer, timeoutText, showStoreTimeout, storeUnavailableText
local loadingText, loadingTrans, playedGames, alertListener, gameUnlockedText, privacyPolicyTouched
local iapListenerPurchase, iapListenerRestore, iapListenerOther, buttonTouched, manageSubscriptionTouched
local purchaseInProgress = false
local timeoutDelay = 1000 * 30
local scaling = 1.6

iapListenerPurchase = function(product, eventType)
    -- The product catalog onPurchase listener calls globalData.storeProductPurchased()
    cancelTimeoutTimer()
    composer.removeHidden()
    if button_buy1 ~= nil then
      button_buy1:setFillColor(unpack(runtime.COLORS.White))
    end
    if button_buy2 ~= nil then
      button_buy2:setFillColor(unpack(runtime.COLORS.White))
    end
    purchaseInProgress = false
    native.showAlert("Store", T.find("store_purchase_ok"), {"Ok"}, alertListener)
end

iapListenerRestore = function(product, eventType)
    -- The product catalog onPurchase listener calls globalData.storeProductPurchased()
    cancelTimeoutTimer()
    composer.removeHidden()
    if button_buy1 ~= nil then
      button_buy1:setFillColor(unpack(runtime.COLORS.White))
    end
    if button_buy2 ~= nil then
      button_buy2:setFillColor(unpack(runtime.COLORS.White))
    end
    purchaseInProgress = false
    native.showAlert("Store", T.find("store_restore_ok"), {"Ok"}, alertListener)
end

iapListenerOther = function(product, eventType)
    cancelTimeoutTimer()
    if button_buy1 ~= nil then
      button_buy1:setFillColor(unpack(runtime.COLORS.White))
    end
    if button_buy2 ~= nil then
      button_buy2:setFillColor(unpack(runtime.COLORS.White))
    end
    if button_restore ~= nil then
      button_restore:setFillColor(unpack(runtime.COLORS.White))
    end
    purchaseInProgress = false
end

-- IAP Setup
local iapOptions = {
    catalogue=globalData.IAP,
    package=runtime.APP_PACKAGE,
    debugMode=false,
    verboseDebugOutput=runtime.settings["debug"],
    receiptVerifyURL=runtime.API_RECEIPT_VERIFY,
    failedListener = iapListenerOther,
    cancelledListener = iapListenerOther
}
iap.init(iapOptions)

_G.storeCallback = iapListenerPurchase

manageSubscriptionTouched = function(event)
    system.openURL(runtime.settings["managesubsurl"]) 
end

privacyPolicyTouched = function(event)
    system.openURL(runtime.settings["privacypolicy"])
end

termsOfUseTouched = function(event)
    system.openURL(runtime.settings["termsofuse"])
end

alertListener = function(event)
  Util.sound("select")
  composer.gotoScene('scenes.Menu', { effect='slideDown', params={} })
end

showStoreTimeout = function()
  runtime.log("[STORE] Timeout in store call")
  native.showAlert("Store", T.find("store_timeout"), {"Ok"})
end

setTimeoutWithCallback = function(callback, delay)
    local thisTimerDelay = delay or timeoutDelay
    cancelTimeoutTimer()
    if callback ~= nil then
      runtime.log("[STORE] Starting timer (" .. delay .. ")")
      timeoutTimer = timer.performWithDelay(thisTimerDelay, function()
        callback()
      end)
    end
end

cancelTimeoutTimer = function()
    if timeoutTimer ~= nil then
      runtime.log("[STORE] Cancelled timeout timer")
      timer.cancel(timeoutTimer)
    end
end

buttonTouched = function(event)
    local t = event.target
    local id = t.id 
    
    if event.phase == "began" then 
        display.getCurrentStage():setFocus(t)
        t.isFocus = true
        t.xScale = 0.85
        t.yScale = 0.85
        if t.linked ~= nil then
          t.linked.xScale = 0.85
          t.linked.yScale = 0.85
        end

    elseif t.isFocus then
        if event.phase == "ended" then
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
            t.xScale = 1
            t.yScale = 1
            if t.linked ~= nil then
              t.linked.xScale = 1
              t.linked.yScale = 1
            end

            local b = t.contentBounds 
            if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then
                if id == "back" then
                  Util.sound("select")
                  composer.gotoScene('scenes.Menu', { effect='slideDown', params={} })

                elseif id == "unlock" and not purchaseInProgress then
                  Util.sound("select")
                  if button_buy1 ~= nil then
                    purchaseInProgress = true
                    button_buy1:setFillColor(unpack(runtime.COLORS.Silver))
                  end
                  _G.storeCallback = iapListenerPurchase
                  setTimeoutWithCallback(showStoreTimeout,1000*60)
                  runtime.log("[STORE] Starting purchase: " .. id)
                  iap.purchase("unlock")

                elseif id == "submonthly" and not purchaseInProgress then
                  Util.sound("select")
                  if button_buy2 ~= nil then
                    purchaseInProgress = true
                    button_buy2:setFillColor(unpack(runtime.COLORS.Silver))
                  end
                  _G.storeCallback = iapListenerPurchase
                  setTimeoutWithCallback(showStoreTimeout,1000*60)
                  runtime.log("[STORE] Starting purchase: " .. id)
                  iap.purchase("subMonthly")

                elseif id == "restore" and not purchaseInProgress then
                  Util.sound("select")
                  if button_restore ~= nil then
                    purchaseInProgress = true
                    button_restore:setFillColor(unpack(runtime.COLORS.Silver))
                  end
                  _G.storeCallback = iapListenerRestore
                  setTimeoutWithCallback(showStoreTimeout,1000*60)
                  runtime.log("[STORE] Starting restore")
                  iap.restore(false)

                elseif id == "managesub" then
                  Util.sound('select')
                  timer.performWithDelay(30, function()
                      manageSubscriptionTouched()
                  end)

                elseif id == "privacy" then
                  Util.sound('select')
                  timer.performWithDelay(30, function()
                      privacyPolicyTouched()
                  end)

                elseif id == "termsofuse" then
                  Util.sound('select')
                  timer.performWithDelay(30, function()
                      termsOfUseTouched()
                  end)

                end
            end
        end
    end
    return true
end

showTrialGames = function()
  runtime.log("[STORE] Showing trial games")
  loadingText = display.newText({parent=buttonGroup, text=T.find("loading"), x=0, y=0, font=runtime.FONTS.TEXT, fontSize=35*scaling})
  loadingText.x, loadingText.y = display.contentCenterX, display.contentCenterY - 20*scaling
  loadingText.alpha = 1
  loadingText:setFillColor(unpack(runtime.COLORS.Black))

  local gamesPlayedDisplay = globalData.gamesPlayed
  if gamesPlayedDisplay > globalData.freeTrialGames then
    gamesPlayedDisplay = globalData.freeTrialGames
  end
  playedGames = display.newText({
      parent=buttonGroup, text=T.find("you_played") .. globalData.gamesPlayed .. T.find("of") .. globalData.freeTrialGames .. T.find("trial_games") , 
      x=0, y=0, fontSize=14*scaling, font=runtime.FONTS.TEXT
  })
  playedGames.x, playedGames.y = display.contentCenterX, runtime.topInset + 80*scaling
  if gamesPlayedDisplay == globalData.freeTrialGames then
    playedGames:setFillColor(unpack(runtime.COLORS.DarkRed))
  else
    playedGames:setFillColor(unpack(runtime.COLORS.DarkGray))
  end
  runtime.log("[STORE] Done showTrialGames")
end

showGameUnlocked = function()
  gameUnlockedText = display.newText({
      parent=buttonGroup, text=T.find("thanks_playing"), 
      x=0, y=0, fontSize=18*scaling, font=runtime.FONTS.TEXT,
  })
  gameUnlockedText.x, gameUnlockedText.y = display.contentCenterX, display.contentCenterY
  gameUnlockedText:setFillColor(unpack(runtime.COLORS.DarkGray))
end

showBuyButtons = function()
    runtime.log("[STORE] Showing buy buttons")
    if runtime.settings["currentscene"] ~= "GameStore" then
        return
    end
    cancelTimeoutTimer()
    local products = iap.getLoadProductsCatalogue()
    if products ~= nil then
        if loadingTrans ~= nil then
            transition.cancel(loadingTrans)
        end
        if loadingText ~= nil then
            loadingText:removeSelf()
            loadingText = nil
        end

        if products["unlock"] ~= nil then
            button_buy1 = display.newImageRect(buttonGroup, "images/rect.png", 140*scaling, 50*scaling)
            button_buy1.x, button_buy1.y = display.contentCenterX - 100*scaling, display.contentCenterY - 50*scaling
            button_buy1.id = "unlock"
            button_buy1:addEventListener("touch", buttonTouched)
            text_buy1 = display.newText({parent=buttonGroup, text="" .. products["unlock"].localizedPrice, x=0, y=0, fontSize=16*scaling, font=runtime.FONTS.TEXT})
            text_buy1.x, text_buy1.y = button_buy1.x, button_buy1.y - 2
            text_buy1:setFillColor(unpack(runtime.COLORS.White))
            button_buy1.linked = text_buy1

            text_detail1 = display.newText({
              parent=buttonGroup, text=T.find("product_onetime"), 
              x=0, y=0, fontSize=14*scaling, font=runtime.FONTS.TEXT,
              width = 180*scaling
            })
            text_detail1.x, text_detail1.y = display.contentCenterX + 80*scaling, button_buy1.y
            text_detail1:setFillColor(unpack(runtime.COLORS.Black))
        end

        if products["subMonthly"] ~= nil then
            button_buy2 = display.newImageRect(buttonGroup, "images/rect.png", 140*scaling, 50*scaling)
            button_buy2.x, button_buy2.y = display.contentCenterX - 100*scaling, display.contentCenterY + 30*scaling
            button_buy2.id = "submonthly"
            button_buy2:addEventListener("touch", buttonTouched)
            text_buy2 = display.newText({parent=buttonGroup, text="" .. products["subMonthly"].localizedPrice .. " / mo", x=0, y=0, fontSize=16*scaling, font=runtime.FONTS.TEXT})
            text_buy2.x, text_buy2.y = button_buy2.x, button_buy2.y - 2
            text_buy2:setFillColor(unpack(runtime.COLORS.White))
            button_buy2.linked = text_buy2

            text_detail2 = display.newText({
              parent=buttonGroup, text=T.find("product_subscription"), 
              x=0, y=0, fontSize=14*scaling, font=runtime.FONTS.TEXT,
              width = 180*scaling
            })
            text_detail2.x, text_detail2.y = display.contentCenterX + 80*scaling, button_buy2.y
            text_detail2:setFillColor(unpack(runtime.COLORS.Black))
        end

        -- Show if both one time unlock and subscription are available
        if products["unlock"] ~= nil and products["subMonthly"] ~= nil then
          legalText = display.newText({
            parent=buttonGroup, text=T.find("store_legal_1") .. products["unlock"].localizedPrice .. T.find("store_legal_2") .. products["subMonthly"].localizedPrice .. T.find("store_legal_3"),
            x=0, y=0, fontSize=8*scaling, width = backRect.width-20*scaling
          })
          legalText.x, legalText.y = display.contentCenterX, backRect.y + backRect.height - 80*scaling
          legalText:setFillColor(unpack(runtime.COLORS.Black))
        end

        -- Show if only the one time unlock is available
        if products["unlock"] ~= nil and products["subMonthly"] == nil then
          legalText = display.newText({
            parent=buttonGroup, text=T.find("store_legal_4") .. products["unlock"].localizedPrice .. T.find("store_legal_5"),
            x=0, y=0, fontSize=8*scaling, width = backRect.width-20*scaling
          })
          legalText.x, legalText.y = display.contentCenterX, backRect.y + backRect.height - 80*scaling
          legalText:setFillColor(unpack(runtime.COLORS.Black))
        end

        -- Show if there is no way to buy
        if products["unlock"] == nil and products["subMonthly"] == nil then
          storeUnavailableText = display.newText({parent=buttonGroup, text=T.find("store_unavailable"), x=0, y=0, font=runtime.FONTS.TEXT,
            width=backRect.width-40*scaling, fontSize=24*scaling, align="center"})
          storeUnavailableText.x, storeUnavailableText.y = display.contentCenterX, display.contentCenterY
          storeUnavailableText:setFillColor(unpack(runtime.COLORS.Black))
        end

    end
end

function scene:create(event)
  sceneGroup = self.view
  bgGroup = display.newGroup()
  sceneGroup:insert(bgGroup)
  headerGroup = display.newGroup()
  sceneGroup:insert(headerGroup)
  buttonGroup = display:newGroup()
  sceneGroup:insert(buttonGroup)
  textGroup = display:newGroup()
  sceneGroup:insert(textGroup)

  local y = runtime.topInset + 20

  Util.banner(headerGroup, y, T.find("store_title"))

  y = y + 18

  backRect = display.newRect(headerGroup, display.contentCenterX, y, display.contentWidth - 20*scaling, display.contentHeight - 30)
  backRect.anchorY = 0
  backRect:setFillColor(unpack(runtime.COLORS.White))
  backRect.alpha = 0.7

  button_restore = display.newImageRect(buttonGroup, "images/rect.png", 120*scaling, 30*scaling)
  button_restore.x, button_restore.y = 70*scaling, display.contentHeight - 30*scaling
  button_restore.id = "restore"
  button_restore:addEventListener("touch", buttonTouched)
  text_restore = display.newText({parent=buttonGroup, text=T.find("restore_purchase"), x=0, y=0, fontSize=13*scaling})
  text_restore.x, text_restore.y = button_restore.x, button_restore.y - 2
  text_restore:setFillColor(unpack(runtime.COLORS.White))
  button_restore.linked = text_restore

  backButton = display.newImageRect(buttonGroup,"images/ui/button_up.png", 32*scaling, 35*scaling)
  backButton.x = display.contentWidth - 33*scaling
  backButton.y = display.contentHeight - 30*scaling
  backButton.id = "back"
  backButton:addEventListener("touch", buttonTouched)

  button_managesub = display.newImageRect(buttonGroup, "images/rect.png", 130*scaling, 30*scaling)
  button_managesub.x, button_managesub.y = display.contentCenterX - 70*scaling, display.contentHeight - 30*scaling
  button_managesub.id = "managesub"
  button_managesub:addEventListener("touch", buttonTouched)
  text_managesub = display.newText({parent=buttonGroup, text=T.find("manage_subscription"), x=0, y=0, fontSize=11*scaling})
  text_managesub.x, text_managesub.y = button_managesub.x, button_managesub.y - 2*scaling
  text_managesub:setFillColor(unpack(runtime.COLORS.White))
  button_managesub.linked = text_managesub

  button_privacy = display.newImageRect(buttonGroup, "images/rect.png", 80*scaling, 30*scaling)
  button_privacy.x, button_privacy.y = display.contentCenterX + 60*scaling, display.contentHeight - 30*scaling
  button_privacy.id = "privacy"
  button_privacy:addEventListener("touch", buttonTouched)
  text_privacy = display.newText({parent=buttonGroup, text=T.find("privacy"), x=0, y=0, fontSize=11*scaling})
  text_privacy.x, text_privacy.y = button_privacy.x, button_privacy.y - 2*scaling
  text_privacy:setFillColor(unpack(runtime.COLORS.White))
  button_privacy.linked = text_privacy

  if runtime.settings["termsofuse"] then
    button_terms = display.newImageRect(buttonGroup, "images/rect.png", 80*scaling, 30*scaling)
    button_terms.x, button_terms.y = display.contentCenterX + 165*scaling, display.contentHeight - 30*scaling
    button_terms.id = "termsofuse"
    button_terms:addEventListener("touch", buttonTouched)
    text_terms = display.newText({parent=buttonGroup, text=T.find("terms"), x=0, y=0, fontSize=11*scaling})
    text_terms.x, text_terms.y = button_terms.x, button_terms.y - 2*scaling
    text_terms:setFillColor(unpack(runtime.COLORS.White))
    button_terms.linked = text_terms
  end

end


function scene:show(event)
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    Util.setBackground(bgGroup)

    if globalData.subscriptionActive or globalData.permanentUnlock then
      showGameUnlocked()
    else
      showTrialGames()
      iap.loadProducts(showBuyButtons)
      loadingTrans = transition.to(loadingText, {time=800, alpha=0, easing=easing.continuousLoop, iterations=5000})
      setTimeoutWithCallback(showStoreTimeout, 1000*15)
    end

  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen

  end
end

-- hide()
function scene:hide(event)
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    runtime.settings["currentscene"] = ""
    if loadingTrans ~= nil then
        transition.cancel(loadingTrans)
    end
    cancelTimeoutTimer()

  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    if loadingText ~= nil then
        loadingText:removeSelf()
        loadingText = nil
    end
    if playedGames ~= nil then
        playedGames:removeSelf()
        playedGames = nil
    end
  end
end

-- destroy()
function scene:destroy(event)
  -- Code here runs prior to the removal of scene's view
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)
-- -----------------------------------------------------------------------------------

return scene
