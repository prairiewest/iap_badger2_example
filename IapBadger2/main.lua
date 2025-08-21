display.setStatusBar( display.HiddenStatusBar )
if audio.supportsSessionProperty ~= nil and audio.supportsSessionProperty == true then
    audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end
if system.getInfo("platformName") == "Android" then
    local androidVersion = string.sub(system.getInfo("platformVersion"), 1, 3)
    if androidVersion and tonumber(androidVersion) >= 4.4 then
        native.setProperty("androidSystemUiVisibility", "immersiveSticky")
    elseif androidVersion then
        native.setProperty("androidSystemUiVisibility", "lowProfile")
    end
end

local composer = require "composer"
local globalData = require "globalData"
local runtime = require "libraries.runtime"
local uuid = require "libraries.uuid"

if system.getInfo('environment') == 'simulator' then
    composer.isDebug = true
end

native.setProperty('windowTitleText', 'EXAMPLE')
math.randomseed(uuid.randomseed(os.time()))

runtime.log("PLATFORM: " .. system.getInfo("platform"))

local detectLanguage = function()
    local newLang = nil
    if globalData.languagesetfromos == false then
        -- Only do this once
        runtime.log("Trying to set language from device OS")
        lang = system.getPreference( "locale", "language" ):lower()
        if lang == nil or lang == "" then
            lang = system.getPreference( "ui", "language" ):lower()
        end

        if lang ~= nil then
            lang = string.sub(lang,1,2)
            runtime.log("Device language code: " .. lang)
            if lang == "es" or lang == "en" then
                newLang = lang
            else
                runtime.log("Unknown language code: " .. lang)
            end
        end
    end
    if newLang ~= nil then
        globalData.language = newLang
        globalData.languagesetfromos = true
        globalData:saveSettings()
    end
end

_G.onSystemEvent = function( event )
    print("[MAIN] Application event: " .. event.type)
    if event.type == "applicationSuspend" or event.type == "applicationExit" then
        globalData:saveSettings()
        return true
    end
    if event.type == "applicationResume" then
        globalData:loadSettings()
        return true
    end
    if event.type == "applicationStart" then
        globalData:loadSettings()
        detectLanguage()
        return true
    end
end
Runtime:addEventListener("system", _G.onSystemEvent)

-- Table functions
if not _G.table.contains then
    function _G.table.contains(tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true, index
            end
        end
        return false, 0
    end
end

if not _G.table.length then
  function _G.table.length(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
  end
end

if not _G.table.clone then
  function _G.table.clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in pairs(orig) do
        copy[orig_key] = orig_value
      end
    else -- number, string, boolean, etc
      copy = orig
    end
    return copy
  end
end

composer.gotoScene('scenes.CutScene')
