local application = require("hs.application")
local fnutils = require("hs.fnutils")
local grid = require("hs.grid")
local hotkey = require("hs.hotkey")
local mjomatic = require("hs.mjomatic")
local window = require("hs.window")
local spaces = require("hs.spaces")

grid.MARGINX = 0
grid.MARGINY = 0
grid.GRIDHEIGHT = 12
grid.GRIDWIDTH = 12

local mash = { "cmd", "alt" }
local mashctrl = { "cmd", "alt", "ctrl" }

--
-- replace caffeine
--
local caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
	local result
	if state then
		result = caffeine:setIcon("caffeine-on.pdf")
	else
		result = caffeine:setIcon("caffeine-off.pdf")
	end
end

function caffeineClicked()
	setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
	caffeine:setClickCallback(caffeineClicked)
	setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

hs.hotkey.bind(mash, "/", function()
	caffeineClicked()
end)
--
-- /replace caffeine
--

--
-- toggle push window to edge and restore to screen
--

-- somewhere to store the original position of moved windows
local origWindowPos = {}

-- cleanup the original position when window restored or closed
local function cleanupWindowPos(_, _, _, id)
	origWindowPos[id] = nil
end

-- function to move a window to edge or back
local function movewin(direction)
	local win = hs.window.frontmostWindow()
	local res = hs.screen.mainScreen():frame()
	local id = win:id()

	if not origWindowPos[id] then
		-- move the window to edge if no original position is stored in
		-- origWindowPos for this window id
		local f = win:frame()
		origWindowPos[id] = win:frame()

		-- add a watcher so we can clean the origWindowPos if window is closed
		local watcher = win:newWatcher(cleanupWindowPos, id)
		watcher:start({ hs.uielement.watcher.elementDestroyed })

		if direction == "left" then
			f.x = (res.w - (res.w * 2)) + 10
		end
		if direction == "right" then
			f.x = (res.w + res.w) - 10
		end
		if direction == "down" then
			f.y = (res.h + res.h) - 10
		end
		win:setFrame(f)
	else
		-- restore the window if there is a value for origWindowPos
		win:setFrame(origWindowPos[id])
		-- and clear the origWindowPos value
		cleanupWindowPos(_, _, _, id)
	end
end

hs.hotkey.bind(mash, "A", function()
	movewin("left")
end)
hs.hotkey.bind(mash, "D", function()
	movewin("right")
end)
hs.hotkey.bind(mash, "S", function()
	movewin("down")
end)
--
-- /toggle push window to edge and restore to screen
--

--
-- Open Applications
--
local function openchrome()
	application.launchOrFocus("Google Chrome")
end

local function openff()
	application.launchOrFocus("FirefoxDeveloperEdition")
end

local function openmail()
	application.launchOrFocus("Airmail Beta")
end

hotkey.bind(mash, "F", openff)
hotkey.bind(mash, "C", openchrome)
hotkey.bind(mash, "M", openmail)
--
--
-- Window management
--
--Alter gridsize
hotkey.bind(mashctrl, "=", function()
	grid.adjustHeight(1)
end)
hotkey.bind(mashctrl, "-", function()
	grid.adjustHeight(-1)
end)
hotkey.bind(mash, "=", function()
	grid.adjustWidth(1)
end)
hotkey.bind(mash, "-", function()
	grid.adjustWidth(-1)
end)

--Snap windows
hotkey.bind(mash, ";", function()
	module.topHalf()
end)
hotkey.bind(mash, "'", function()
	module.bottomHalf()
end)
hotkey.bind(mash, ",", function()
	module.leftHalf()
end)
hotkey.bind(mash, ".", function()
	module.rightHalf()
end)

hotkey.bind(mashctrl, ";", function()
	module.topLeftQuarter()
end)
hotkey.bind(mashctrl, "'", function()
	module.topRightQuarter()
end)
hotkey.bind(mashctrl, ",", function()
	module.bottomLeftQuarter()
end)
hotkey.bind(mashctrl, ".", function()
	module.bottomRightQuarter()
end)

