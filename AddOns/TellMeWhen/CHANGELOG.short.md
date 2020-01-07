
## v8.7.3
* Added a new "Any Totem" condition that will check all totem slots.
* Updated totem checking to account for removal of totem APIs in 1.13.3. Totem deaths cannot be accounted for.

### Bug Fixes
* Fix #1742 - Errors related to improper escaping of user input for the suggestion list.
* Fixed error `bad argument #1 to 'strlower' (string expected, got boolean)` when using Diminishing Returns icons
* Fix #1755 - Swing Timer conditions with durations other than zero seconds were not triggering updates at the proper moment.
* Fixed error `PlayerNames.lua:96: attempt to concatenate field "?" (a nil value)`

