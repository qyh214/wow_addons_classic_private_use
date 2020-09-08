# Deadly Boss Mods Core

## [1.13.59](https://github.com/DeadlyBossMods/DBM-Classic/tree/1.13.59) (2020-09-04)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Classic/compare/1.13.58...1.13.59) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Classic/releases)

- Prep new release  
- Added a nameplate aura to bugs that are exploding to twin emps  
- Update localization.cn.lua (#560)  
- Add another user frontend debug feature to report invalid spell or journal Ids, also off by default  
- I'm sure this is answer for visc  
- Allow milliseconds to be disabled all the way down to 1 second  
- Update localization.fr.lua (#559)  
- Update localization.cn.lua (#558)  
- Update localization.cn.lua (#557)  
    Smooth chinese sentence grammar  
- Update localization.cn.lua (#556)  
    smooth chinese sentence's grammar  
- Update localization.cn.lua (#555)  
- Fix one of numeric values in last  
- Make it easier for users to contribute bad timer data via new bug report options they can choose to opt into that's more user friendly than just asking users to run the more developer advanced debug mode. this new area will allow DBM to simply add options specifically targetting boss mod type bugs like bad timers  
- Fix  
- The way api returns string on buru, users are reporting never seeing pursue warnings, My own transcriptor shows this is likely do to the fact it's not propertly handling player name insertion. based on this transcriptor log it also looks like this partial match omitting the player name part will competely solve the problem. Also made mod match conventions while at it  
- Update localization.fr.lua (#553)  
- Fix conventions on this mod so that stops happening in first place. DBM always does ID as Id  
- two fixes  
- Fix two differernt scenarios I saw on stream in last 24 hours in regard to AQ40 speed clear timer/progress tracking.  
    1. If a user releases during a boss and raid successfully downs that boss, that progress was not counted for the player who released.  
    2. If a user sits for a boss entirely. I saw a speed clear where one player had to take an emergency afk during clear and simply stepped outside for Ouro.  
    Both situations are now handled by synced boss kill progress  
- Update localization.cn.lua (#551)  
- Update localization.tw.lua (#552)  
- Add all frost schools, for good measure  
- This should fix up viscidus problems  
- Limit viscidus tracker to debug mode only for now. it has 3 issues that need fixing.  
- Don't cap infoframe on cthun,  
- Update koKR (Classic) (#543)  
- Block the dark glare airhorn/warning if dead or ghost. this fixes issue with warning showing during run back, before wipe officially declared, often happening in event player releases BEFORE encounter\_end fires, causing the mod to stay active until they zone back in.  
- Fix bug where recovered speed clear timer didn't have an icon  
- Bug fixes koKR locale (#542)  
- Fine, do it this way  
- remove this, it's not needed  
- prep new alpha cycle, before the PRs start up again.  
