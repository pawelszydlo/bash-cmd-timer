#!/bin/bash
#
# cmd-timer.sh -- Time current command execution in the corner of your terminal.
# https://github.com/pawelszydlo/bash-cmd-timer
#
# Author: Pawel Szydlo (pawelszydlo@gmail.com)


# Configuration
INSTALL_DEST="$HOME/.cmd-timer.sh"  # Where to install the script.
DELAY=2  # Delay before showing the timer, in seconds.
EXCLUDE=( vi vim less emacs ls )  # Do not time those commands.


# Print in the top-right corner
__print ()
{
	tput sc  # Save the cursor
   	tput cup 0 $((`tput cols` - ${#1} + 16))  # Move to upper right corner
   	echo -ne " $1 \r"
   	tput rc  # Restore cursor
} 


# Get time that passed.
__get_time ()
{
	seconds="$((`date +%s` - $CMDTIMER_START))";
	text=`printf '%02d:%02d:%02d' \
   		$(($seconds / 3600)) $(($seconds % 3600 / 60)) $(($seconds % 60))`
   	echo "$text"
}


# Run the timer.
__timer_start ()
{
	# Wait before starting.
	sleep $DELAY
	# Check if command name was passed.
	if [ ! -z $1 ]; then
		cmd="$1: "
	else
		cmd=''
	fi
	# Run until stopped.
	while true
	do
		sleep 0.1
   		__print "\033[1;33m$cmd$(__get_time)\033[0m"
	done
}


# Start the timer.
start ()
{
	# Check for excluded commands.
	for item in "${EXCLUDE[@]}"; do
    	if [[ $1 == "$item" ]]; then
    		return
    	fi
	done

	if [ -z "$CMDTIMER_PID" ]; then
		# Start the timer in the background and remember the PID.
		export CMDTIMER_START=`date +%s`
		__timer_start $1 &
		export CMDTIMER_PID=$!
	fi
}


# Finish the timer.
stop ()
{
	if [ ! -z "$CMDTIMER_PID" ]; then
		kill $CMDTIMER_PID 2> /dev/null
		wait $CMDTIMER_PID 2> /dev/null
		# Check if the timer had time to actually start.
		seconds="$((`date +%s` - $CMDTIMER_START))";
		if [ $seconds -gt $DELAY ]; then
			__print "\033[1;32m$(__get_time)\033[0m"
		fi
		unset CMDTIMER_PID
		unset CMDTIMER_START
	fi
}

# Install the handlers.
install ()
{
	echo "Copying script to $INSTALL_DEST..."
	cp "$(pwd)/$(basename $BASH_SOURCE)" ~/.cmd-timer.sh

	# This mechanism are highly unreliable, hence the checks when
	# starting/stopping the timer.
	echo "Setting handlers..."
	# Execute before each command
	trap 'source '$INSTALL_DEST' start $BASH_COMMAND' DEBUG
	# This command will be executed before each prompt, which means after
	# execution is finished.
	export PROMPT_COMMAND="source $INSTALL_DEST stop"

	echo "Adding timer handlers to your ~/.profile file..."
	echo "trap 'source "$INSTALL_DEST" start \$BASH_COMMAND' DEBUG" >> ~/.profile
	echo 'export PROMPT_COMMAND="source '$INSTALL_DEST' stop"' >> ~/.profile

	echo "Done."
}


# Uninstall everything.
uninstall ()
{
	echo "Removing the handlers..."
	trap - DEBUG  # This is not working! I have no idea why.
	stop

	echo "Removing variables..."
	unset PROMPT_COMMAND
	unset CMDTIMER_PID
	unset CMDTIMER_START

	echo "WARNING: All lines containing the string \"$INSTALL_DEST\" will be removed from your ~/.profile file. Press y to continue."
	read -p "" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
	    # Remove all lines containing the installation path.
		sed -i '' "/$(echo $INSTALL_DEST | sed -e 's/[\/&]/\\&/g')/d" ~/.profile
	else
		echo "Skipping ~/.profile cleanup."
	fi
	echo "Done."
}


# Check if script is being sourced, not run.
if [[ $_ = $0 ]]; then
	echo "This script uses global env variables and must be sourced. Run:"
	echo "source $0"
	exit 1
fi


# Hnadle parameters.
case "$1" in
	start)
	    start $2
	    ;;
	stop)
	    stop
	    ;;
	install)
	    install
	    ;;
	uninstall)
	    uninstall
	    ;;
	*)
	    echo $"Usage: $BASH_SOURCE {install|uninstall}"
esac
