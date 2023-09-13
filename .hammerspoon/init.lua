awakeTimer = nil

function sleep(n)
    os.execute('sleep ' .. tonumber(n))
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.alert.show("Hello World!")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "A", function()
  if awakeTimer == nil then
    hs.alert.show("Keeping you active!")
  else
    hs.alert.show("Disabling activity daemon")
    awakeTimer = nil
    return
  end

  local activity = function()
    local position = hs.mouse.absolutePosition()
    local movement = 0
    if position.x % 2 == 0 then
      movement = 5
    else
      movement = -5
    end
    hs.mouse.absolutePosition({x = position.x + movement, y = position.y})
  end

  awakeTimer = hs.timer.doUntil(function() return awakeTimer == nil end, activity, 5)
end)
