-- stroke module com.ponywolf.ponystroke
-- modified to always use a group

-- define module
local M = {}
local renderSteps = 1

function M.newText(options)

  -- default options for instance
  options = options or {}
  local h = options.height
  options.height = nil
  options.x = 0
  options.y = 0

  -- new options 
  local color = options.color or {1,1,1,1}
  local strokeColor = options.strokeColor or {0,0,0,0.75}
  local strokeWidth = options.strokeWidth or 2
  local strokeAlpha = options.strokeAlpha or 1

  -- create the main text
  local text = display.newText(options)
  text:setFillColor(unpack(color))

  -- make a bounding box based on the default text
  local width = math.max(text.contentWidth, options.width or 0)
  local height = h or math.max(text.contentHeight * 2, width)

  --  create group to hold text/strokes
  local stroked = display.newGroup()
  stroked.strokes = {}
  stroked.unstroked = text

  -- draw the strokes
  for i = -strokeWidth, strokeWidth, renderSteps do
    for j = -strokeWidth, strokeWidth, renderSteps do
      if not (i == 0 and j == 0) then --skip middle
        options.x,options.y = i,j
        local stroke = display.newText(options)
        stroke.alpha = strokeAlpha
        stroke:setFillColor(unpack(strokeColor))
        stroked:insert(stroke)
        stroked.strokes[#stroked.strokes+1] = stroke
      end
    end
  end

  -- call this function to update the text and invalidate the canvas
  function stroked:update(text)
    self.unstroked.text = text
    self.text = text
    for i=1, #self.strokes do
      self.strokes[i].text = text
    end
    if self.invalidate then self:invalidate() end
  end

  stroked:insert(text)
  function stroked:setFillColor(r,g,b,a)
    stroked.unstroked:setFillColor(r,g,b,a)
  end

  -- return instance
  return stroked
end

-- return module
return M