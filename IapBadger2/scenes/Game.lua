local globalData = require 'globalData'
local Util = require 'libraries.Util'
local runtime = require 'libraries.runtime'
local T = require"libraries.translator"
local composer = require('composer')
local scene = composer.newScene()
local sceneGroup
local bgGroup,uiGroup
local scaling = 1.6
local button_menu, playedGames
local buttonY = display.contentHeight - 42*scaling

local buttonTouched = function(event)
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

                if id == "menu" then
                    Util.sound('select')
                    composer.gotoScene('scenes.Menu', {effect='slideRight'})
                end
            end
        end
    end
    return true
end

local showTrialGames = function()
  local gamesPlayedDisplay = globalData.gamesPlayed
  if gamesPlayedDisplay > globalData.freeTrialGames then
    gamesPlayedDisplay = globalData.freeTrialGames
  end
  playedGames = display.newText({
      parent=uiGroup, text=T.find("you_played") .. globalData.gamesPlayed .. T.find("of") .. globalData.freeTrialGames .. T.find("trial_games") , 
      x=0, y=0, fontSize=14*scaling, font=runtime.FONTS.TEXT
  })
  playedGames.x, playedGames.y = display.contentCenterX, display.contentCenterY
  if gamesPlayedDisplay == globalData.freeTrialGames then
    playedGames:setFillColor(unpack(runtime.COLORS.DarkRed))
  else
    playedGames:setFillColor(unpack(runtime.COLORS.DarkGray))
  end
end

function scene:create(event)
  sceneGroup = self.view
  bgGroup = display.newGroup()
  sceneGroup:insert(bgGroup)
  uiGroup = display.newGroup()
  sceneGroup:insert(uiGroup)

  button_menu = display.newImageRect(uiGroup,"images/ui/button_left.png",36*scaling, 39*scaling)
  button_menu.x = display.contentCenterX - 160*scaling
  button_menu.y = buttonY
  button_menu.id = "menu"
  button_menu:addEventListener("touch", buttonTouched)
  uiGroup:insert(button_menu)

end

function scene:show(event)
  local phase = event.phase

  if phase == 'will' then
    Util.setBackground(bgGroup)
    globalData.gamesPlayed = globalData.gamesPlayed + 1
    globalData:saveSettings()
    showTrialGames()

  elseif phase == 'did' then
    -- Code here runs when the scene is entirely on screen

  end
end

function scene:hide(event)
  local phase = event.phase

  if phase == 'will' then
    -- Code here runs when the scene is on screen (but is about to go off screen)
  elseif phase == 'did' then
    -- Code here runs immediately after the scene goes entirely off screen
    uiGroup:remove(playedGames)
  end
end

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
