---@class DynamicGroupLayout : AceAddon, AceConsole-3.0, AceEvent-3.0, AceHook-3.0
local DynamicGroupLayout = LibStub("AceAddon-3.0"):NewAddon("DynamicGroupLayout", "AceConsole-3.0", "AceEvent-3.0",
    "AceHook-3.0")

--------------------------------------------------------------------------------
-- Modules
--------------------------------------------------------------------------------

---@class Layouts : AceModule
local Layouts = DynamicGroupLayout:NewModule("Layouts")


--------------------------------------------------------------------------------
-- DynamicGroupLayout
--------------------------------------------------------------------------------


local options = {
    name = "DynamicGroupLayout",
    handler = DynamicGroupLayout,
    type = "group",
    args = {

        general = {
            name = "General",
            type = "group",
            order = 1,
            args = {

                layoutsModule = {
                    name = "Enable Auto Layouts",
                    type = "toggle",
                    width = "full",
                    order = 1,
                    get = function()
                        return DynamicGroupLayout:GetOption("layoutsModule")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("layoutsModule", value)
                        ReloadUI()
                    end,
                    confirm = "ConfirmReload"
                },

                notify = {
                    name = "Notify layout changes",
                    type = "toggle",
                    width = "full",
                    order = 2,
                    get = function()
                        return DynamicGroupLayout:GetOption("notify")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("notify", value)
                    end
                },
            },
        },

        pve = {
            name = "PvE Layouts",
            type = "group",
            order = 2,
            args = {

                group5Layout = {
                    name = "Party Layout",
                    type = "select",
                    width = "full",
                    order = 1,
                    handler = Layouts,
                    values = "List",
                    style = "dropdown",
                    get = function()
                        return DynamicGroupLayout:GetOption("group5Layout")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("group5Layout", value)
                    end
                },

                group10Layout = {
                    name = "Raid Layout (10)",
                    type = "select",
                    width = "full",
                    order = 2,
                    handler = Layouts,
                    values = "List",
                    style = "dropdown",
                    get = function()
                        return DynamicGroupLayout:GetOption("group10Layout")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("group10Layout", value)
                    end
                },

                group25Layout = {
                    name = "Raid Layout (25)",
                    type = "select",
                    width = "full",
                    order = 3,
                    handler = Layouts,
                    values = "List",
                    style = "dropdown",
                    get = function()
                        return DynamicGroupLayout:GetOption("group25Layout")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("group25Layout", value)
                    end
                },

                group40Layout = {
                    name = "Raid Layout (40)",
                    type = "select",
                    width = "full",
                    order = 4,
                    handler = Layouts,
                    values = "List",
                    style = "dropdown",
                    get = function()
                        return DynamicGroupLayout:GetOption("group40Layout")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("group40Layout", value)
                    end
                },
            },
        },

        pvp = {
            name = "PvP Layouts",
            type = "group",
            order = 3,
            args = {

                arenaLayout = {
                    name = "Arena Layout",
                    type = "select",
                    width = "full",
                    order = 1,
                    handler = Layouts,
                    values = "List",
                    style = "dropdown",
                    get = function()
                        return DynamicGroupLayout:GetOption("arenaLayout")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("arenaLayout", value)
                    end
                },

                bg10Layout = {
                    name = "BG Layout (10)",
                    type = "select",
                    width = "full",
                    order = 2,
                    handler = Layouts,
                    values = "List",
                    style = "dropdown",
                    get = function()
                        return DynamicGroupLayout:GetOption("bg10Layout")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("bg10Layout", value)
                    end
                },

                bg15Layout = {
                    name = "BG Layout (15)",
                    type = "select",
                    width = "full",
                    order = 3,
                    handler = Layouts,
                    values = "List",
                    style = "dropdown",
                    get = function()
                        return DynamicGroupLayout:GetOption("bg15Layout")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("bg15Layout", value)
                    end
                },

                epicBGLayout = {
                    name = "Epic BG Layout (35–40)",
                    type = "select",
                    width = "full",
                    order = 4,
                    handler = Layouts,
                    values = "List",
                    style = "dropdown",
                    get = function()
                        return DynamicGroupLayout:GetOption("epicBGLayout")
                    end,
                    set = function(info, value)
                        DynamicGroupLayout:SetOption("epicBGLayout", value)
                    end
                },
            },
        },
    },
}



local defaults = {
    profile = {
        -- Layouts Module
        layoutsModule = true,
        group5Layout = 0,
        group10Layout = 0,
        group25Layout = 0,
        group40Layout = 0,
        arenaLayout = 0,
        bg10Layout = 0,
        bg15Layout = 0,
        epicBGLayout = 0,
        notify = true
    }
}

