#!/bin/bash
set -e

# VNC default no password
export X11VNC_AUTH="-nopw"

# look for VNC password file in order (first match is used)
passwd_files=(
  /home/chrome/.vnc/passwd
  /run/secrets/vncpasswd
)

for passwd_file in ${passwd_files[@]}; do
  if [[ -f ${passwd_file} ]]; then
    export X11VNC_AUTH="-rfbauth ${passwd_file}"
    break
  fi
done

# override above if VNC_PASSWORD env var is set (insecure!)
if [[ "$VNC_PASSWORD" != "" ]]; then
  export X11VNC_AUTH="-passwd $VNC_PASSWORD"
fi

# init
if ! id chrome &>/dev/null; then
  echo "Creating user..."
  useradd -m -G chrome-remote-desktop,pulse-access chrome
  usermod -s /bin/bash chrome
fi
if [[ ! -f /home/chrome/.initialized ]]; then
  mkdir -p /home/chrome/.config/chrome-remote-desktop
  mkdir -p /home/chrome/.fluxbox
  cp /usr/local/etc/fluxbox/* /home/chrome/.fluxbox/
  cp -r /usr/local/etc/tint2 /home/chrome/.config/
  chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox
  touch /home/chrome/.initialized
fi

# set sizes for both VNC screen & Chrome window
: ${VNC_SCREEN_SIZE:='1024x768'}
IFS='x' read SCREEN_WIDTH SCREEN_HEIGHT <<< "${VNC_SCREEN_SIZE}"
export VNC_SCREEN="${SCREEN_WIDTH}x${SCREEN_HEIGHT}x24"
export CHROME_WINDOW_SIZE="${SCREEN_WIDTH},${SCREEN_HEIGHT}"

export CHROME_OPTS="${CHROME_OPTS_OVERRIDE:- --user-data-dir --no-sandbox --window-position=0,0 --force-device-scale-factor=1 --disable-dev-shm-usage}"

exec "$@"
