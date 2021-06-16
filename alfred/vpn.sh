#!/bin/bash

CONNECTION_REGEX='^(\*| ) +\(([[:alnum:]]+)\) +([-[:alnum:]]+) +([[:alnum:]]+) +"([^"]+)" +\[([[:alnum:]]+)\]$'

getCommand() {
  if [[ "connect" = $1* ]]; then
    echo -n "connect";
  elif [[ "reconnect" = $1* ]]; then
    echo -n "reconnect";
  elif [[ "disconnect" = $1* ]]; then
    echo -n "disconnect";
  elif [[ "status" = $1* ]]; then
    echo -n "status";
  else
    echo -n "unknown";
  fi
}

shCmd() {
  if [ "X$1" = "Xconnect" ]; then
    echo "scutil --nc start $2";
  elif [ "X$1" = "Xreconnect" ]; then
    echo "scutil --nc stop $2; scutil --nc start $2";
  elif [ "X$1" = "Xdisconnect" ]; then
    echo "scutil --nc stop $2";
  else
    echo "echo $2";
  fi
}

main() {
  if [ $# -lt 1 ]; then
    cat << EOF
{
  "items": [
    {
      "valid": false,
      "icon": {
        "path": "up.png"
      },
      "uid": "connect",
      "title": "connect",
      "autocomplete": "connect "
    },
    {
      "valid": false,
      "icon": {
        "path": "up-down.png"
      },
      "uid": "reconnect",
      "title": "reconnect",
      "autocomplete": "reconnect "
    },
    {
      "valid": false,
      "icon": {
        "path": "down.png"
      },
      "uid": "disconnect",
      "title": "disconnect",
      "autocomplete": "disconnect "
    },
    {
      "valid": false,
      "icon": {
        "path": "right-left.png"
      },
      "uid": "status",
      "title": "status",
      "autocomplete": "status "
    }
  ]
}
EOF
  else
    local COMMAND=`getCommand $1`;
    shift;
    cat << EOF
{
  "rerun": 5,
  "items": [
EOF
    scutil --nc list | tail -n +2 | while IFS= read -r c; do
      if [[ "$c" =~ $CONNECTION_REGEX ]]; then
        local VALID=`[ "X$COMMAND" != "Xstatus" ] && [ '*' = "${BASH_REMATCH[1]}" ] && echo "true" || echo "false"`
        local STATUS="${BASH_REMATCH[2]}"
        local UUID="${BASH_REMATCH[3]}";
        local NAME="${BASH_REMATCH[5]}";
        local SEARCH="`echo \"$@\" | tr [:upper:] [:lower:]`";
        local LNAME="`echo \"$NAME\" | tr [:upper:] [:lower:]`";
        ( [ "X$@" = "X" ] || [[ $LNAME = *$SEARCH* ]] ) && cat << EOF
    {
      "valid": $VALID,
      "uid": "$UUID",
      "title": "$NAME",
      "subtitle": "Status: $STATUS",
      "arg": "`shCmd "$COMMAND" "$UUID"`"
    },
EOF
      fi
    done
    cat << EOF
  ]
}
EOF
  fi
  return 0;
}

main $@
