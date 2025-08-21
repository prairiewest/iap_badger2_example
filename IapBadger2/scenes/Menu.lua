local composer = require('composer')
local scene = composer.newScene()
local globalData = require 'globalData'
local Util = require 'libraries.Util'
local runtime = require 'libraries.runtime'
local iap = require 'libraries.iap_badger2'
local T = require"libraries.translator"

runtime.settings["currentscene"] = "Menu"

local button_play1, button_text1
local scaling = 1.6
local button_soundon, button_soundoff, button_store
local sceneGroup, backgroundGroup, titleGroup, iapListenerOther
local restoreRequested = false
local iapListenerRestore, checkSubscriptionExpiry, refreshSound, buttonTouched, checkStoreButton
local buttonY = display.contentHeight - 42*scaling
local languageLabel, languageButtonListener

iapListenerOther = function(product, eventType)
    -- Do nothing
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

iapListenerRestore = function(product, eventType)
    -- Do not reset restoreRequested here or it could be an infinite loop of restores
    -- So a restore should be performed only once each time the Menu scene is shown
    checkSubscriptionExpiry()
end

checkSubscriptionExpiry = function()
    if globalData.permanentUnlock then
        runtime.log("[MENU] Permanent unlock is true, not checking subscription expiry")
        return
    end

    if subscriptionGrace and not restoreRequested then
        _G.storeCallback = iapListenerRestore
        restoreRequested = true
        timer.performWithDelay(30, function()
            iap.restore(false)
        end)
    end

    if globalData.subscriptionActive then
        runtime.log("[MENU] Checking subscription end date")
        if globalData.subscriptionEndDate < os.time() then
            runtime.log("[MENU] Subscription just expired - will run a restore event to check for new subscription data")
            globalData.subscriptionActive = false
            globalData:saveSettings()
            if not restoreRequested then
                _G.storeCallback = iapListenerRestore
                restoreRequested = true
                timer.performWithDelay(30, function()
                    iap.restore(false)
                end)
            end
        else
            runtime.log("[MENU] Subscription expires in " .. tostring(globalData.subscriptionEndDate - os.time() ) .. " seconds")
        end
    else
        runtime.log("[MENU] Subscription is not active, not checking end date for expiry")
    end

    if globalData.subscriptionEndDate > 0 and not globalData.subscriptionActive then
        runtime.log("[MENU] Subscription used to be active")
        -- Subscription not active but used to be, check for grace period
        if globalData.subscriptionEndDate > (os.time() + runtime.subscriptionGraceSeconds) then
            globalData.subscriptionGrace = true
            runtime.log("[MENU] Subscription grace = true, " .. tostring(os.time() + runtime.subscriptionGraceSeconds - globalData.subscriptionEndDate) .. " seconds remain")
        else
            globalData.subscriptionGrace = false
            runtime.log("[MENU] Subscription grace = false")
        end
        globalData:saveSettings()
    end
end

checkStoreButton = function()
    if globalData.subscriptionActive or globalData.permanentUnlock then
        button_store:setFillColor(unpack(runtime.COLORS.Silver))
    else
        button_store:setFillColor(unpack(runtime.COLORS.White))
    end
end

refreshSound = function()
    if globalData.soundOn then
        button_soundon.isVisible = true
        button_soundoff.isVisible = false
    else
        button_soundon.isVisible = false
        button_soundoff.isVisible = true
    end
end

languageButtonListener = function(event)
    if event.phase == "began" then
        Util.sound("select")
        globalData.language = T.getNextLanguage(globalData.language)
        runtime.log("New language: " .. globalData.language)
        globalData.savedGame = nil
        globalData.lastInstructions = 0
        globalData:saveSettings()
        languageLabel.text = globalData.language:upper()
        button_text1.text = T.find("play")
        composer.gotoScene("scenes.Menu", { time = 250, effect = "fade" })
        composer:removeHidden()
    end
    return true
end

