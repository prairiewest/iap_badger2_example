local composer  = require( "composer" )
local scene     = composer.newScene()

-- This scene is temporary, allowing composer to remove the Menu scene so it can be recreated after a purchase

function scene:create( event )
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        composer.removeHidden()  --Remove all other scenes
        composer.gotoScene("scenes.Menu")
    end
end


function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end

function scene:destroy( event )
    -- Called prior to the removal of scene's view ("sceneGroup").
end

-- Then add the listeners for the above functions
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
  


