if not ACP then return end

--@non-debug@

if (GetLocale() == "zhCN") then
	ACP:UpdateLocale(

L = {
	["*** Enabling <%s> %s your UI ***"] = "*** 启用 <%s>，%s 你的插件 ***",
	["*** Unknown Addon <%s> Required ***"] = "*** 需要未知插件 <%s> ***",
	["ACP: Some protected addons aren't loaded. Reload now?"] = "ACP：部分受保护插件没有被加载。现在重载插件么？",
	["Active Embeds"] = "单独使用",
	["Add to current selection"] = "添加当前选择",
	["Addon <%s> not valid"] = "无效的插件：<%s>",
	["AddOns"] = "插件管理",
	["Addons [%s] Loaded."] = "插件设置[%s]已加载。",
	["Addons [%s] renamed to [%s]."] = "插件设置[%s]已改名为[%s]。",
	["Addons [%s] Saved."] = "插件设置[%s]已保存。",
	["Addons [%s] Unloaded."] = "插件设置[%s]已卸载。",
	["Author"] = "作者",
	["Blizzard_AchievementUI"] = "Blizzard: Achievement",
	["Blizzard_AuctionUI"] = "Blizzard: Auction",
	["Blizzard_BarbershopUI"] = "Blizzard: Barbershop",
	["Blizzard_BattlefieldMinimap"] = "Blizzard: Battlefield Minimap",
	["Blizzard_BindingUI"] = "Blizzard: Binding",
	["Blizzard_Calendar"] = "Blizzard: Calendar",
	["Blizzard_CombatLog"] = "Blizzard: Combat Log",
	["Blizzard_CombatText"] = "Blizzard: Combat Text",
	["Blizzard_FeedbackUI"] = "Blizzard: Feedback",
	["Blizzard_GlyphUI"] = "Blizzard: Glyph",
	["Blizzard_GMSurveyUI"] = "Blizzard: GM Survey",
	["Blizzard_GuildBankUI"] = "Blizzard: GuildBank",
	["Blizzard_InspectUI"] = "Blizzard: Inspect",
	["Blizzard_ItemSocketingUI"] = "Blizzard: Item Socketing",
	["Blizzard_MacroUI"] = "Blizzard: Macro",
	["Blizzard_RaidUI"] = "Blizzard: Raid",
	["Blizzard_TalentUI"] = "Blizzard: Talent",
	["Blizzard_TimeManager"] = "Blizzard: TimeManager",
	["Blizzard_TokenUI"] = "Blizzard: Token",
	["Blizzard_TradeSkillUI"] = "Blizzard: Trade Skill",
	["Blizzard_TrainerUI"] = "Blizzard: Trainer",
	["Blizzard_VehicleUI"] = "Blizzard: Vehicle",
	["Click to enable protect mode. Protected addons will not be disabled"] = "点击启用保护模式。受保护插件不会被禁用。",
	["Close"] = "关闭",
	["Default"] = "默认",
	["Dependencies"] = "依赖",
	["Disable All"] = "全部禁用",
	["Disabled on reloadUI"] = "重载插件后禁用",
	["Embeds"] = "内置",
	["Enable All"] = "全部启用",
	["Enter the new name for [%s]:"] = "输入[%s]的新名字：",
	["Load"] = "加载",
	["Loadable OnDemand"] = "需要时加载",
	["Loaded"] = "已加载",
	["Loaded on demand."] = "需要时加载。",
	["LoD Child Enable is now %s"] = "需要时加载的子插件：%s",
	["Memory Usage"] = "内存占用",
	["No information available."] = "无可用信息。",
	["Recursive"] = "递归",
	["Recursive Enable is now %s"] = "递归加载的插件：%s",
	["Reload"] = "重载",
	["Reload your User Interface?"] = "重载插件？",
	["ReloadUI"] = "重载插件",
	["Remove from current selection"] = "移除当前选择",
	["Rename"] = "重命名",
	["Resurse-ToolTip"] = "当启用一个插件时，尝试启用此插件所依赖的插件。",
	["Save"] = "保存",
	["Save the current addon list to [%s]?"] = "保存当前插件设置为[%s]？",
	["Set "] = "配置：",
	["Sets"] = "配置",
	["Status"] = "状态",
	["Use SHIFT to override the current enabling of dependancies behaviour."] = "使用 Shift 键无视目前的递归设定。",
	["Version"] = "版本",
	["when performing a reloadui."] = "重载插件时。"
}


    )
end

--@end-non-debug@