hotkey.bind(mashctrl, "H", function()
	window.frontmostWindow():focusWindowWest()
end)
hotkey.bind(mashctrl, "L", function()
	window.frontmostWindow():focusWindowEast()
end)
hotkey.bind(mashctrl, "K", function()
	window.frontmostWindow():focusWindowNorth()
end)
hotkey.bind(mashctrl, "J", function()
	window.frontmostWindow():focusWindowSouth()
end)

--Move windows hotkey.bind(mash, 'J', grid.pushWindowDown) hotkey.bind(mash, 'K', grid.pushWindowUp)
hotkey.bind(mash, "H", grid.pushWindowLeft)
hotkey.bind(mash, "L", grid.pushWindowRight)

--resize windows
hotkey.bind(mash, "U", grid.resizeWindowTaller)
hotkey.bind(mash, "O", grid.resizeWindowWider)
hotkey.bind(mash, "I", grid.resizeWindowThinner)
hotkey.bind(mash, "Y", grid.resizeWindowShorter)

hotkey.bind(mash, "N", grid.pushWindowNextScreen)
hotkey.bind(mash, "P", grid.pushWindowPrevScreen)

hotkey.bind(mash, "M", grid.maximizeWindow)

-- Move to specific desktop spaces
for i = 1, 9 do
    hotkey.bind(mash, tostring(i), function()
        print("Attempting to move to desktop " .. i)
        local screen = hs.screen.primaryScreen()
        print("Current screen: " .. screen:name())
        
        local allSpaces = spaces.allSpaces()
        print("All spaces: " .. hs.inspect(allSpaces))
        
        -- Get the first screen ID from allSpaces since that's what we have
        local screenId = next(allSpaces)
        print("Using screen ID: " .. screenId)
        
        local screenSpaces = allSpaces[screenId]
        print("Spaces for current screen: " .. hs.inspect(screenSpaces))
        
        if not screenSpaces or not screenSpaces[i] then
            print("No space " .. i .. " found for current screen")
            return
        end
        
        print("Moving to space: " .. hs.inspect(screenSpaces[i]))
        spaces.gotoSpace(screenSpaces[i])
    end)
end

-- Move window to specific desktop spaces
for i = 1, 9 do
    hotkey.bind(mashctrl, tostring(i), function()
        print("Attempting to move window to desktop " .. i)
        local win = hs.window.focusedWindow()
        if not win then
            print("No focused window")
            return
        end
        print("Moving window: " .. win:title())
        
        local app = win:application()
        if not app then
            print("No application found for window")
            return
        end
        print("Application: " .. app:name())
        print("Process ID: " .. app:pid())
        
        local screen = hs.screen.primaryScreen()
        print("Current screen: " .. screen:name())
        
        local allSpaces = spaces.allSpaces()
        print("All spaces: " .. hs.inspect(allSpaces))
        
        -- Get the first screen ID from allSpaces since that's what we have
        local screenId = next(allSpaces)
        print("Using screen ID: " .. screenId)
        
        local screenSpaces = allSpaces[screenId]
        print("Spaces for current screen: " .. hs.inspect(screenSpaces))
        
        if not screenSpaces or not screenSpaces[i] then
            print("No space " .. i .. " found for current screen")
            return
        end
        
        print("Moving window to space: " .. hs.inspect(screenSpaces[i]))
        local winId = win:id()
        print("Attempting to move window with process ID: " .. app:pid())
        spaces.moveWindowToSpace(app:pid(), screenSpaces[i] + 1)
        spaces.gotoSpace(screenSpaces[i] + 1)
    end)
end

