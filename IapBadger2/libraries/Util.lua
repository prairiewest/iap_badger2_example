-- Util.lua

local widget = require "widget"
local globalData = require "globalData"
local runtime = require "libraries.runtime"
local strokedText = require "libraries.strokedText"

local Util = {}

function Util.setBackground(group)
  display.setDefault('background', unpack(runtime.COLORS.Black))
  while group.numChildren > 0 do
    local child = group[1]
    if child then child:removeSelf() end
  end
  local todayDay = os.date("%d")
  local bg = display.newImageRect(group, "images/background/1.jpg", 1500, 844)
  bg.x, bg.y = display.contentCenterX, display.contentCenterY 
end

function Util.banner(grp, y, text)
  local bannerText = strokedText.newText({
    text = text,
    font = runtime.FONTS.TEXT,
    fontSize = 32,
    align = "center",
    color = runtime.COLORS.White,
    strokeColor = runtime.COLORS.Black,
    strokeWidth = 1.5,
    strokeAlpha = 0.3
  })

  bannerText.x = display.contentCenterX
  bannerText.y = y
  grp:insert(bannerText)
  return bannerText
end

function Util.sound(name)
  if globalData.soundOn then
    local handle
    handle = runtime.SOUNDS[name]
    if handle then
      audio.play(handle)
    end
  end
end

return Util