function DynamicGroupLayout:OnInitialize()
    self.database = LibStub("AceDB-3.0"):New("DGLDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("DynamicGroupLayout", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicGroupLayout", "DynamicGroupLayout")

    self.events = {}
    self.locked = false
    self.lockedFrames = {}
    self.protectedFrames = {}

    EventRegistry:RegisterCallback("EditMode.Enter", function()
        EventRegistry:TriggerEvent("DynamicGroupLayout.Lock")
        DynamicGroupLayout:Lock()
    end)
    EventRegistry:RegisterCallback("EditMode.Exit", function()
        DynamicGroupLayout:Unlock()
        EventRegistry:TriggerEvent("DynamicGroupLayout.Unlock")
    end)
end

function DynamicGroupLayout:OnEnable()
    if self:GetOption("layoutsModule") then
        Layouts:Enable()
    end
    for event in pairs(self.events) do
        self:RegisterEvent(event, "OnEvent")
    end
end

function DynamicGroupLayout:OnDisable()
end

function DynamicGroupLayout:OnEvent(event, ...)
    if self.events[event] then
        for _, callback in ipairs(self.events[event]) do
            callback(event, ...)
        end
    end
end

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

function DynamicGroupLayout:ConfirmReload()
    return "This action will reload the UI"
end

function DynamicGroupLayout:Event(event, callback)
    if not self.events[event] then
        self.events[event] = {}
    end

    table.insert(self.events[event], callback)
end

function DynamicGroupLayout:SetOption(key, value)
    self.database.profile[key] = value
end

function DynamicGroupLayout:GetOption(key)
    return self.database.profile[key]
end

function DynamicGroupLayout:Protect(Frame)
    self.protectedFrames[Frame] = true
end

function DynamicGroupLayout:Lock(Frame)
    if Frame then
        self.lockedFrames[Frame] = true
    else
        self.locked = true
    end
end

function DynamicGroupLayout:Unlock(Frame)
    if Frame then
        self.lockedFrames[Frame] = false
    else
        self.locked = false
    end
end

function DynamicGroupLayout:OnLock(callback)
    EventRegistry:RegisterCallback("DynamicGroupLayout.Lock", callback)
end

function DynamicGroupLayout:OnUnlock(callback)
    EventRegistry:RegisterCallback("DynamicGroupLayout.Unlock", callback)
end

function DynamicGroupLayout:IsLocked(Frame)
    if Frame then
        local isProtected, isProtectedExplicitly = Frame:IsProtected()

        if isProtected and InCombatLockdown() then
            return true
        elseif isProtectedExplicitly and InCombatLockdown() then
            return true
        elseif self.protectedFrames[Frame] and InCombatLockdown() then
            return self.protectedFrames[Frame]
        elseif self.lockedFrames[Frame] then
            return self.lockedFrames[Frame]
        end

        return self.locked
    end

    return self.locked
end

function DynamicGroupLayout:Register(Frame, state, condition)
    if not DynamicGroupLayout:IsLocked(Frame) then
        RegisterAttributeDriver(Frame, "state-" .. state, condition)
    end
end

function DynamicGroupLayout:Unregister(Frame, state)
    if not self:IsLocked(Frame) then
        UnregisterAttributeDriver(Frame, "state-" .. state)
    end
end

function DynamicGroupLayout:FadeIn(Frame, alpha, callback, ...)
    if not DynamicGroupLayout:IsLocked(Frame) then
        local settings = {}

        settings.finishedFunc = callback
        settings.finishedArg1, settings.finishedArg2, settings.finishedArg3, settings.finishedArg4 = ...

        settings.mode = "IN"
        settings.timeToFade = 0
        settings.startAlpha = Frame:GetAlpha()
        settings.endAlpha = alpha or 1

        UIFrameFade(Frame, settings)
    end
end

function DynamicGroupLayout:FadeOut(Frame, alpha, callback, ...)
    if not self:IsLocked(Frame) then
        local settings = {}

        settings.finishedFunc = callback
        settings.finishedArg1, settings.finishedArg2, settings.finishedArg3, settings.finishedArg4 = ...

        settings.mode = "OUT"
        settings.timeToFade = 0
        settings.startAlpha = Frame:GetAlpha()
        settings.endAlpha = alpha or 0

        UIFrameFade(Frame, settings)
    end
end

function DynamicGroupLayout:HasRoot(Frame, root)
    if Frame and Frame:GetName() == root then
        return true
    elseif Frame and Frame:GetParent() then
        return self:HasRoot(Frame:GetParent(), root)
    end

    return false
end

function DynamicGroupLayout:OnLeave(root, callback, ...)
    -- The returned table will contain multiple regions in the case where objects at the top of the stack are configured for mouse input propagation.
    -- The order of results in the table is such that the topmost region will be at index 1, and the bottommost region will be at the last index in the table.
    local focusRegions = GetMouseFoci()
    local focus = focusRegions[1]

    if not self:HasRoot(focus, root) then
        callback(...)
    end