-- Move to next desktop space
hotkey.bind(mash, "0", function()
    print("Attempting to move to next desktop")
    local screen = hs.screen.primaryScreen()
    print("Current screen: " .. screen:name())
    
    local allSpaces = spaces.allSpaces()
    print("All spaces: " .. hs.inspect(allSpaces))
    
    -- Get the first screen ID from allSpaces since that's what we have
    local screenId = next(allSpaces)
    print("Using screen ID: " .. screenId)
    
    local screenSpaces = allSpaces[screenId]
    print("Spaces for current screen: " .. hs.inspect(screenSpaces))
    
    if not screenSpaces then
        print("No spaces found for current screen")
        return
    end
    
    local currentSpace = spaces.focusedSpace()
    print("Current space: " .. hs.inspect(currentSpace))
    
    if not currentSpace then
        print("No current space found")
        return
    end
    
    -- Find the next space
    for i, space in ipairs(screenSpaces) do
        if space == currentSpace then
            local nextSpace = screenSpaces[i + 1] or screenSpaces[1]
            print("Moving to next space: " .. hs.inspect(nextSpace))
            spaces.gotoSpace(nextSpace)
            break
        end
    end
end)

-- Move window to next desktop space
hotkey.bind(mashctrl, "0", function()
    print("Attempting to move window to next desktop")
    local win = hs.window.focusedWindow()
    if not win then
        print("No focused window")
        return
    end
    print("Moving window: " .. win:title())
    
    local app = win:application()
    if not app then
        print("No application found for window")
        return
    end
    print("Application: " .. app:name())
    print("Process ID: " .. app:pid())
    
    local screen = hs.screen.primaryScreen()
    print("Current screen: " .. screen:name())
    
    local allSpaces = spaces.allSpaces()
    print("All spaces: " .. hs.inspect(allSpaces))
    
    -- Get the first screen ID from allSpaces since that's what we have
    local screenId = next(allSpaces)
    print("Using screen ID: " .. screenId)
    
    local screenSpaces = allSpaces[screenId]
    print("Spaces for current screen: " .. hs.inspect(screenSpaces))
    
    if not screenSpaces then
        print("No spaces found for current screen")
        return
    end
    
    local currentSpace = spaces.focusedSpace()
    print("Current space: " .. hs.inspect(currentSpace))
    
    if not currentSpace then
        print("No current space found")
        return
    end
    
    -- Find the next space
    for i, space in ipairs(screenSpaces) do
        if space == currentSpace then
            local nextSpace = screenSpaces[i + 1] or screenSpaces[1]
            print("Moving window to next space: " .. hs.inspect(nextSpace))
            local winId = win:id()
            print("Window ID: " .. winId)
            print("Attempting to move window with process ID: " .. app:pid())
            spaces.moveWindowToSpace(app:pid(), nextSpace)
            spaces.gotoSpace(nextSpace)
            break
        end
    end
end)

-- Move to next/previous desktop with arrows
hotkey.bind(mash, "right", function()
    print("Attempting to move to next desktop")
    local screen = hs.screen.primaryScreen()
    local allSpaces = spaces.allSpaces()
    local screenId = next(allSpaces)
    local screenSpaces = allSpaces[screenId]
    
    if not screenSpaces then return end
    
    local currentSpace = spaces.focusedSpace()
    if not currentSpace then return end
    
    for i, space in ipairs(screenSpaces) do
        if space == currentSpace then
            local nextSpace = screenSpaces[i + 1] or screenSpaces[1]
            spaces.gotoSpace(nextSpace)
            break
        end
    end
end)

