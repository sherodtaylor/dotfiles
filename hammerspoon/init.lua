local application = require "hs.application"
local fnutils = require "hs.fnutils"
local grid = require "hs.grid"
local hotkey = require "hs.hotkey"
local mjomatic = require "hs.mjomatic"
local window = require "hs.window"

grid.MARGINX = 0
grid.MARGINY = 0
grid.GRIDHEIGHT = 12
grid.GRIDWIDTH = 12

local mash = {"cmd", "alt"}
local mashctrl = {"cmd", "alt", "ctrl"}

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

hs.hotkey.bind(mash, "/", function() caffeineClicked() end)
--
-- /replace caffeine
--


--
-- toggle push window to edge and restore to screen
--

-- somewhere to store the original position of moved windows
local origWindowPos = {}

-- cleanup the original position when window restored or closed
local function cleanupWindowPos(_,_,_,id)
  origWindowPos[id] = nil
end

-- function to move a window to edge or back
local function movewin(direction)
  local win = hs.window.focusedWindow()
  local res = hs.screen.mainScreen():frame()
  local id = win:id()

  if not origWindowPos[id] then
    -- move the window to edge if no original position is stored in
    -- origWindowPos for this window id
    local f = win:frame()
    origWindowPos[id] = win:frame()

    -- add a watcher so we can clean the origWindowPos if window is closed
    local watcher = win:newWatcher(cleanupWindowPos, id)
    watcher:start({hs.uielement.watcher.elementDestroyed})

    if direction == "left" then f.x = (res.w - (res.w * 2)) + 10 end
    if direction == "right" then f.x = (res.w + res.w) - 10 end
    if direction == "down" then f.y = (res.h + res.h) - 10 end
    win:setFrame(f)
  else
    -- restore the window if there is a value for origWindowPos
    win:setFrame(origWindowPos[id])
    -- and clear the origWindowPos value
    cleanupWindowPos(_,_,_,id)
  end
end

hs.hotkey.bind(mash, "A", function() movewin("left") end)
hs.hotkey.bind(mash, "D", function() movewin("right") end)
hs.hotkey.bind(mash, "S", function() movewin("down") end)
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

hotkey.bind(mash, 'F', openff)
hotkey.bind(mash, 'C', openchrome)
hotkey.bind(mash, 'M', openmail)
--
--
-- Window management
--
--Alter gridsize
hotkey.bind(mashctrl, '=', function() grid.adjustHeight( 1) end)
hotkey.bind(mashctrl, '-', function() grid.adjustHeight(-1) end)
hotkey.bind(mash, '=', function() grid.adjustWidth( 1) end)
hotkey.bind(mash, '-', function() grid.adjustWidth(-1) end)

--Snap windows
hotkey.bind(mash, ';', function() module.leftHalf() end)
hotkey.bind(mash, "'", function() module.rightHalf() end)
hotkey.bind(mashctrl, ';', function() module.topHalf() end)
hotkey.bind(mashctrl, "'", function() module.bottomHalf() end)

hotkey.bind(mashctrl, 'H', function() window.focusedWindow():focusWindowWest() end)
hotkey.bind(mashctrl, 'L', function() window.focusedWindow():focusWindowEast() end)
hotkey.bind(mashctrl, 'K', function() window.focusedWindow():focusWindowNorth() end)
hotkey.bind(mashctrl, 'J', function() window.focusedWindow():focusWindowSouth() end)

--Move windows
hotkey.bind(mash, 'J', grid.pushWindowDown)
hotkey.bind(mash, 'K', grid.pushWindowUp)
hotkey.bind(mash, 'H', grid.pushWindowLeft)
hotkey.bind(mash, 'L', grid.pushWindowRight)

--resize windows
hotkey.bind(mash, 'U', grid.resizeWindowTaller)
hotkey.bind(mash, 'O', grid.resizeWindowWider)
hotkey.bind(mash, 'I', grid.resizeWindowThinner)
hotkey.bind(mash, 'Y', grid.resizeWindowShorter)

hotkey.bind(mash, 'N', grid.pushWindowNextScreen)
hotkey.bind(mash, 'P', grid.pushWindowPrevScreen)

hotkey.bind(mash, 'M', grid.maximizeWindow)
hotkey.bind(mashctrl, 'M', grid.maximizeWindow)


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
for index=1,#hs.screen.allScreens() do
  local xIndex,yIndex = hs.screen.allScreens()[index]:position()
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
for _index,screen in pairs(hs.screen.allScreens()) do
  if screen:frame().w / screen:frame().h > 2 then
    -- 10 * 4 for ultra wide screen
    grid.setGrid('10 * 4', screen)
  else
    if screen:frame().w < screen:frame().h then
      -- 4 * 8 for vertically aligned screen
      grid.setGrid('4 * 8', screen)
    else
      -- 8 * 4 for normal screen
      grid.setGrid('8 * 4', screen)
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
    __call = function (cls, ...)
      return cls.new(...)
    end,
  })
  
  self.window = window.focusedWindow()
  self.screen = window.focusedWindow():screen()
  self.windowGrid = grid.get(self.window)
  self.screenGrid = grid.getGrid(self.screen)
  
  return self
end

-- -----------------------------------------------------------------------
--                   ** ALERT: GEEKS ONLY, GLHF  :C **                  --
--            ** Keybinding configurations locate at bottom **          --
-- -----------------------------------------------------------------------

module.maximizeWindow = function ()
  local this = windowMeta.new()
  hs.grid.maximizeWindow(this.window)
end

module.centerOnScreen = function ()
  local this = windowMeta.new()
  this.window:centerOnScreen(this.screen)
end

module.throwLeft = function ()
  local this = windowMeta.new()
  this.window:moveOneScreenWest()
end

module.throwRight = function ()
  local this = windowMeta.new()
  this.window:moveOneScreenEast()
end

module.leftHalf = function ()
  local this = windowMeta.new()
  local cell = Cell(0, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
  this.window.setShadows(true)
end

module.rightHalf = function ()
  local this = windowMeta.new()
  local cell = Cell(0.5 * this.screenGrid.w, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
end
--
module.topHalf = function ()
  local this = windowMeta.new()
  local cell = Cell(0, 0, this.screenGrid.w, this.screenGrid.h * 0.5)
  print(this.screenGrid)
  grid.set(this.window, cell, this.screen)
  this.window.setShadows(true)
end

module.bottomHalf = function ()
  local this = windowMeta.new()
  local cell = Cell(0, this.screenGrid.h * 0.5, this.screenGrid.w, this.screenGrid.h * 0.5)
  print(cell)
  grid.set(this.window, cell, this.screen)
end
--
