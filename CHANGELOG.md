# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-10-07

### Added

-   Added the use a bottle of water to brush your teeth.
-   Toothbrush item now returns to the place where it was grabbed from.

### Changed

-   Item script definitions are now modified on both the server and the client. This should fix a mismatch of item definitions between the client and server if it were to ever happen.
-   Optimised some code loops (remove pairs and ipairs usage).
-   Fixed a typo in the item script.
-   Changed some things in the mod data table. This will cause (THIS MOD ONLY, NOT ALL) player mod data to reset.
-   Fixed the moodle not displaying the negative portion.
-   Fixed the moodle displaying the state incorrectly.
-   Fixed a bug which caused the items to not be tweaked properly.
-   Fixed item distributions table parsing.
-   Fixed player mod data being the same for all clients.
-   Fixed the trait not being created properly. (?)
-   Fixed from changing the bottom half of the player animation.

## [1.2.1] - 2024-07-06

### Changed

-   Changed logger func calls to now use implied self arg

## [1.2.0] - 2024-07-04

### Added

-   Added 10 differently coloured toothbrush textures.
-   Added 3 different toothbrush textures showing similarities to real world brands.
-   Added the `Toothbrush` tag to `Base.Toothbrush`.
-   Added the `Toothpaste` tag to `Base.Toothpaste`.
-   Added a tooltip to show when the player has brushed their teeth too recently.
-   Fixed a bug where you couldn't brush on certain sink objects (I hope).
-   Fixed a bug that caused an error when brushing teeth.

### Changed

-   A small chunk of the code.
-   Made the ToothpastesRequired sandbox option irrelevant for now as it's not needed.

### Removed

-   ItemTweakerAPI due to lack of a proper use-case when I can just inline the code myself.

## [1.1.0] - 2024-04-11

### Added

-   Teeth brushing animation
-   Positive and Negative trait
-   MoodleFramework dependency
-   Teeth brush status moodle
-   Multiple sandbox options (with docs and calculator on GitHub)
-   More translations
-   Lots of code (changelog only lists front-end noticable features)

### Changed

-   Use GlobalModData instead of PlayerModData (supports cleanup of old GlobalModData).
-   Fixed bug where items didn't transfer to the main inventory.
-   Fixed potential lua file name conflict issue
-   Much more...

### Removed

-   Some insignificant stuff in the code.

## [1.0.1] - 2024-03-27

### Changed

-   Refactored Mod ID and directory names for better naming convension.

## [1.0.0] - 2024-03-26

### Added

-   Initial release. It's not much and there are probably lots of bugs and edge cases that weren't considered but it's a start.