end

function DynamicGroupLayout:HasTarget()
    return UnitExists("target")
end

--------------------------------------------------------------------------------
-- Layouts
--------------------------------------------------------------------------------

Layouts.throttleTime = 0.5
Layouts.lastChange = 0

function Layouts:CanChange()
    local now = GetTime()
    if now - self.lastChange < self.throttleTime then
        return false
    end
    self.lastChange = now
    return true
end

function Layouts:Notify(layout)
    if not DynamicGroupLayout:GetOption("notify") then
        return
    end

    local info = self.layouts.layouts[layout]
    local name = info and info.layoutName or "Unknown Layout"

    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff00ffccDynamicGroupLayout|r: Layout changed to |cffffff00" .. name .. "|r"
    )
end

function Layouts:Enable()
    Layouts:Update()

    DynamicGroupLayout:Event("PLAYER_ENTERING_WORLD", function(event, ...)
        Layouts:Evaluate(event, ...)
    end)

    DynamicGroupLayout:Event("GROUP_ROSTER_UPDATE", function(event, ...)
        Layouts:Evaluate(event, ...)
    end)

    DynamicGroupLayout:OnLock(function()
        Layouts:Evaluate("OnLock")
    end)
    DynamicGroupLayout:OnUnlock(function()
        Layouts:Update()
        Layouts:Evaluate()
    end)
end

function Layouts:Update()
    self.layouts = self:Get()
    self.activeLayout = self:GetActive()

    if self.activeLayout ~= self.defaultLayout then
        self.defaultLayout = self.activeLayout
    end

    self.group5Layout = DynamicGroupLayout:GetOption("group5Layout")
    self.group10Layout = DynamicGroupLayout:GetOption("group10Layout")
    self.group25Layout = DynamicGroupLayout:GetOption("group25Layout")
    self.group40Layout = DynamicGroupLayout:GetOption("group40Layout")
    self.arenaLayout = DynamicGroupLayout:GetOption("arenaLayout")
    self.bg10Layout = DynamicGroupLayout:GetOption("bg10Layout")
    self.bg15Layout = DynamicGroupLayout:GetOption("bg15Layout")
    self.epicBGLayout = DynamicGroupLayout:GetOption("epicBGLayout")
end

function Layouts:Activate(layout)
    if layout == self.activeLayout then
        return
    end

    if self:Has(layout) then
        C_EditMode.SetActiveLayout(layout)
        self.activeLayout = layout
        self:Notify(layout)
    end
end

function Layouts:Get()
    local layouts = C_EditMode.GetLayouts()
    local presetLayouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts()

    tAppendAll(presetLayouts, layouts.layouts)

    layouts.layouts = presetLayouts

    return layouts
end

function Layouts:GetActive()
    return self.layouts.activeLayout
end

function Layouts:Has(layout)
    if self.layouts.layouts[layout] then
        return true
    end

    return false
end

function Layouts:List()
    local layouts = {}
    layouts[0] = ""

    for index, layout in pairs(self:Get().layouts) do
        layouts[index] = layout.layoutName
    end

    return layouts
end

function Layouts:Evaluate(event, ...)
    local inInstance, instanceType = IsInInstance()
    local members = GetNumGroupMembers()
    local isRaid = IsInRaid()
    local isGroup = IsInGroup()

    if not self:CanChange() then
        return
    end
    local newLayout = self.defaultLayout

    -- Arena
    if inInstance and instanceType == "arena" then
        if self.arenaLayout ~= 0 and self:Has(self.arenaLayout) then
            newLayout = self.arenaLayout
        end

        -- Battlegrounds
    elseif inInstance and instanceType == "pvp" then
        if members <= 10 and self.bg10Layout ~= 0 then
            newLayout = self.bg10Layout
        elseif members <= 15 and self.bg15Layout ~= 0 then
            newLayout = self.bg15Layout
        elseif members >= 35 and self.epicBGLayout ~= 0 then
            newLayout = self.epicBGLayout
        end

        -- World / PvE
    elseif isGroup and not isRaid then
        if self.group5Layout ~= 0 then
            newLayout = self.group5Layout
        end
    elseif isRaid then
        if members <= 10 and self.group10Layout ~= 0 then
            newLayout = self.group10Layout
        elseif members <= 25 and self.group25Layout ~= 0 then
            newLayout = self.group25Layout
        elseif members <= 40 and self.group40Layout ~= 0 then
            newLayout = self.group40Layout
        end
    end

    if event == "OnLock" then
        newLayout = self.defaultLayout
    end

    if newLayout ~= self.activeLayout then
        self:Activate(newLayout)
    end
end
