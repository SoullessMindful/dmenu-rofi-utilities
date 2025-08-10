note_menu() {
  local all_notes="📑 Add"
  local notes
  notes=$(
    find "$note_directory"\
    -type f\
    -name "*.md"\
    -printf "%f\n" |
    sort -r
  )

  if [[ -n "$notes" ]]; then
    all_notes+=$'\n'
    all_notes+=$notes
  fi
  
  local note=$(
    echo "$all_notes" |
    $LAUNCHER -i\
    -p "$note_mode"
  )

  case $note in
    "📑 Add")
      note_add
      ;;
    *)
      local note_path=$(
        find "$note_directory"\
        -type f -name "$note"
      )
      if [[ -n "$note_path" ]]; then
        local action=$(
          echo -e "📑 Open\n🗑️ Remove\n↩️ Back" |
          $LAUNCHER -i -p "$note"
        )
        case $action in
          "📑 Open")
            $TERMINAL --class floating $EDITOR "$note_path"
            ;;
          "🗑️ Remove")
            rm "$note_path"
            note_menu
            ;;
          "↩️ Back")
            note_menu
            ;;
        esac
      fi
      ;;
  esac
}

note_add() {
  local note_name="$(
    date "+%Y-%m-%d %H-%M-%S"
  ) $(
    $LAUNCHER -i -p "Note name"
  ).md"
  local note_path="$note_directory/$note_name"
  touch "$note_path"
  echo -e "# $note_name\n" > "$note_path"

  $TERMINAL --class floating $EDITOR "$note_path"

  note_menu
}
