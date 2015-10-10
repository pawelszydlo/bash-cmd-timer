#!/bin/bash
#
# cmd-timer.sh -- Time current command execution in the corner of your terminal.
# https://github.com/pawelszydlo/bash-cmd-timer
#
# Author: Pawel Szydlo (pawelszydlo@gmail.com)
_CMDT_LAST_CMD=$_


###### CONFIGURATION ######


# Where to install the script.
_CMDT_INSTALL_DEST="$HOME/.cmd-timer.sh"
# Minimum time before starting the timer, in seconds.
_CMDT_DELAY=3
# Display live timer in the corner of your terminal.
_CMDT_LIVE_TIMER=true
# Print the summary after the command finishes.
_CMDT_SUMMARY=false
# Enable logging of execution time to file.
_CMDT_LOGGING=true
# Log file.
_CMDT_LOGFILE="$HOME/.cmd-timer.log"
# Do not time these commands. Arguments are matched if present, from the left.
_CMDT_EXCLUDE=( vi vim less emacs pv "tail -f" ssh telnet scp ftp man )


###### HELPERS ######


# Colour definitions.
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
WHITE="\033[1;37m"
RED="\033[1;31m"
PURPLE="\033[1;35m"
NOCOL="\033[0m"


###### FUNCTION DEFINITIONS ######


# Main.
_cmdt_main () {
    # Check if script is being sourced, not run.
    if [ "$_CMDT_LAST_CMD" = "$0" ]; then
        echo "This script uses global env variables and must be sourced. Run:"
        echo "source $0"
        exit 1
    fi

    # Load user config, if exists.
    if [ -r ~/.cmd-timer-conf.sh ]; then
        source ~/.cmd-timer-conf.sh
    fi

    # Handle parameters
    case "$1" in
        start)
            _cmdt_start "${@:2}"
            ;;
        stop)
            _cmdt_stop
            ;;
        install)
            _cmdt_install
            ;;
        uninstall)
            _cmdt_uninstall
            ;;
        *)
            echo $"Usage: source $BASH_SOURCE {install|uninstall}"
            return
    esac
}


# Get the correct profile file to install to.
_cmdt_get_profile () {
    if [ ! "$(shopt -q login_shell)" ]; then
        # It is a login shell.
        if [ -f "$HOME/.bash_profile" ]; then
            local profile_file="$HOME/.bash_profile"
        else
            local profile_file="$HOME/.profile"
        fi
    else
        # It is not a login shell.
        local profile_file="$HOME/.bashrc"
    fi
    echo "$profile_file"
}


