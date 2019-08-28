# wow_addons_classic_private_use 魔兽世界怀旧服自用整合插件
魔兽世界怀旧服务器自用插件wow addons classic private use

## 使用方法
将addons文件夹放置在```游戏根目录/_classic_/interface/```下，例如```D:\World of Warcraft\_classic_\interface\addons```，进入后便是插件列表，避免出现```D:\World of Warcraft\_classic_\interface\addons\addons```等情况。

## 一些有用的重要命令
在游戏内聊天窗口输入，然后回车：

最远镜头距离：`/console cameraDistanceMaxZoomFactor 2.6`

总是对比装备：`/console alwaysCompareItems 1`

以上命令可借助插件AdvancedInterfaceOptions、ElvUI_WindTools控制。

WTF（WOW安装目录/WTF/config.wtf）：

在配置文件内添加以下内容（可能会被覆盖掉，可由插件AdvancedInterfaceOptions再次单角色控制）

```
SET overrideArchive "0"
SET profanityFilter "0"
```
