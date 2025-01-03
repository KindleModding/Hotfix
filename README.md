# HAKT
<a href='https://ko-fi.com/hackerdude' target='_blank'><img height='35' style='border:0px;height:46px;' src='https://az743702.vo.msecnd.net/cdn/kofi3.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' />

HAckerdude's<br/>
Kindle<br/>
Toolkit<br/>

A collection of utilities including a revamped hotfix all as a single update file to be installed after jailbreaking
- Universal Hotfix
- sh_integration
- KPM

## Universal Hotfix
- This is a hotfix based on NiLuJe's K5 Hotfix modified to support both `armel` and `armhf` Kindles
- We target every Kindle the original hotfix did* (*testing needed to validate this to be honest)
- Targets all Kindle architectures and persists cross-architecture upgrades/downgrades
- Designed to install more than just the hotfix/bridge script
- Hotfix Script now uses FBInk natively so eink deprecation issues are ignored

## sh_integration
- Allows any .sh file put into a Kindle's documents folder to show up in the library as if it were a book
- .sh files can be run simply by clicking on them
- Stdout and stderr are both redirected to the display via fbink

## KPM
- The Kindle Package Manager
- It's like APT, if APT was built in a week and made for Kindles
- Use it via the search bar `;kpm`