# Print text in the top-right corner.
_cmdt_print () {
    tput sc  # Save the cursor
    tput cup 0 $(($(tput cols) - ${#1} + 15))  # Move to upper right corner
    echo -ne " $1 "
    tput rc  # Restore cursor
} 


# Get elapsed time.
_cmdt_get_time () {
    local seconds="$(($(date +%s) - $_CMDT_TIMER_START))";
    local text=$(printf '%02d:%02d:%02d' \
        $(($seconds / 3600)) $(($seconds % 3600 / 60)) $(($seconds % 60)))
    echo "$text"
}


# Run the timer.
_cmdt_live_timer_start () {
    # Wait before starting.
    sleep $_CMDT_DELAY
    # Check if command name was passed.
    if [ ! -z "$1" ]; then
        local cmd="$1: "
    else
        local cmd=''
    fi
    # Run until stopped.
    while true; do
        sleep 0.1 
        _cmdt_print "$YELLOW$cmd$(_cmdt_get_time)$NOCOL"
    done
}


# Print the summary.
_cmdt_summary () {
    echo -e "$PURPLE[ $_CMDT_TIMER_COMMAND ] executed in $1$NOCOL"
}


# Save the log.
_cmdt_log () {
    echo "$_CMDT_TIMER_START;$1;$2;${@:3}" >> $_CMDT_LOGFILE
}


# Start the timer.
_cmdt_start () {
    # Start only if no PID var found.
    if [ -z "$_CMDT_TIMER_PID" ]; then
        # Check for excluded commands.
        if [ ! $# -eq 0 ]; then
            for item in "${_CMDT_EXCLUDE[@]}"; do
                for i in $(seq 1 $#); do 
                    if [ "${*:1:$i}" = "$item" ]; then
                        return
                    fi
                done
            done
        fi
        # Start the timer in the background and remember the PID.
        export _CMDT_TIMER_START=$(date +%s)
        export _CMDT_TIMER_COMMAND="$@"
        if [ "$_CMDT_LIVE_TIMER" = true ]; then
            _cmdt_live_timer_start "$1" & disown
            export _CMDT_TIMER_PID=$!
        else
            # This var is used for checking if the timer is running, so set it.
            export _CMDT_TIMER_PID="DUMMY"
        fi
    fi
}


# Finish the timer.
_cmdt_stop () {
    # Stop only if PID var found.
    if [ ! -z "$_CMDT_TIMER_PID" ]; then
        kill $_CMDT_TIMER_PID 2> /dev/null
        wait $_CMDT_TIMER_PID 2> /dev/null
        
        # Check if the timer actually started.
        local seconds="$(($(date +%s) - $_CMDT_TIMER_START))";
        if [ $seconds -gt $_CMDT_DELAY ]; then
            local elapsed=$(_cmdt_get_time)
            # Print the summary if enabled.
            if [ "$_CMDT_SUMMARY" = true ]; then
                _cmdt_summary "$elapsed"
            fi
            # Save log if enabled
            if [ "$_CMDT_LOGGING" = true ]; then
                _cmdt_log "$elapsed" $_CMDT_TIMER_COMMAND
            fi
            # Make the live timer green, if enabled.
            if [ "$_CMDT_LIVE_TIMER" = true ]; then
                _cmdt_print "$GREEN$elapsed$NOCOL"
            fi

        fi
        unset _CMDT_TIMER_PID
        unset _CMDT_TIMER_COMMAND
        unset _CMDT_TIMER_START
    fi
}


# Install the handlers.
_cmdt_install () {
    local profile_file="$(_cmdt_get_profile)"
    echo "Copying script to $_CMDT_INSTALL_DEST..."
    cp "$BASH_SOURCE" "$_CMDT_INSTALL_DEST"

    # This mechanism is highly unreliable, hence the checks when
    # starting/stopping the timer.
    echo "Setting handlers..."
    # Execute before each command
    trap 'source '$_CMDT_INSTALL_DEST' start $BASH_COMMAND' DEBUG
    # This command will be executed before each prompt, which means after
    # execution is finished.
    export PROMPT_COMMAND="source $_CMDT_INSTALL_DEST stop"

    echo "Adding timer handlers to $profile_file..."
    echo "trap 'source "$_CMDT_INSTALL_DEST" start \$BASH_COMMAND' DEBUG" \
        >> "$profile_file"
    echo 'export PROMPT_COMMAND="source '$_CMDT_INSTALL_DEST' stop"' \
        >> "$profile_file"

    echo "Done."
}


# Uninstall everything.
_cmdt_uninstall () {
    local profile_file="$(_cmdt_get_profile)"
    echo "Removing the handlers..."
    trap - DEBUG  # This is not working! I have no idea why.
    _cmdt_stop

    echo "Removing variables..."
    unset PROMPT_COMMAND
    unset _CMDT_TIMER_PID
    unset _CMDT_TIMER_COMMAND
    unset _CMDT_TIMER_START

    echo -en "\nWARNING:\nAll lines containing \"$_CMDT_INSTALL_DEST\" will be " 
    echo "removed from $profile_file. Press y to continue."
    local reply
    read -n 1 reply
    echo
    if [ "$reply" = "y" ] || [ "$reply" = "Y" ]; then
        # Remove all lines containing the installation path.
        local needle=$(echo "$_CMDT_INSTALL_DEST" | sed -e 's/[\/&]/\\&/g')
        sed -i.ctbak "/$needle/d" "$profile_file"
        rm "${profile_file}.ctbak"
    else
        echo "Skipping cleanup."
    fi
    echo "Done."
}


###### RUN ######


# Run the script.
_cmdt_main "$@"
