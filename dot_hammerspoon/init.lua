local hyper = { "ctrl", "alt", "cmd" }
local lesshyper = { "ctrl", "alt" }

-- Activity Manager --
local awakeTimer = nil

local function sleep(n)
	os.execute("sleep " .. tonumber(n))
end

hs.hotkey.bind(hyper, "W", function()
	hs.alert.show("Hello World!")
end)

hs.hotkey.bind(hyper, "A", function()
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
		hs.mouse.absolutePosition({ x = position.x + movement, y = position.y })
	end

	awakeTimer = hs.timer.doUntil(function()
		return awakeTimer == nil
	end, activity, 5)
end)

-- Global Mute Hotkeys --
hs.loadSpoon("GlobalMute")
spoon.GlobalMute:bindHotkeys({
	unmute = { lesshyper, "u" },
	mute = { lesshyper, "m" },
	toggle = { hyper, "t" },
})
spoon.GlobalMute:configure({
	unmute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png",
	mute_background = "file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png",
	enforce_desired_state = true,
	stop_sococo_for_zoom = true,
	unmute_title = "",
	mute_title = "",
	-- change_screens = "SCREENNAME1, SCREENNAME2"  -- This will only change the background of the specific screens.  string.find()
})
spoon.GlobalMute._logger.level = 3
