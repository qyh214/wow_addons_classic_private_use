local _, MySlot = ...

local L = MySlot.L

local crc32 = LibStub:GetLibrary('CRC32-1.0')
local base64 = LibStub:GetLibrary('BASE64-1.0')

local pblua = LibStub:GetLibrary('pblua')
local _MySlot = pblua.load_proto_ast(MySlot.ast)


local MYSLOT_AUTHOR = "T.G. <farmer1992@gmail.com>"

local MYSLOT_VER = 30
local MYSLOT_ALLOW_VER = {MYSLOT_VER}

-- local MYSLOT_IS_DEBUG = true
local MYSLOT_LINE_SEP = IsWindowsClient() and "\r\n" or "\n"
local MYSLOT_MAX_ACTIONBAR = 120

-- {{{ SLOT TYPE
local MYSLOT_SPELL = _MySlot.Slot.SlotType.SPELL
local MYSLOT_COMPANION = _MySlot.Slot.SlotType.COMPANION
local MYSLOT_ITEM = _MySlot.Slot.SlotType.ITEM
local MYSLOT_MACRO = _MySlot.Slot.SlotType.MACRO
local MYSLOT_FLYOUT = _MySlot.Slot.SlotType.FLYOUT
local MYSLOT_EQUIPMENTSET = _MySlot.Slot.SlotType.EQUIPMENTSET
local MYSLOT_EMPTY = _MySlot.Slot.SlotType.EMPTY
local MYSLOT_SUMMONPET = _MySlot.Slot.SlotType.SUMMONPET
local MYSLOT_SUMMONMOUNT = _MySlot.Slot.SlotType.SUMMONMOUNT
local MYSLOT_NOTFOUND = "notfound"

MySlot.SLOT_TYPE = {
    ["spell"] = MYSLOT_SPELL,
    ["companion"] = MYSLOT_COMPANION,
    ["macro"]= MYSLOT_MACRO,
    ["item"]= MYSLOT_ITEM,
    ["flyout"] = MYSLOT_FLYOUT, 
    ["petaction"] = MYSLOT_EMPTY,
    ["futurespell"] = MYSLOT_EMPTY,
    ["equipmentset"] = MYSLOT_EQUIPMENTSET,
    ["summonpet"] = MYSLOT_SUMMONPET,
    ["summonmount"] = MYSLOT_SUMMONMOUNT,
    [MYSLOT_NOTFOUND] = MYSLOT_EMPTY,
}
-- }}}

local MYSLOT_BIND_CUSTOM_FLAG = 0xFFFF

