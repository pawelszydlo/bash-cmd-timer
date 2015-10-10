# bash-cmd-timer
Display a timer in the upper-right hand side of your console, timing current command.

![screenshot](http://i.imgur.com/vcHKBgf.png)

###Quick Start
Download and install the script:
```bash
curl https://raw.githubusercontent.com/pawelszydlo/bash-cmd-timer/master/cmd-timer -o ~/.cmd-timer
source ~/.cmd-timer install
```

###Features
* No effort required - install and it just works
* Highly configurable
* Live timer during command execution
* Summary after execution
* Logging of execution times
* Exclude certain commands, including parameter checking
* Compatible with Linux and OS X


###Configuration 
Configuration can be done by editing variables at the beginning of the script or by overwriting them through user config.
The script will look for user config in:
```
~/.cmd-timer-conf
```


###Uninstall
```bash
source ~/.cmd-timer uninstall
```

###Log format
Data is logged as a semicolon separated list, each entry in a new line.
```
timestamp ; timer ; command ; parameters
```

###How does it work?
The timer is started by the DEBUG trap and stopped throught PROMPT_COMMAND.

###Known issues
* Trap is not removed when uninstalling. It will disappear in your new session or you can remove it manually by running:
```bash
trap - DEBUG
```
###TODO
* Better way to display live timer
* Better list of commands to exclude from timing
