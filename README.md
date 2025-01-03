# Hotfix
<a href='https://ko-fi.com/hackerdude' target='_blank'><img height='35' style='border:0px;height:46px;' src='https://az743702.vo.msecnd.net/cdn/kofi3.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' />

A universal Kindle jailbreak hotfix based on NiLuJe's

## Universal Hotfix Changes
- We target every Kindle the original hotfix did* (*testing needed to validate this to be honest)
- Targets all Kindle architectures and persists cross-architecture upgrades/downgrades
- Designed to install more than just the hotfix/bridge script
- Hotfix Script now uses FBInk natively so 

## What does it do
The Hotfix is split into two parts, the installer and the hotfix itself

### The Installer
1. Create persistent storage directories under /var/local
2. Copy data under `mkk` and `kmc` to those directories
3. Fix permissions (`chmod a+rx`) and ownership for stuff in those folders
4. Fix Gandalf (`chmod +s`)
5. Setup persistent RP (Rescue Pack - LEGACY TO BE REPLACED)
6. Installs the KMC upstart job
7. Sets up gandalf `su` links for all architectures under `kmc` as well as the current one in `mkk`
8. Installs the proper `fbink` binary to `/mnt/us/libkh/bin/fbink`
9. Installs the hotfix booklet as `run_hotfix.run_hotfix`
10. Sets up `sh_integration` with the current architecture
11. Modifies the appreg for `sh_integration` and `hotfix_runner`

### The Hotfix
1. Mount rootfs as RW
2. Install /MNTUS_EXEC flag if firmware is >=5.4
3. If using old uks, add our dev key
4. If using new uks, replace sqsh
5. Add the java developer.keystore if it hasn't been added
6. Add the Kindlet JB jar file if needed (idk)
7. Setup Gandalf if it's not got the proper perms and such
8. Install RP/CRP if needed
9. Install the logThis.sh dispatcher
10. Modify the search command list
11. Add the KMC upstart job if it doesn't already exist
12. Add debugging features flag if firmware is >=5.12 and we don't have it