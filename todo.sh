todo_menu() {
  local all_todos="☑️ Add"
  local todos
  todos=$(
    ls "$todo_directory" -t |
    grep -E "^✅ |^⬜ "
  )

  if [[ -n "$todos" ]]; then
    all_todos+=$'\n'
    all_todos+=$todos
  fi
  
  local todo=$(
    echo "$all_todos" |
    $LAUNCHER -i\
    -p "$todo_mode"
  )

  case $todo in
    "☑️ Add")
      todo_add
      ;;
    *)
      local todo_path=$(
        find "$todo_directory"\
        -type f -name "$todo"
      )
      if [[ -n "$todo_path" ]]; then
        local action=$(
          echo -e "☑️ Toggle checked\n🗑️ Remove\n↩️ Back" |
          $LAUNCHER -i -p "$todo"
        )
        case $action in
          "☑️ Toggle checked")
            if grep -q "^✅ " "$todo_path"; then
              (cd "$todo_directory" && mv "$todo_path" "${todo_path/✅ /⬜ }")
            else
              (cd "$todo_directory" && mv "$todo_path" "${todo_path/⬜ /✅ }")
            fi
            todo_menu
            ;;
          "🗑️ Remove")
            rm "$todo_path"
            todo_menu
            ;;
          "↩️ Back")
            todo_menu
            ;;
        esac
      fi
      ;;
  esac
}

todo_add() {
  local todo_name="$(
    date "+%Y-%m-%d %H-%M-%S"
  ) $(
    $LAUNCHER -i -p "Todo name"
  ).md"
  local todo_path="$todo_directory/⬜ $todo_name"
  touch "$todo_path"

  todo_menu
}
