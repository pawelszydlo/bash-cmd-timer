# bash-cmd-timer
Display a timer in the upper-right hand side of your console, timing current command.

![screenshot](http://i.imgur.com/vcHKBgf.png)

###Quick Start
```bash
# Download the script:
curl https://raw.githubusercontent.com/pawelszydlo/bash-cmd-timer/master/cmd-timer.sh -o ~/.cmd-timer.sh
# Install:
source ~/.cmd-timer.sh install
```

###Uninstall
```bash
source ~/.cmd-timer.sh uninstall
```

###How it works?
The timer is started by the DEBUG trap and stopped throught PROMPT_COMMAND.

###Known issues
* On OSX the trap is not removed when uninstalling. It will disappear in your new session or you can remove it manually by running:
```bash
trap - DEBUG
```

###TODO
* Logging