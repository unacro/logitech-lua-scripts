-- Logitech G HUB - Lua Script
-- Auto Clicker
-- Test URL: https://cps-check.com/cn/mouse-buttons-test
-- Common Global Constants
MOUSE_EVENT = {
    -- OnEvent() arg
    LMB = 1, -- Left Mouse Button 左键 (主键) 监听需要启用函数 EnablePrimaryMouseButtonEvents(true)
    RMB = 2, -- Right Mouse Button 右键 (次键)
    MMB = 3, -- Middle Mouse Button 中键
    XB1 = 4, -- X1 Mouse Button 侧键 X1 (后退)
    XB2 = 5 -- X2 Mouse Button 侧键 X2 (前进)
}

MOUSE_BUTTON = {
    -- PressMouseButton() / ReleaseMouseButton() / PressAndReleaseMouseButton() / IsMouseButtonPressed()
    LMB = 1, -- Left Mouse Button 左键 (主键)
    MMB = 2, -- Middle Mouse Button 中键
    RMB = 3, -- Right Mouse Button 右键 (次键)
    XB1 = 4, -- X1 Mouse Button 侧键 X1 (后退)
    XB2 = 5 -- X2 Mouse Button 侧键 X2 (前进)
}

-- Common Utils Class
Utils = {
    scriptName = "Auto Clicker",
    scriptAuthor = "unacro <po@ews.ink>",
    scriptVersion = "nil",
    debugMode = false,
    useMacro = false,
    macroName = {
        bySwitch = "开关自动点击",
        byPress = "按住自动点击"
    },
    macroState = false
}

function Utils:new(obj, ver)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    ver = ver or "unknown"
    self.scriptVersion = ver
    self.now = function(timeFormat)
        timeFormat = timeFormat or "%Y-%m-%d %H:%M:%S"
        return GetDate(timeFormat)
    end
    self.logPrefix = function(level)
        level = type(level) == "string" and level or "info"
        -- return "[" .. self.now() .. "] "
        return self.now() .. " | " .. string.upper(level) .. " | "
    end
    self.logSuffix = function()
        return "\n"
    end
    self.log = function(logString)
        logString = logString or "this is a empty log"
        OutputLogMessage(self.logPrefix() .. logString .. self.logSuffix())
    end
    self.debug = function(logString)
        logString = logString or "this is a empty debug log"
        OutputLogMessage(self.logPrefix("debug") .. logString .. self.logSuffix())
    end
    self.startMacro = function()
        PlayMacro(self.macroName.bySwitch)
        self.log("Script enabled.")
        return true
    end
    self.stopMacro = function(disabled)
        disabled = disabled == true and true or false
        AbortMacro()
        self.log("Script disabled." .. (disabled and " (reason: Scroll Lock is off" .. ")" or ""))
        return true
    end
    OutputLogMessage("Utils initialized.")
    return obj
end

utils = Utils:new(nil, "0.9.1")

