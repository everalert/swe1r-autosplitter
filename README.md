# Star Wars Racer Autosplitter

Automatic control script for use in conjunction with the Scriptable Auto Splitter component for LiveSplit when timing Star Wars Episode I Racer speedruns on PC.

### Features

* Auto Start on file open.
* Auto Split on race completion.
* Auto Reset at file select.
* Customizable advanced settings to suit different categories.
* ASL Var Viewer compatibility.

## Instructions

### Prerequisites

This script is made for use with the re-released PC versions of Star Wars Racer (GOG, Steam, etc.), and will not work with the original CD version. You will also need:

* [LiveSplit](https://livesplit.org/)
* Scriptable Auto Splitter layout component (comes with LiveSplit)
* (OPTIONAL) [ASL Var Viewer](https://github.com/hawkerm/LiveSplit.ASLVarViewer/releases) layout component

### Basic Setup

In the LiveSplit Layout Editor, add the Scriptable Auto Splitter component (Add -> Control -> Scriptable Auto Splitter) to your layout.

![Adding the Scriptable Auto Splitter component](https://raw.githubusercontent.com/everalert/swe1r-autosplitter/master/img/add-autosplitter.png)

Then open Layout Settings, and select the Scriptable Auto Splitter tab. Under Script Path, click "Browse..." and navigate to "swe1r.asl", and click "Open" to add the script to the component.

![Click this button to add the script](https://raw.githubusercontent.com/everalert/swe1r-autosplitter/master/img/add-script.png)

At this stage, the autosplitter should be ready for real-time timing of most runs. To exclude load screens from run timing, see the Timing Without Load Screens section. The autosplitter behaviour is as follows:

* The timer will START when entering the Select Vehicle screen. This will happen when selecting "OK" on the file select screen, but also when backing out of the track select screen.
* The timer will SPLIT when completing a race while placing 3rd or better on Spice Mine Run, Bumpy's Breakers and The Boonta Classic, and when placing 4th or better on any other track. To modify this behaviour for 100% runs, see the Script Options section.
* The timer will RESET when entering the file select screen.

### Timing Without Load Screens

LiveSplit will display a Real Time timer by default. In Displaying a run time that does not count loading screens is achieved by setting the timer to display Game Time. This can be achieved in one of two ways:

1. Set a Timer or Detailed Timer component's Timing Method to Game Time: 

![Timer Component Settings](https://raw.githubusercontent.com/everalert/swe1r-autosplitter/master/img/use-gametime-timer.png)

2. Set a Timer or Detailed Timer component's Timing Method to Current Timing Method, and have LiveSplit compare against Game Time:

![Comparing Against Game Time](https://raw.githubusercontent.com/everalert/swe1r-autosplitter/master/img/use-gametime-comparison.png)

By default, the script detects load screens by checking whether the game increments its frame counter. As a side effect, any time spent tabbed out of the game will also be removed from the Game Time timer. It is recommended that the Experimental Load Removal option is enabled (see the Script Options section), which will attempt to include this time.

### Script Options

LiveSplit allows you to toggle automatic Starting, Splitting and Resetting of timers for all autosplitters. In addition, this script also comes with the following advanced options:

| Option | Description |
| - | - |
| Require 1st Place | The timer will not split unless the player wins the race. |
| Game Time Removes Loads | LiveSplit's Game Time timer will display real-time with load screen time excluded. When this option is disabled, Game Time will only include in-game race times. |
| Game Time Removes Unfocused Time | Time in which the game is not active (when closed, tabbed out, etc.) is also removed from the Game Time comparison. Requires "Game Time Removes Loads." |

The recommended settings for 100% runs are as follows:

* "Reset" disabled.
* "Require 1st Place" enabled.

### Showing Additional Run Information

Some extra information about a run can be displayed through the script in conjunction with ASL Var Viewer. First, download [ASL Var Viewer](https://github.com/hawkerm/LiveSplit.ASLVarViewer/releases) and install it to your LiveSplit "Components" directory, then:

1. Add the component to your layout via Add -> Information -> ASL Var Viewer
2. On the new ASL Var Viewer tab in the Layout Settings
   * Change the Value Container to "Variables"
   * Select the variable you would like to show from the "Value" dropdown menu.
   * Don't forget to give your Value Label a name!

Names of variables that have been designed for use with this component begin with "viewable". The following is a summary of these variables:

| Variable | Description |
| - | - |
| viewableRaceInGameTime        | Displays the total in-game race time for the current split only. This will include any time spent retrying tracks. |
| viewableTotalRaceInGameTime   | Displays the total in-game race time for the whole run. Can be used to display in-game time when Game Time is set to display real-time with load screen removal. |
| viewableOverheatCounter       | Increments when the player overheats, causing an engine fire. |
| viewableDeathCounter          | Increments when the player crashes. |

## Author

**Galeforce** (aka EVAL)
* Discord - Galeforce#3296
* [Twitter](https://twitter.com/everalert)
* [Twitch](https://twitch.tv/everalert)

While not direct contributors, the Racer Discord was instrumental in learning about the game memory in order to develop this script, in particular kingbeandip and LightningPirate.

## License

License-free. Do whatever you want to with this.

## Acknowledgements

* [CryZe](https://twitter.com/CryZe107)
* [wooferzfg](https://twitter.com/wooferzfg)
* kingbeandip (kingbeandip#9391)
* LightningPirate (LightningPirate#5872)
* The [Star Wars Episode I: Racer](https://discord.gg/28vrDPM) Discord Server