hotkey.bind(mash, "left", function()
    print("Attempting to move to previous desktop")
    local screen = hs.screen.primaryScreen()
    local allSpaces = spaces.allSpaces()
    local screenId = next(allSpaces)
    local screenSpaces = allSpaces[screenId]
    
    if not screenSpaces then return end
    
    local currentSpace = spaces.focusedSpace()
    if not currentSpace then return end
    
    for i, space in ipairs(screenSpaces) do
        if space == currentSpace then
            local prevSpace = screenSpaces[i - 1] or screenSpaces[#screenSpaces]
            spaces.gotoSpace(prevSpace)
            break
        end
    end
end)

-- Add window filter at the top of the file
local wf = hs.window.filter

-- Create a filter for the current window
local function createWindowFilter(win)
    return wf.new(win:application():name())
end

-- Move window to next/previous desktop with arrows
hotkey.bind(mashctrl, "right", function()
    print("\n=== Attempting to move window to next desktop ===")
    local win = hs.window.focusedWindow()
    if not win then 
        print("ERROR: No focused window found")
        return 
    end
    
    local app = win:application()
    if not app then 
        print("ERROR: No application found for window")
        return 
    end
    
    print("Window Info:")
    print("- Title: " .. win:title())
    print("- ID: " .. win:id())
    print("- Frame: " .. hs.inspect(win:frame()))
    print("- Is Full Screen: " .. tostring(win:isFullScreen()))
    print("\nApplication Info:")
    print("- Name: " .. app:name())
    print("- Bundle ID: " .. app:bundleID())
    print("- Process ID: " .. app:pid())
    
    -- Get all spaces
    local allSpaces = spaces.allSpaces()
    print("All spaces: " .. hs.inspect(allSpaces))
    
    -- Get the first screen ID from allSpaces since that's what we have
    local screenId = next(allSpaces)
    print("Using screen ID: " .. screenId)
    
    local screenSpaces = allSpaces[screenId]
    print("Spaces for current screen: " .. hs.inspect(screenSpaces))
    
    if not screenSpaces then
        print("ERROR: No spaces found")
        return
    end
    
    -- Find the next space
    local currentSpace = spaces.focusedSpace()
    print("Current space: " .. tostring(currentSpace))
    
    local nextSpace = nil
    for i, space in ipairs(screenSpaces) do
        if space == currentSpace then
            nextSpace = screenSpaces[i + 1] or screenSpaces[1]
            break
        end
    end
    
    if not nextSpace then
        print("ERROR: Could not find next space")
        return
    end
    
    print("Moving to space: " .. tostring(nextSpace))
    
    -- Try to move the window using hs.spaces methods
    print("Attempting to move window using hs.spaces methods...")
    
    -- First try moving the window using its ID
    print("Attempting to move window with ID: " .. win:id())
    local success = spaces.moveWindowToSpace(win:id(), nextSpace, true)
    print("Move result with window ID: " .. tostring(success))
    
    if not success then
        -- If that fails, try moving the window using its process ID
        print("Attempting to move window with process ID: " .. app:pid())
        success = spaces.moveWindowToSpace(app:pid(), nextSpace, true)
        print("Move result with process ID: " .. tostring(success))
    end
    
    -- Move to the new space
    print("Moving to new space...")
    spaces.gotoSpace(nextSpace)
    
    -- Wait a moment and then check if the window is visible
    hs.timer.doAfter(0.5, function()
        local visibleWindows = app:allWindows()
        print("\nChecking window visibility after move:")
        for _, w in ipairs(visibleWindows) do
            print("- Window visible: " .. w:title() .. " (ID: " .. w:id() .. ")")
            print("  - Is Full Screen: " .. tostring(w:isFullScreen()))
            print("  - Frame: " .. hs.inspect(w:frame()))
            print("  - Screen: " .. w:screen():name())
        end
    end)
    
    print("=== Window move operation complete ===\n")
end)

hotkey.bind(mashctrl, "left", function()
    print("\n=== Attempting to move window to previous desktop ===")
    local win = hs.window.focusedWindow()
    if not win then 
        print("ERROR: No focused window found")
        return 
    end
    
    local app = win:application()
    if not app then 
        print("ERROR: No application found for window")
        return 
    end
    
    print("Window Info:")
    print("- Title: " .. win:title())
    print("- ID: " .. win:id())
    print("- Frame: " .. hs.inspect(win:frame()))
    print("- Is Full Screen: " .. tostring(win:isFullScreen()))
    print("\nApplication Info:")
    print("- Name: " .. app:name())
    print("- Bundle ID: " .. app:bundleID())
    print("- Process ID: " .. app:pid())
    
    -- Get all spaces
    local allSpaces = spaces.allSpaces()
    print("All spaces: " .. hs.inspect(allSpaces))
    
    -- Get the first screen ID from allSpaces since that's what we have
    local screenId = next(allSpaces)
    print("Using screen ID: " .. screenId)
    
    local screenSpaces = allSpaces[screenId]
    print("Spaces for current screen: " .. hs.inspect(screenSpaces))
    
    if not screenSpaces then
        print("ERROR: No spaces found")
        return
    end
    
    -- Find the previous space
    local currentSpace = spaces.focusedSpace()
    print("Current space: " .. tostring(currentSpace))
    
    local prevSpace = nil
    for i, space in ipairs(screenSpaces) do
        if space == currentSpace then
            prevSpace = screenSpaces[i - 1] or screenSpaces[#screenSpaces]
            break
        end
    end
    
    if not prevSpace then
        print("ERROR: Could not find previous space")
        return
    end
    
    print("Moving to space: " .. tostring(prevSpace))
    
    -- Try to move the window using hs.spaces methods
    print("Attempting to move window using hs.spaces methods...")
    
    -- First try moving the window using its ID
    print("Attempting to move window with ID: " .. win:id())
    local success = spaces.moveWindowToSpace(win:id(), prevSpace, true)
    print("Move result with window ID: " .. tostring(success))
    
    if not success then
        -- If that fails, try moving the window using its process ID
        print("Attempting to move window with process ID: " .. app:pid())
        success = spaces.moveWindowToSpace(app:pid(), prevSpace, true)
        print("Move result with process ID: " .. tostring(success))
    end
    
    -- Move to the new space
    print("Moving to new space...")
    spaces.gotoSpace(prevSpace)
    
    -- Wait a moment and then check if the window is visible
    hs.timer.doAfter(0.5, function()
        local visibleWindows = app:allWindows()
        print("\nChecking window visibility after move:")
        for _, w in ipairs(visibleWindows) do
            print("- Window visible: " .. w:title() .. " (ID: " .. w:id() .. ")")
            print("  - Is Full Screen: " .. tostring(w:isFullScreen()))
            print("  - Frame: " .. hs.inspect(w:frame()))
            print("  - Screen: " .. w:screen():name())
        end
    end)
    
    print("=== Window move operation complete ===\n")
end)

--
-- Monitor and reload config when required
--
function reload_config(files)
	caffeine:delete()
	hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Config loaded")

-- /Monitor and reload config when required
-- ----------------------------------------------------------------------- --                         ** Something Global **                       --
-- -----------------------------------------------------------------------
-- Comment out this following line if you wish to see animations
local windowMeta = {}
hs.window.animationDuration = 0

module = {}

-- Set screen watcher, in case you connect a new monitor, or unplug a monitor
screens = {}
screenArr = {}
local screenwatcher = hs.screen.watcher.new(function()
	screens = hs.screen.allScreens()
end)
screenwatcher:start()

-- Construct list of screens
indexDiff = 0
for index = 1, #hs.screen.allScreens() do
	local xIndex, yIndex = hs.screen.allScreens()[index]:position()
	screenArr[xIndex] = hs.screen.allScreens()[index]
end

-- Find lowest screen index, save to indexDiff if negative
hs.fnutils.each(screenArr, function(e)
	local currentIndex = hs.fnutils.indexOf(screenArr, e)
	if currentIndex < 0 and currentIndex < indexDiff then
		indexDiff = currentIndex
	end
end)

-- Set screen grid depending on resolution
-- TODO: set grid according to pixels
for _index, screen in pairs(hs.screen.allScreens()) do
	if screen:frame().w / screen:frame().h > 2 then
		-- 10 * 4 for ultra wide screen
		grid.setGrid("10 * 4", screen)
	else
		if screen:frame().w < screen:frame().h then
			-- 4 * 8 for vertically aligned screen
			grid.setGrid("4 * 8", screen)
		else
			-- 8 * 4 for normal screen
			grid.setGrid("8 * 4", screen)
		end
	end
end

-- Some constructors, just for programming
function Cell(x, y, w, h)
	return hs.geometry(x, y, w, h)
end

-- Bind new method to windowMeta
function windowMeta.new()
	local self = setmetatable(windowMeta, {
		-- Treate table like a function
		-- Event listener when windowMeta() is called
		__call = function(cls, ...)
			return cls.new(...)
		end,
	})

	self.window = window.frontmostWindow()
	self.screen = window.frontmostWindow():screen()
	self.windowGrid = grid.get(self.window)
	self.screenGrid = grid.getGrid(self.screen)

	return self
end

-- -----------------------------------------------------------------------
--                   ** ALERT: GEEKS ONLY, GLHF  :C **                  --
--            ** Keybinding configurations locate at bottom **          --
-- -----------------------------------------------------------------------

module.maximizeWindow = function()
	local this = windowMeta.new()
	hs.grid.maximizeWindow(this.window)
end

module.centerOnScreen = function()
	local this = windowMeta.new()
	this.window:centerOnScreen(this.screen)
end

module.throwLeft = function()
	local this = windowMeta.new()
	this.window:moveOneScreenWest()
end

module.throwRight = function()
	local this = windowMeta.new()
	this.window:moveOneScreenEast()
end

module.leftHalf = function()
	local this = windowMeta.new()
	local cell = Cell(0, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)
	grid.set(this.window, cell, this.screen)
	this.window.setShadows(true)
end

module.rightHalf = function()
	local this = windowMeta.new()
	local cell = Cell(0.5 * this.screenGrid.w, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)
	grid.set(this.window, cell, this.screen)
end
--
module.topHalf = function()
	local this = windowMeta.new()
	local cell = Cell(0, 0, this.screenGrid.w, this.screenGrid.h * 0.5)
	print(this.screenGrid)
	grid.set(this.window, cell, this.screen)
	this.window.setShadows(true)
end

module.bottomHalf = function()
	local this = windowMeta.new()
	local cell = Cell(0, this.screenGrid.h * 0.5, this.screenGrid.w, this.screenGrid.h * 0.5)
	print(cell)
	grid.set(this.window, cell, this.screen)
end

--
module.topLeftQuarter = function()
	local this = windowMeta.new()
	local cell = Cell(0, 0, 0.5 * this.screenGrid.w, this.screenGrid.h * 0.5)
	print(cell)
	grid.set(this.window, cell, this.screen)
end

module.topRightQuarter = function()
	local this = windowMeta.new()
	local cell = Cell(0.5 * this.screenGrid.w, 0, 0.5 * this.screenGrid.w, this.screenGrid.h * 0.5)
	print(cell)
	grid.set(this.window, cell, this.screen)
end

module.bottomLeftQuarter = function()
	local this = windowMeta.new()
	local cell = Cell(0, this.screenGrid.h * 0.5, this.screenGrid.w * 0.5, this.screenGrid.h * 0.5)
	print(cell)
	grid.set(this.window, cell, this.screen)
end

module.bottomRightQuarter = function()
	local this = windowMeta.new()
	local cell =
		Cell(this.screenGrid.w * 0.5, this.screenGrid.h * 0.5, this.screenGrid.w * 0.5, this.screenGrid.h * 0.5)
	print(cell)
	grid.set(this.window, cell, this.screen)
end

-- Function to move window to specific space
local function moveWindowToSpace(spaceIndex)
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local cur_screen = hs.screen.mainScreen()
    local cur_screen_id = cur_screen:id()
    local all_spaces = spaces.allSpaces()
    local screenSpaces = all_spaces[cur_screen_id]
    
    if not screenSpaces or not screenSpaces[spaceIndex] then return end
    
    local spaceID = screenSpaces[spaceIndex]
    spaces.moveWindowToSpace(win:id(), spaceID)
    spaces.gotoSpace(cur_screen, spaceID)
end

-- Bind number keys to move windows to spaces
for i = 1, 9 do
    hotkey.bind(mash, tostring(i), function()
        moveWindowToSpace(i)
    end)
end