-- {{{ MergeTable
-- return item count merge into target
local function MergeTable(target, source)
    if source then
        assert(type(target) == 'table' and type(source) == 'table')
        for _,b in ipairs(source) do
            assert(b < 256)
            target[#target+1] = b
        end
        return #source
    else
        return 0
    end
end
-- }}}

-- fix unpack stackoverflow
local function StringToTable(s)
    if type(s) ~= 'string' then
        return {}
    end 
    local r = {}
    for i = 1, string.len(s) do
        r[#r + 1] = string.byte(s, i)
    end
    return r
end

local function TableToString(s)
    if type(s) ~= 'table' then
        return ''
    end 
    local t = {}
    for _,c in pairs(s) do
        t[#t + 1] = string.char(c)
    end
    return table.concat(t)
end

function MySlot:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|CFFFF0000<|r|CFFFFD100Myslot|r|CFFFF0000>|r"..(msg or "nil"))
end

-- {{{ GetMacroInfo
function MySlot:GetMacroInfo(macroId)
    -- {macroId ,icon high 8, icon low 8 , namelen, ..., bodylen, ...}

    local name, iconTexture, body, isLocal = GetMacroInfo(macroId)
    
    if not name then
        return nil
    end

    local t = {macroId} 

    iconTexture = gsub( strupper(iconTexture or "INV_Misc_QuestionMark") , "INTERFACE\\ICONS\\", "");
    
    local msg = _MySlot.Macro()
    
    msg.id = macroId
    msg.icon = iconTexture
    msg.name = name
    msg.body = body

    return msg
end
-- }}}

-- {{{ GetActionInfo
function MySlot:GetActionInfo(slotId)
    -- { slotId, slotType and high 16 ,high 8 , low 8, }
    local slotType, index = GetActionInfo(slotId)
    if MySlot.SLOT_TYPE[slotType] == MYSLOT_EQUIPMENTSET then
        for i = 1, C_EquipmentSet.GetNumEquipmentSets() do
            if C_EquipmentSet.GetEquipmentSetInfo(i) == index then
                index = i
                break
            end
        end
    elseif not MySlot.SLOT_TYPE[slotType] then
        if slotType then 
            self:Print(L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"]:format(slotType , MYSLOT_AUTHOR))
        end
        return nil
    elseif not index then
        return nil
    end

    local msg = _MySlot.Slot()
    msg.id = slotId
    msg.type = MySlot.SLOT_TYPE[slotType]
    if type(index) == 'string' then
        msg.strindex = index
        msg.index = 0
    else
        msg.index = index
    end
    return msg
end

-- }}}

-- {{{ GetBindingInfo
-- {{{ Serialzie Key
local function KeyToByte(key , command)
    -- {mod , key , command high 8, command low 8}
    if not key then
        return nil
    end

    local mod,key = nil, key
    local t = {}
    local _,_,_mod,_key = string.find(key ,"(.+)-(.+)") 
    if _mod and _key then
        mod, key = _mod, _key
    end

    mod = mod or "NONE"

    if not MySlot.MOD_KEYS[mod] then
        MySlot:Print(L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"]:format(mod, MYSLOT_AUTHOR))
        return nil
    end

    local msg = _MySlot.Key()
    if MySlot.KEYS[key] then
        msg.key = MySlot.KEYS[key]
    else
        msg.key = MySlot.KEYS["KEYCODE"]
        msg.keycode = key
    end
    msg.mod = MySlot.MOD_KEYS[mod]

    return msg
end
-- }}}

function MySlot:GetBindingInfo(index)
    -- might more than 1
    local _command, _, key1, key2 = GetBinding(index)

    if not _command then
        return
    end

    local command = MySlot.BINDS[_command]

    local msg = _MySlot.Bind()

    if not command then
        msg.command = _command
        command = MYSLOT_BIND_CUSTOM_FLAG
    end

    msg.id = command

    msg.key1 = KeyToByte(key1)
    msg.key2 = KeyToByte(key2)

    if msg.key1 or msg.key2 then
        return msg
    else
        return nil
    end
end
-- }}}


function MySlot:Export()
    -- ver nop nop nop crc32 crc32 crc32 crc32

    local msg = _MySlot.Charactor()

    msg.ver = MYSLOT_VER
    msg.name = UnitName("player")
    
    msg.macro = {}

    for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        local m = self:GetMacroInfo(i)
        if m then
            msg.macro[#msg.macro + 1] = m
        end
    end

    msg.slot = {}
    for i = 1, MYSLOT_MAX_ACTIONBAR do
        local m = self:GetActionInfo(i)
        if m then
            msg.slot[#msg.slot + 1] = m
        end
    end

    msg.bind = {}
    for i = 1, GetNumBindings() do
        local m = self:GetBindingInfo(i)
        if m then
            msg.bind[#msg.bind + 1] = m
        end
    end

    local ct = msg:Serialize()
    t = {MYSLOT_VER,86,04,22,0,0,0,0}
    MergeTable(t, StringToTable(ct))

    -- {{{ CRC32
    -- crc
    local crc = crc32.enc(t)
    t[5] = bit.rshift(crc , 24)
    t[6] = bit.band(bit.rshift(crc , 16), 255)
    t[7] = bit.band(bit.rshift(crc , 8) , 255)
    t[8] = bit.band(crc , 255)
    -- }}}
    
    -- {{{ OUTPUT
    local s = ""
    s = "@ --------------------" .. MYSLOT_LINE_SEP .. s
    s = "@ " .. L["Feedback"] .. "  farmer1992@gmail.com" .. MYSLOT_LINE_SEP .. s
    s = "@ " .. MYSLOT_LINE_SEP .. s
    s = "@ " .. LEVEL .. ":" ..UnitLevel("player") .. MYSLOT_LINE_SEP .. s
    -- s = "@ " .. SPECIALIZATION ..":" .. ( GetSpecialization() and select(2, GetSpecializationInfo(GetSpecialization())) or NONE_CAPS ) .. MYSLOT_LINE_SEP .. s
    s = "@ " .. TALENT .. ":" .. select(3,GetTalentTabInfo(1)) .. "/" .. select(3,GetTalentTabInfo(2)) .. "/" .. select(3,GetTalentTabInfo(3)) .. MYSLOT_LINE_SEP .. s
    s = "@ " .. CLASS .. ":" ..UnitClass("player") .. MYSLOT_LINE_SEP .. s
    s = "@ " .. PLAYER ..":" ..UnitName("player") .. MYSLOT_LINE_SEP .. s
    s = "@ " .. L["Time"] .. ":" .. date() .. MYSLOT_LINE_SEP .. s
    s = "@ Wow (V" .. GetBuildInfo() .. ")" .. MYSLOT_LINE_SEP .. s
    s = "@ Myslot (V" .. MYSLOT_VER .. ")" .. MYSLOT_LINE_SEP .. s

    local d = base64.enc(t)
    local LINE_LEN = 80
    for i = 1, d:len(), LINE_LEN do
        s = s .. d:sub(i, i + LINE_LEN - 1) .. MYSLOT_LINE_SEP
    end
    MYSLOT_ReportFrame_EditBox:SetText(s)
    MYSLOT_ReportFrame_EditBox:HighlightText()
    -- }}}
end

function MySlot:Import()
    if InCombatLockdown() then
        MySlot:Print(L["Import is not allowed when you are in combat"])
        return
    end

    local s = MYSLOT_ReportFrame_EditBox:GetText() or ""
    s = string.gsub(s,"(@.[^\n]*\n)","")
    s = string.gsub(s,"(#.[^\n]*\n)","")
    s = string.gsub(s,"\n","")
    s = string.gsub(s,"\r","")
    s = base64.dec(s)
    
    if #s < 8  then
        MySlot:Print(L["Bad importing text [TEXT]"])
        return
    end

    local force = _G['MYSLOT_ReportFrameForceImport']:GetChecked()

    local ver = s[1]
    local crc = s[5] * 2^24 + s[6] * 2^16 + s[7] * 2^8 + s[8]
    s[5], s[6], s[7] ,s[8] = 0, 0 ,0 ,0
    
    if ( crc ~= bit.band(crc32.enc(s), 2^32 - 1)) then
        MySlot:Print(L["Bad importing text [CRC32]"])
        if force then
            MySlot:Print(L["Skip bad CRC32"] .. " " .. L["Try force importing"])
        else
            return 
        end
    end

    if not tContains(MYSLOT_ALLOW_VER,ver) then
        MySlot:Print(L["Importing text [ver:%s] is not compatible with current version"]:format(ver))
        if force then
            MySlot:Print(L["Skip unsupported version"] .. " " .. L["Try force importing"])
        else
            return 
        end
    end

    local ct = {}
    for i = 9, #s do
        ct[#ct + 1] = s[i]
    end
    ct = TableToString(ct)
    
    local msg = _MySlot.Charactor():Parse(ct)

    StaticPopupDialogs["MYSLOT_MSGBOX"].OnAccept = function()
        StaticPopup_Hide("MYSLOT_MSGBOX")
        MySlot:RecoverData(msg)
    end
    StaticPopup_Show("MYSLOT_MSGBOX")
end

-- {{{ FindOrCreateMacro
function MySlot:FindOrCreateMacro(macroInfo)
    if not macroInfo then
        return
    end
    -- cache local macro index
    -- {{{ 
    local localMacro = {}
    for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        
        local name, _, body = GetMacroInfo(i)
        if name then
            localMacro[ name .. "_" .. body ] = i
            localMacro[ body ] = i
        end
    end
    -- }}} 

    local id = macroInfo["oldid"]
    local name = macroInfo["name"]
    local icon = macroInfo["icon"]
    local body = macroInfo["body"]

    local localIndex = localMacro[ name .. "_" .. body ] or localMacro[ body ]

    if localIndex then
        return localIndex
    else

        local numglobal, numperchar = GetNumMacros()
        local perchar = id > MAX_ACCOUNT_MACROS and 2 or 1

        --[[
            perchar    G = 01 P = 10 
            testallow  allow 01 | allow 10 = 00 , 01 , 10 , 11
            perchar & testallow = 01 , 10 , 00
            perchar = testallow when not allow
        ]]
        local testallow = bit.bor( numglobal < MAX_ACCOUNT_MACROS and 1 or 0 , numperchar < MAX_CHARACTER_MACROS and 2 or 0)
        perchar = bit.band( perchar, testallow)
        perchar = perchar == 0 and testallow or perchar
                
        if perchar ~= 0 then
            -- fix icon using #showtooltip
            
            if strsub(body,0, 12) == '#showtooltip' then
                icon = 'INV_Misc_QuestionMark'
            end
            local newid = CreateMacro(name, icon, body, perchar >= 2)
            if newid then
                return newid
            end
        end

        self:Print(L["Macro %s was ignored, check if there is enough space to create"]:format(name))
        return nil
    end
end
-- }}}


function MySlot:RecoverData(msg)

    -- {{{ Cache Spells
    --cache spells
    local spells = {}


    for i = 1, GetNumSpellTabs() do
            local tab, tabTex, offset, numSpells, isGuild, offSpecID = GetSpellTabInfo(i);
        offSpecID = (offSpecID ~= 0)
        if not offSpecID then

            offset = offset + 1;
            local tabEnd = offset + numSpells;
            for j = offset, tabEnd - 1 do
                local spellType, spellId = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
                if spellType then
                    local slot = j + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[i] - 1));
                    local spellName = GetSpellInfo(spellId)
                    spells[MySlot.SLOT_TYPE[string.lower(spellType)] .. "_" .. spellId] = {slot, BOOKTYPE_SPELL, "spell"}
                    if spellName then -- flyout 
                        spells[MySlot.SLOT_TYPE[string.lower(spellType)] .. "_" .. spellName] = {slot, BOOKTYPE_SPELL, "spell"}
                    end
                end
            end
        end
    end

    -- removed in 6.0 
    -- for _, companionsType in pairs({"CRITTER"}) do
    --     for i =1,GetNumCompanions(companionsType) do
    --         local _,_,spellId = GetCompanionInfo( companionsType, i)
    --         spells[MYSLOT_SPELL .. "_" .. spellId] = {i, companionsType, "companions"}
    --     end
    -- end


    -- for _, p in pairs({GetProfessions()}) do
    --     local _, _, _, _, numSpells, spelloffset = GetProfessionInfo(p)
    --     for i = 1,numSpells do
    --         local slot = i + spelloffset
    --         local spellType, spellId = GetSpellBookItemInfo(slot, BOOKTYPE_PROFESSION)
    --         if spellType then
    --             spells[MySlot.SLOT_TYPE[string.lower(spellType)] .. "_" .. spellId] = {slot, BOOKTYPE_PROFESSION, "spell"}
    --         end
    --     end
    -- end
    
    -- }}}

    
    -- {{{ cache mounts

    -- local mounts = {}

    -- for i = 1, C_MountJournal.GetNumMounts() do
    --     ClearCursor()
    --     C_MountJournal.Pickup(i)
    --     local _, mount_id = GetCursorInfo()

    --     if mount_id then
    --         mounts[mount_id] = i
    --     end
    -- end

    -- }}}


    -- {{{ Macro

    -- cache macro

    

    local macro = {}
    for _, m in pairs(msg.macro or {}) do

        local macroId = m.id
        local icon = m.icon

        local name = m.name
        local body = m.body

        macro[macroId] = {
            ["oldid"] = macroId,
            ["name"] = name,
            ["icon"] = icon,
            ["body"] = body,
        }

        self:FindOrCreateMacro(macro[macroId])
    end

    -- }}} Macro

    local slotBucket = {}

    for _, s in pairs(msg.slot or {}) do
        local slotId = s.id
        local slotType = _MySlot.Slot.SlotType[s.type]
        local index = s.index
        local strindex = s.strindex

        local curType, curIndex = GetActionInfo(slotId)
        curType = MySlot.SLOT_TYPE[curType or MYSLOT_NOTFOUND]
        slotBucket[slotId] = true

        if not pcall(function()
            if curIndex ~= index or curType ~= slotType or slotType == MYSLOT_MACRO then -- macro always test
                if slotType == MYSLOT_SPELL or slotType == MYSLOT_FLYOUT or slotType == MYSLOT_COMPANION then
                    
                    if slotType == MYSLOT_SPELL or slotType == MYSLOT_COMPANION then
                        PickupSpell(index)
                    end

                    if not GetCursorInfo() then
                        -- flyout and failover

                        local spellName = GetSpellInfo(index) or "NOSUCHSPELL"
                        local newId, spellType, pickType = unpack(spells[slotType .."_" ..index] or spells[slotType .."_" ..spellName] or {})

                        if newId then
                            if pickType == "spell" then
                                PickupSpellBookItem(newId, spellType)
                            elseif pickType == "companions" then
                                PickupCompanion(spellType , newId)
                            end
                        else
                            MySlot:Print(L["Ignore unlearned skill [id=%s], %s"]:format(index, GetSpellLink(index)))    
                        end
                    end
                elseif slotType == MYSLOT_ITEM then
                    PickupItem(index)
                elseif slotType == MYSLOT_MACRO then
                    local macroid = self:FindOrCreateMacro(macro[index])

                    if curType ~= MYSLOT_MACRO or curIndex ~=index then
                        PickupMacro(macroid)
                    end
                elseif slotType == MYSLOT_SUMMONPET and strindex and strindex ~=curIndex then
                    C_PetJournal.PickupPet(strindex , false)
                    if not GetCursorInfo() then
                        C_PetJournal.PickupPet(strindex, true)
                    end
                    if not GetCursorInfo() then
                        MySlot:Print(L["Ignore unattained pet[id=%s], %s"]:format(strindex, C_PetJournal.GetBattlePetLink(strindex)))    
                    end
                elseif slotType == MYSLOT_SUMMONMOUNT then
                    
                    index = mounts[index]
                    if index then
                        C_MountJournal.Pickup(index)
                    else
                        C_MountJournal.Pickup(0)
                        MySlot:Print(L["Use random mount instead of an unattained mount"])
                    end
                    
                elseif slotType == MYSLOT_EMPTY then
                    PickupAction(slotId)
                elseif slotType == MYSLOT_EQUIPMENTSET then
                    PickupEquipmentSet(index)
                end
                PlaceAction(slotId) 
                ClearCursor()
            end
        end) then
            
            MySlot:Print(L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"]:format(slotId,slotType,index,MYSLOT_AUTHOR))
        end
    end

    for i = 1, MYSLOT_MAX_ACTIONBAR do
        if not slotBucket[i] then
            if GetActionInfo(i) then
                PickupAction(i)
                ClearCursor()
            end
        end
    end

    for _, b in pairs(msg.bind or {}) do
        
        local command = b.command
        if b.id ~= MYSLOT_BIND_CUSTOM_FLAG then
            command = MySlot.R_BINDS[b.id]
        end

        if b.key1 then
            local mod, key = MySlot.R_MOD_KEYS[b.key1.mod], MySlot.R_KEYS[b.key1.key]
            if key == "KEYCODE" then
                key = b.key1.keycode
            end
            local key = ( mod ~= "NONE" and (mod .. "-") or "" ) .. key
            SetBinding(key, command, 1)
        end

        if b.key2 then
            local mod, key = MySlot.R_MOD_KEYS[b.key2.mod], MySlot.R_KEYS[b.key2.key]
            if key == "KEYCODE" then
                key = b.key2.keycode
            end
            local key = ( mod ~= "NONE" and (mod .. "-") or "" ) .. key
            SetBinding(key, command, 1)
        end

    end
    -- SaveBindings(GetCurrentBindingSet())

    MySlot:Print(L["All slots were restored"])
end

function MySlot:Clear(what)
    if what == "action" then
        for i = 1, MYSLOT_MAX_ACTIONBAR do
            PickupAction(i)
            ClearCursor()
        end
    elseif what == "binding" then
        for i = 1, GetNumBindings() do
            local _, _, key1, key2 = GetBinding(i)
            
            for _, key in pairs({key1, key2}) do
                if key then
                    SetBinding(key, nil, 1)
                end
            end
        end
        SaveBindings(GetCurrentBindingSet())
    end
end

SlashCmdList["MYSLOT"] = function(msg, editbox)
    local cmd, what = msg:match("^(%S*)%s*(%S*)%s*$")

    if cmd == "clear" then
        MySlot:Clear(what)
    else
        MYSLOT_ReportFrame:Show() 
    end
end
SLASH_MYSLOT1 = "/MYSLOT"

StaticPopupDialogs["MYSLOT_MSGBOX"] = {
    text = L["Are you SURE to import ?"],
    button1 = ACCEPT,
    button2 = CANCEL,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    multiple = 0,
}

local f = CreateFrame('Frame')
f:RegisterEvent('ADDON_LOADED')

f:SetScript("OnEvent", function()
    -- TODO clean up code
    local FRAMENAME = 'MYSLOT_ReportFrame'
    _G[FRAMENAME .. 'CloseButton']:SetText(L["Close"])
    _G[FRAMENAME .. 'CloseButton']:SetScript('OnClick', function()
        MYSLOT_ReportFrame:Hide()
    end)

    _G[FRAMENAME .. 'ImportButton']:SetText(L["Import"])
    _G[FRAMENAME .. 'ImportButton']:SetScript('OnClick', function()
        MySlot:Import()
    end)

    _G[FRAMENAME .. 'ExportButton']:SetText(L["Export"])
    _G[FRAMENAME .. 'ExportButton']:SetScript('OnClick', function()
        MySlot:Export()
    end)

    _G[FRAMENAME .. 'ForceImportText']:SetText(L["Force Import"])
    _G[FRAMENAME .. 'ForceImport'].tooltip = L["Skip CRC32, version and any other validation before importing. May cause unknown behavior"]

    -- _G[FRAMENAME .. 'OptionFrameOptionBarText']:SetText(L["Import and Export settings below"])
    -- _G[FRAMENAME .. 'OptionFrameActionText']:SetText(L["Spell"])
    -- _G[FRAMENAME .. 'OptionFrameMacroText']:SetText(L["Macro"])
    -- _G[FRAMENAME .. 'OptionFrameBindingText']:SetText(L["Keys Binding"])
end)
