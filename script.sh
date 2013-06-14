#!/usr/bin/env bash
# To run: 
#   bash < <(curl -s https://github.com/$author_name/$base_name/raw/$tag/install)

url=

function show_usage () {
  cat <<USAGE
usage: $0 options 

OPTIONS
    -h|--help       Display this message
	-u|--update		Update the script
USAGE
}

runSelfUpdate() {
  echo "Performing self-update..."

  # Download new version
  echo -n "Downloading latest version..."
  if ! wget --quiet --output-document="$0.tmp" $url ; then
    echo "Failed: Error while trying to wget new version!"
    echo "File requested: $UPDATE_BASE/$SELF"
    exit 1
  fi
  echo "Done."

  # Copy over modes from old version
  OCTAL_MODE=$(stat -c '%a' $SELF)
  if ! chmod $OCTAL_MODE "$0.tmp" ; then
    echo "Failed: Error while trying to set mode on $0.tmp."
    exit 1
  fi

  # Spawn update script
  cat > updateScript.sh << EOF
#!/bin/bash
# Overwrite old file with new
if mv "$0.tmp" "$0"; then
  echo "Done. Update complete."
  rm \$0
else
  echo "Failed!"
fi
EOF

  echo -n "Inserting update process..."
  exec /bin/bash updateScript.sh
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    -u|--update)
      runSelfUpdate
      exit 1
      ;;
    *)
      show_usage
      exit 1
      ;;
  esac
  shift
done