-- Main Function
function OnEvent(event, arg, family)
    -- utils.debugMode = true
    utils.useMacro = true
    if (event == "PROFILE_ACTIVATED") then
        ClearLog()
        utils.log("Logitech G HUB - Lua Script [" .. utils.scriptName .. "] loaded. (Current version: v" ..
                      utils.scriptVersion .. ")")
    elseif (utils.debugMode and event == "MOUSE_BUTTON_PRESSED") then
        local eventInfo = {'Event: "' .. event .. '"', 'Arg: "' .. arg .. '"', 'Family: "' .. family .. '"'}
        -- Family: kb - keyboard devices / lhc - left-handed controllers / mouse - gaming mouse
        utils.debug(table.concat(eventInfo, "    "))
    end

    if (utils.useMacro) then
        if (IsKeyLockOn("scrolllock")) then
            -- utils.debug("scrolllock on")
            if (event == "MOUSE_BUTTON_PRESSED" and arg == MOUSE_EVENT.XB2) then
                if (IsModifierPressed("alt")) then
                    utils.debug("pressed alt, do something")
                elseif (IsModifierPressed("shift")) then
                    -- utils.debug("pressed shift, do something")
                    PressMouseButton(MOUSE_BUTTON.LMB)
                    -- ReleaseMouseButton(MOUSE_BUTTON.LMB)
                elseif (IsModifierPressed("ctrl")) then
                    utils.debug("pressed ctrl, do something")
                else
                    utils.macroState = not utils.macroState
                    if (utils.macroState) then
                        utils.startMacro()
                    else
                        utils.stopMacro()
                    end
                end
            elseif (event == "MOUSE_BUTTON_PRESSED" and arg == MOUSE_EVENT.XB1) then
                PressMacro(utils.macroName.byPress)
                utils.log("Script enabled.")
            elseif (event == "MOUSE_BUTTON_RELEASED" and arg == MOUSE_EVENT.XB1) then
                ReleaseMacro(utils.macroName.byPress)
                utils.log("Script disabled.")
            end
        else
            -- utils.debug("scrolllock off")
            if (event == "MOUSE_BUTTON_PRESSED") then
                ReleaseMacro(utils.macroName.byPress)
                utils.stopMacro(true)
                if (arg == MOUSE_EVENT.XB2) then
                    -- PressAndReleaseMouseButton(MOUSE_BUTTON.XB2)
                    PressMouseButton(MOUSE_BUTTON.XB2)
                elseif (arg == MOUSE_EVENT.XB1) then
                    -- PressAndReleaseMouseButton(MOUSE_BUTTON.XB1)
                    PressMouseButton(MOUSE_BUTTON.XB1)
                end
            elseif (event == "MOUSE_BUTTON_RELEASED") then
                if (arg == MOUSE_EVENT.XB2) then
                    ReleaseMouseButton(MOUSE_BUTTON.XB2)
                elseif (arg == MOUSE_EVENT.XB1) then
                    ReleaseMouseButton(MOUSE_BUTTON.XB1)
                end
            end
        end
    else
        if (IsKeyLockOn("scrolllock")) then
            local tempMouseEvent = MOUSE_EVENT.XB1
            local tempMouseButton = MOUSE_BUTTON.XB1
            if (event == "MOUSE_BUTTON_PRESSED" and arg == tempMouseEvent) then
                -- utils.debug("Random number [20, 150]: " .. math.random(20, 150))

                utils.debug("Button[" .. tempMouseEvent .. "] state: " ..
                                (IsMouseButtonPressed(tempMouseButton) and "pressed" or "not pressed")) -- debug: not work, always be `not pressed`
                -- 无论物理按键状态还是模拟按键状态都监听不到
                PressMouseButton(MOUSE_BUTTON.RMB)
                if (IsMouseButtonPressed(MOUSE_BUTTON.RMB)) then
                    utils.debug("Right Mouse Button state: pressed")
                else
                    utils.debug("Right Mouse Button state: NOT pressed")
                end
                ReleaseMouseButton(MOUSE_BUTTON.RMB)

                while (IsMouseButtonPressed(tempMouseButton)) do
                    utils.debug("exec click by while loop")
                    PressAndReleaseMouseButton(MOUSE_BUTTON.LMB)

                    -- PressMouseButton(MOUSE_BUTTON.LMB)
                    -- Sleep(math.random(20, 30))
                    -- ReleaseMouseButton(MOUSE_BUTTON.LMB)

                    Sleep(math.random(40, 60))
                end

                if (IsMouseButtonPressed(tempMouseButton)) then
                    utils.log("Script enabled.")
                    repeat
                        utils.debug("exec click by repeat loop") -- todo
                    until not IsMouseButtonPressed(tempMouseButton)
                    utils.log("Script disabled.")
                end
            end
        else
            utils.debug("Disable auto click **without macro**: Not Implemented")
        end
    end
end
