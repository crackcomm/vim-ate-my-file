--[[
    World Population Clock
--]]
local gears = require("gears")
local wibox = require("wibox")

local start_time = os.time({ year = 2025, month = 4, day = 28, hour = 5, min = 27, sec = 0 })
local start_population = 8219739634
local growth_per_second = 2.5

local function format_with_commas(num)
	local formatted = tostring(num)
	local reverse = formatted:reverse()
	local formatted_reverse = reverse:gsub("(%d%d%d)", "%1,")
	return formatted_reverse:reverse():gsub("^,", "")
end

local widget = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = "sans 12",
})

local current_population = start_population

gears.timer({
	timeout = 0.1, -- update every 0.1 seconds
	autostart = true,
	call_now = true,
	callback = function()
		local elapsed = os.difftime(os.time(), start_time)
		local target_population = start_population + math.floor(elapsed * growth_per_second)

		-- Animate by incrementing population towards target, creating smooth effect
		if current_population < target_population then
			current_population = current_population + math.ceil((target_population - current_population) * 0.1) -- 10% of the difference each time
		end

		widget.text = string.format("%s", format_with_commas(current_population))
	end,
})

return widget
