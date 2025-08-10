whiteboard_menu() {
  local all_whiteboards="🧑🏻‍🏫 Add"
  local whiteboards
  whiteboards=$(
    find "$whiteboard_directory"\
    -type f\
    -printf "%P\n" |
    grep -E "$whiteboard_ext" |
    sort -r
  )

  if [[ -n "$whiteboards" ]]; then
    all_whiteboards+=$'\n'
    all_whiteboards+=$whiteboards
  fi
  
  local whiteboard=$(
    echo "$all_whiteboards" |
    $LAUNCHER -i\
    -p "$whiteboard_mode"
  )

  case $whiteboard in
    "🧑🏻‍🏫 Add")
      whiteboard_add
      ;;
    *)
      local whiteboard_path=$(
        find "$whiteboard_directory"\
        -type f -name "$whiteboard"
      )
      if [[ -n "$whiteboard_path" ]]; then
        local action=$(
          echo -e "📑 Open\n🗑️ Remove\n↩️ Back" |
          $LAUNCHER -i -p "$note"
        )
        case $action in
          "📑 Open")
            $whiteboard_cmd "$whiteboard_path"
            ;;
          "🗑️ Remove")
            rm "$whiteboard_path"
            whiteboard_menu
            ;;
          "↩️ Back")
            whiteboard_menu
            ;;
        esac
      fi
      ;;
  esac
}

whiteboard_add() {
  local whiteboard_name="$(
    date "+%Y-%m-%d %H-%M-%S"
  ) $(
    $LAUNCHER -i -p "Whiteboard name"
  ).xopp"
  local whiteboard_path="$whiteboard_directory/$whiteboard_name"
  cp "$whiteboard_template" "$whiteboard_path"

  $whiteboard_cmd "$whiteboard_path"
}
