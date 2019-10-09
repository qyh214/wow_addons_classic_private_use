# Deadly Boss Mods Core

## [1.13.14](https://github.com/DeadlyBossMods/DBM-Classic/tree/1.13.14) (2019-10-07)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Classic/compare/1.13.13b...1.13.14)

- Bump version  
- Make countdown for wrath of ragnaros on by default for melee  
    Fixed a few niche cases where UnitGroupRoleAssigned might still be called incorrectly in classic (doesn't exist until wrath)  
- auto range 10 on ragnaros for non melee  
- End combat is not fast enough in classic without ENCOUNTER\_END to return valid health at exact time of death, so in event health returns 100% on wipe, ignore this value and try to return last non 100% value instead to fix invalid health reporting for wipes.  
- Disable focus from health checker, it shouldn't be checked in classic  
- Fixed Hud arrow pointing wrong way for 180 degrees of the circle.  
- Add an additional scan for combat on player regen, to attempt to speed up pull detection in dungeons a tiny bit  
- Update luacheck  
- Maraudon update  
- Update user hud commands so that they don't interfere with hud usage from other mods or functions  
- Added a blocker for obsolete Victory sounds 3rd party module  
- Push 8.2.5 arrow fix here too, because god knows if it's broken in retail they'll probably break it in classic too, for feature parity  
- Merge pull request #15 from Elnarfim/master  
    KR Update (Classic)  
- EditBox fix for RaidLeadTools (when it becomes functional)  
- KR Update (Classic)  
- Merge remote-tracking branch 'upstream/master'  
- Rename some callbacks so they don't have common names and can clearly be identified as DBM events  
- Merge remote-tracking branch 'upstream/master'  
- forgot kr localization in toc  
- KR massive push (classic)  
