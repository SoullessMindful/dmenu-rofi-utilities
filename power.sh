power_menu() {
  local action=$(
    echo -e "🌛 Suspend\n🔁 Reboot\n🔌 Shutdown" |
    $LAUNCHER -i -p "$power_mode"
  )
  case $action in
    "🌛 Suspend")
      systemctl suspend
      ;;
    "🔁 Reboot")
      systemctl reboot
      ;;
    "🔌 Shutdown")
      systemctl poweroff
      ;;
  esac
}