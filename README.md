# bash-cmd-timer
Display a timer in the upper-right hand side of your console, timing current command.

![screenshot](http://i.imgur.com/vcHKBgf.png)

###Quick Start
Download and install the script:
```bash
curl https://raw.githubusercontent.com/pawelszydlo/bash-cmd-timer/master/cmd-timer.sh -o ~/.cmd-timer.sh
source ~/.cmd-timer.sh install
```

####Features
* No effort required - install and it just works
* Highly configurable
* Live timer during command execution
* Summary after execution
* Logging of execution times
* Compatible with Linux and OS X


####Configuration 
Configuration can be done by editing variables at the beginning of the script or by overwriting them through user config.
The script will look for user config in:
```
~/.cmd-timer-conf.sh
```


###Uninstall
```bash
source ~/.cmd-timer.sh uninstall
```

###How it works?
The timer is started by the DEBUG trap and stopped throught PROMPT_COMMAND.

###Known issues
* Trap is not removed when uninstalling. It will disappear in your new session or you can remove it manually by running:
```bash
trap - DEBUG
```
####TODO
* Better way to display live timer.