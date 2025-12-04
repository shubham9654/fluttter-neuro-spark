# 🧭 Bottom Navigation Guide

## Overview

NeuroSpark now features a beautiful, persistent bottom navigation bar with 4 main sections.

## 📱 Navigation Structure

### 4 Main Tabs

1. **🏠 Home** (`/dashboard`)
   - Main dashboard with today's tasks
   - Progress tracking
   - Quick actions
   - Stats overview

2. **🧠 Tasks** (`/dashboard/inbox`)
   - Brain Dump inbox
   - Quick task capture
   - Swipe gestures
   - Task management

3. **🛍️ Shop** (`/shop`)
   - Dopamine rewards store
   - Themes, sounds, avatars
   - Power-ups
   - Coin spending

4. **👤 Profile** (`/profile`)
   - User profile & avatar
   - Stats & achievements
   - Settings
   - Sign out

## 🎨 Design Features

### Bottom Navigation Bar
- **Rounded top corners** (24px radius)
- **Elevated shadow** for depth
- **Icon size**: 22px (inactive), 24px (active)
- **Color scheme**:
  - Active: Primary color (#00C4B4)
  - Inactive: Light gray
  - Background: White
- **Smooth transitions** between tabs
- **Fixed position** at bottom

### Profile Page Features

#### Header Section
- **Gradient background** (Primary → Purple)
- **Circular avatar** with border
- **User name** and email display
- **Expandable app bar** (200px expanded)

#### Stats Cards (2x2 Grid)
- 🔥 **Day Streak** - Current consecutive days
- ⚡ **Level & XP** - Gamification progress
- 🪙 **Coins** - Available currency
- ✅ **Tasks Done** - Completion count

#### Achievements Section
- 🏆 **Focus Master** - Total focus minutes
- 🚀 **Productivity Streak** - Longest streak
- ⭐ **Task Warrior** - Total tasks completed

#### Settings Section
- 🔔 **Notifications** - Manage alerts
- 🎨 **Theme** - Customize appearance
- 🔊 **Sounds** - Audio preferences
- ℹ️ **About** - App information

#### Sign Out
- Confirmation dialog
- Secure logout
- Returns to welcome screen

## 🔧 Implementation Details

### Files Created

1. **`lib/features/settings/presentation/pages/profile_page.dart`**
   - Complete profile UI
   - Stats visualization
   - Settings management
   - ~450 lines

2. **`lib/common/widgets/main_scaffold.dart`**
   - Bottom navigation wrapper
   - Navigation logic
   - Consistent layout
   - ~100 lines

### Router Updates

Updated `lib/common/routes/app_router.dart`:
- Wrapped dashboard in `MainScaffold` (index: 0)
- Wrapped inbox in `MainScaffold` (index: 1)
- Wrapped shop in `MainScaffold` (index: 2)
- Added profile route with `MainScaffold` (index: 3)

### Navigation Flow

```
MainScaffold (wrapper)
├── currentIndex: 0-3
├── child: Page content
└── bottomNavigationBar: 4 tabs

Tab Selection:
- Tap → Navigate to route
- Current tab highlighted
- Smooth page transitions
```

## 📊 User Stats Displayed

### From GameStatsProvider
- `currentStreak` - Active day streak
- `longestStreak` - Best streak ever
- `level` - Current level
- `totalXp` - Total experience points
- `coins` - Available coins
- `tasksCompleted` - Total tasks done
- `totalFocusMinutes` - Minutes in focus mode
- `unlockedItems` - Purchased shop items

### From AuthProvider
- `displayName` - User's name
- `email` - User's email
- `photoURL` - Profile picture

## 🎯 Navigation Behavior

### Tab Switching
- **Same tab**: No action
- **Different tab**: Navigate to new route
- **State preservation**: Each tab maintains its state
- **Back button**: Standard browser/device back

### Routes with Bottom Nav
```dart
/dashboard          → Home tab (index 0)
/dashboard/inbox    → Tasks tab (index 1)
/shop              → Shop tab (index 2)
/profile           → Profile tab (index 3)
```

### Routes WITHOUT Bottom Nav
```dart
/                  → Welcome (login)
/onboarding/*      → Setup flow
/focus/*           → Focus sessions
/focus/victory     → Celebration
/sorter            → Task sorter
```

## 🎨 Customization

### Change Bottom Nav Colors

Edit `lib/common/widgets/main_scaffold.dart`:

```dart
BottomNavigationBar(
  selectedItemColor: AppColors.primary,    // Active color
  unselectedItemColor: AppColors.textLight, // Inactive color
  backgroundColor: Colors.white,            // Background
)
```

### Change Tab Icons

Edit the `items` list in `main_scaffold.dart`:

```dart
BottomNavigationBarItem(
  icon: FaIcon(FontAwesomeIcons.yourIcon),
  label: 'Your Label',
)
```

### Add More Stats

Edit `profile_page.dart`, add to stats grid:

```dart
_buildStatCard(
  icon: FontAwesomeIcons.yourIcon,
  value: '${gameStats.yourStat}',
  label: 'Your Label',
  color: AppColors.yourColor,
)
```

## 🔄 State Management

### Current Implementation
- **Riverpod providers** for state
- **Real-time updates** across tabs
- **Persistent state** during navigation
- **No data loss** on tab switch

### Data Flow
```
User Action
    ↓
Provider Update
    ↓
UI Rebuild (all tabs)
    ↓
Consistent State
```

## 📱 Responsive Design

### Mobile
- Bottom nav always visible
- Full-width tabs
- Touch-optimized spacing

### Tablet
- Same layout (optimized for mobile-first)
- Larger touch targets

### Desktop/Web
- Bottom nav still present
- Consider adding side navigation in future

## 🚀 Future Enhancements

### Potential Additions
1. **Badge notifications** on tabs
2. **Long-press actions** on nav items
3. **Swipe gestures** between tabs
4. **Haptic feedback** on tab change
5. **Custom tab animations**
6. **Mini floating action button** on specific tabs

### Profile Page Enhancements
1. **Edit profile** functionality
2. **Avatar upload** from device
3. **Theme switcher** (dark mode)
4. **Export data** feature
5. **Achievement badges** gallery
6. **Social features** (future)

## 🐛 Troubleshooting

### Bottom nav not showing
- Check route is wrapped in `MainScaffold`
- Verify `currentIndex` is set correctly

### Wrong tab highlighted
- Check `currentIndex` matches route
- Verify navigation logic in `_onItemTapped`

### Navigation not working
- Check route names match in router
- Verify `Navigator.pushReplacementNamed` is used

### Stats not updating
- Check Riverpod providers are watched
- Verify state updates in notifiers

## 📚 Related Files

- `lib/common/widgets/main_scaffold.dart` - Bottom nav wrapper
- `lib/features/settings/presentation/pages/profile_page.dart` - Profile UI
- `lib/common/routes/app_router.dart` - Route definitions
- `lib/core/providers/auth_providers.dart` - User state
- `lib/core/providers/game_stats_providers.dart` - Stats state

---

**Navigation is now complete! 🎉**

Users can seamlessly switch between Home, Tasks, Shop, and Profile with a beautiful, consistent bottom navigation bar.

