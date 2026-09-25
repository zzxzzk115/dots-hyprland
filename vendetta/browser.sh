#!/bin/sh
case ${XDG_CURRENT_DESKTOP:-} in
 *Hyprland*|*hyprland*) ;;
 *) exec /usr/bin/microsoft-edge "$@" ;;
esac
if [ "$XDG_CONFIG_HOME" = "$HOME/.config/hypr/end4-session" ]; then
 unset XDG_CONFIG_HOME XDG_STATE_HOME XDG_CACHE_HOME
fi
unset LD_LIBRARY_PATH QT_PLUGIN_PATH QML_IMPORT_PATH QML2_IMPORT_PATH QT_QPA_PLATFORMTHEME QT_QPA_PLATFORM
exec /usr/bin/microsoft-edge --ozone-platform=wayland --enable-wayland-ime --qt-version=6 "$@"
