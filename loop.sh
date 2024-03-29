#!/bin/bash

# used in development

pidfn=/run/user/$UID/docbot

killpid() {
	# kill $(cat $pidfn)
	killall docbot
}

trap "killpid; exit" SIGINT SIGTERM EXIT

winid=$(getwinid)
base=$PWD

# export DOCBOT_CONF=bot/testdata/docbot.conf
export DOCBOT_CONF=local/prod-docbot.conf
export DOCBOT_CRED=local/docbot-mcpbot-key.json

set -x
while true
do
	padsp signalgen -t 100m sin 523 # C5

	echo =======================
	inotifywait -r -e modify *
	padsp signalgen -t 100m sin 262 # C4
	killpid
	sleep 1

	go vet ./... || continue

	padsp signalgen -t 100m sin 330 # E4 

	wmctrl -ia $winid
	go test -v ./... -coverprofile=/tmp/got.out -coverpkg=./... || continue
	padsp signalgen -t 100m sin 392 # G4
	## continue 

	# goenv exec go tool cover -html=/tmp/got.out -o /tmp/got.html
	# xdg-open /tmp/got.html
	# sleep 1

	if false && ! go run . ls 
	then
		echo "FAIL ls"
		padsp signalgen -t 100m sin 220 # A3
		wmctrl -ia $winid
		continue
	fi

	go run . serve &
	sleep 3
	if ! killall -0 docbot
	then
		echo "FAIL server start"
		padsp signalgen -t 100m sin 220 # A3
		wmctrl -ia $winid
		continue
	fi
	xdg-open http://localhost:8080

	sleep 1
done