buttonTouched = function(event)
    local t = event.target
    local id = t.id 
    
    if event.phase == "began" then 
        display.getCurrentStage():setFocus( t )
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

                if id == "play" then
                    Util.sound('select')
                    if globalData.gamesPlayed < globalData.freeTrialGames or globalData.subscriptionActive or globalData.subscriptionGrace or globalData.permanentUnlock then
                        composer.gotoScene('scenes.Game', {effect='slideLeft'})
                    else
                        composer.gotoScene('scenes.GameStore', {effect='slideUp'})
                    end

                elseif id == "store" then
                    Util.sound('select')
                    composer.gotoScene('scenes.GameStore', {effect='slideUp'})

                elseif id == "togglesound" then
                    if globalData.soundOn then
                        globalData.soundOn = false
                    else
                        globalData.soundOn = true
                        Util.sound('select')
                    end
                    globalData:saveSettings()
                    refreshSound()
                end
            end
        end
    end
    return true
end

function scene:create(event)
  sceneGroup = self.view
  backgroundGroup = display.newGroup()
  sceneGroup:insert(backgroundGroup)
  titleGroup = display.newGroup()
  sceneGroup:insert(titleGroup)
  uiGroup = display.newGroup()
  sceneGroup:insert(uiGroup)

  button_play1 = display.newImageRect(uiGroup, "images/rect.png", 140*scaling, 50*scaling)
  button_play1.x, button_play1.y = display.contentCenterX, display.contentCenterY
  button_play1.id = "play"
  button_play1:addEventListener("touch", buttonTouched)
  button_text1 = display.newText({parent=uiGroup, text=T.find("play"), x=0, y=0, font=runtime.FONTS.TEXT, fontSize=20*scaling})
  button_text1.x, button_text1.y = button_play1.x, button_play1.y - 2
  button_text1:setFillColor(unpack(runtime.COLORS.White))
  button_play1.linked = button_text1

  button_store = display.newImageRect(uiGroup,"images/ui/button_store.png",36*scaling, 39*scaling)
  button_store.x = display.contentCenterX - 160*scaling
  button_store.y = buttonY
  button_store.id = "store"
  button_store:addEventListener("touch", buttonTouched)

  button_soundon = display.newImageRect(uiGroup, "images/ui/button_soundon.png", 36*scaling, 39*scaling)
  button_soundon.x = display.contentCenterX + 160*scaling
  button_soundon.y = buttonY
  button_soundon.id = "togglesound"
  button_soundon:addEventListener("touch", buttonTouched)
  if not globalData.soundOn then
      button_soundon.isVisible = false
  end

  button_soundoff = display.newImageRect(uiGroup, "images/ui/button_soundoff.png", 36*scaling, 39*scaling)
  button_soundoff.x = button_soundon.x
  button_soundoff.y = buttonY
  button_soundoff.id = "togglesound"
  button_soundoff:addEventListener("touch", buttonTouched)
  if globalData.soundOn then
      button_soundoff.isVisible = false
  end

  titleLabel = display.newText(T.find("menu_title"), 10, 10, runtime.FONTS.TEXT, 30*scaling )
  titleLabel:setFillColor(unpack(runtime.COLORS.Black))
  titleLabel.x, titleLabel.y = display.contentWidth/2, 60*scaling + runtime.topInset
  uiGroup:insert( titleLabel)

  languageLabel = display.newText( globalData.language:upper(), 10, 10, runtime.FONTS.TEXT, 20*scaling )
  languageLabel:setFillColor(unpack(runtime.COLORS.Black))
  languageLabel.x, languageLabel.y = display.contentWidth - 20*scaling, 20*scaling + runtime.topInset
  languageLabel:addEventListener("touch", languageButtonListener)
  uiGroup:insert( languageLabel)

end

-- show()
function scene:show(event)
  local phase = event.phase
  runtime.log("[SCENE] EVENT: menu show " .. event.phase)

  if phase == 'will' then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    Util.setBackground(backgroundGroup)
    checkSubscriptionExpiry()
    checkStoreButton()

  elseif phase == 'did' then
    refreshSound()
    if composer.getScene("scenes.GameStore") ~= nil then
        composer.removeScene("scenes.GameStore")
    end

  end
end

-- hide()
function scene:hide(event)
  runtime.log("[SCENE] EVENT: menu hide " .. event.phase)
  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    _G.storeCallback = nil

  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    for i = 1, #transitions do
        if transitions[i] ~= nil then
            transition.cancel(transitions[i])
        end
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
