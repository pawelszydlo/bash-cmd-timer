# bash-cmd-timer
Live timer and logger of command execution times.

### Quick Start
Download and install the script:
```bash
curl https://raw.githubusercontent.com/pawelszydlo/bash-cmd-timer/master/cmd-timer -o ~/.cmd-timer
source ~/.cmd-timer install
```
File will be downloaded and appropriate entries will be added to your _.bashrc_ or _.profile_ file.
Alias _cmdt_ will be created for your convenience.

### Features
![screenshot](http://szydlo.eu/wp-content/uploads/2015/10/cmd-timer.png)

* No effort required - install and it just works
* Highly configurable
* Live timer during command execution
* Summary after execution
* Logging of execution times
* Exclude certain commands, including parameter checking
* Callback after a command finishes
* Compatible with Linux and OS X


### Configuration 
Configuration can be done by editing variables at the beginning of the script or by overwriting them through user config.
The script will look for user config in:
```
~/.cmd-timer-conf
```
Possible options and their defaults:
```bash
# Where to install the script.
_CMDT_INSTALL_DEST="$HOME/.cmd-timer"

# Minimum time before starting the timer, in seconds.
_CMDT_DELAY=3

# Display live timer in the corner of your terminal.
_CMDT_LIVE_TIMER=true

# Display the timer in the terminal title.
_CMDT_LIVE_TIMER_TITLE=true

# Print the summary after the command finishes.
_CMDT_SUMMARY=false

# Enable logging of execution time to file.
_CMDT_LOGGING=true

# Log file.
_CMDT_LOGFILE="$HOME/.cmd-timer.log"

# Do not time these commands. Arguments are matched if present, from the left.
_CMDT_EXCLUDE=( vi vim less emacs pv "tail -f" ssh telnet scp ftp man htop top 
    su screen irrsi irc "sudo -s" )

# Callback to execute after the timer finishes. It will be passed to eval.
_CMDT_CALLBACK='echo -ne \\007'
```

### Update
Script can automatically update itself from latest repository version.
```bash
cmdt update
```

### Uninstall
```bash
cmdt uninstall
```

### Log format
Data is logged as a semicolon separated list, each entry in a new line.
```
timestamp ; timer ; command ; parameters
```

### How does it work?
The timer is started by the DEBUG trap and stopped throught PROMPT_COMMAND.

### Known issues
* Trap is not removed when uninstalling. It will disappear in your new session or you can remove it manually by running:
```bash
trap - DEBUG
```
* Problems with pipes!
### TODO
* Better list of commands to exclude from timing
