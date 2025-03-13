## v1.0.2 (Mar 13, 2025)

### Improvements
- Fixed `provider()` in `SendbirdUIKit` to be available everywhere

## v1.0.1 (Jan 2, 2025)
- Updated `README.md`

## v1.0.0 (Dec 6, 2024)
- GA

## v1.0.0-beta.6 (Nov 29, 2024)

### Features
- Added a `chooseMedia` parameter in `SendbirdUIKit.init()`

### Improvements
- Fixed to support tree-shake-icons option when building applications
- Fixed some UI bugs

## v1.0.0-beta.5 (Nov 15, 2024)

### Features
- Added `useReaction`, `useOGTag` and `replyType` parameters in `init()` in `SendbirdUIKit`
- Added `onListItemClicked` parameter in `SBUGroupChannelScreen`
- Added video thumbnail for Android and iOS

## v1.0.0-beta.4 (Jul 11, 2024)

### Improvements
- Updated `README.md` and the documentation link

## v1.0.0-beta.3 (Jul 4, 2024)

### Improvements
- Updated dependency range for `intl` package from `^0.18.1` to `>=0.18.1 <1.0.0`
- Renamed `customMessageSender` to `customMessageInput`

## v1.0.0-beta.2 (Jun 14, 2024)

### Improvements
- Updated `README.md`

## v1.0.0-beta.1 (Jun 14, 2024)

### Features
- Added UIKit Screens for `GroupChannel` List
  - `SBUGroupChannelListScreen`
  - `SBUGroupChannelCreateScreen`
  - `SBUGroupChannelSettingsScreen`
- Added UIKit Screens for `GroupChannel`
  - `SBUGroupChannelScreen`
  - `SBUGroupChannelInformationScreen`
  - `SBUGroupChannelMembersScreen`
  - `SBUGroupChannelInviteScreen`
  - `SBUGroupChannelModerationsScreen`
  - `SBUGroupChannelOperatorsScreen`
  - `SBUGroupChannelMutedMembersScreen`
  - `SBUGroupChannelBannedUsersScreen`
- Added UIKit Resources
  - `SBUThemeProvider`
  - `SBUStringProvider`
  - `SBUColors`
  - `SBUIcons`
