local M = {}
local runtime = require("libraries.runtime")
local persist = require("libraries.persist")
local globalData = require("globalData")

M.cache = nil
M.nextLanguage = {
    en = "es",
    es = "en",
    es = "fr",
    fr = "it",
    it = "en"
}

-- Return the next language to cycle through in selection
M.getNextLanguage = function(current)
    return M.nextLanguage[current]
end

-- Translates a word or key into a specific language
M.find = function(key)
    if M.cache == nil then
        M.init()
    end

    local lookupKey = string.lower(key)
    local lookupResult
    local lang = globalData.language
    if lang == "" then lang = "en"; end

    if key == " " then return key; end

    if M.cache[lang] ~= nil and M.cache[lang][lookupKey] ~= nil then
       lookupResult = M.cache[lang][lookupKey]
    else
        if (runtime.settings["debug"] == true) then
          lookupResult = '??'
        else
          lookupResult = key
        end
    end

    return lookupResult

end

M.init = function()
    M.cache = persist.loadTable("i18n.json", system.ResourceDirectory)
end

return M