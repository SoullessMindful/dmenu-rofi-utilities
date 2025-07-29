#!/bin/sh

source ./config.sh

document_menu() {
  local directory=$1
  local document_kind=$2
  local document_ext=$3
  echo $document_ext
  local files
  files=$(
    cd "$directory" &&
    find .\
    -type f\
    -printf "%P\n" |
    grep -E "$document_ext" |
    sort
  )
  local file=$(
    echo "$files" |
    $LAUNCHER -i\
    -p "$document_kind"
  )
  local file_path=$(
    find "$directory"\
    -type f -wholename "*/$file"
  )
  if [[ -n "$file_path" ]]; then
    $VIEWER "$file_path"
  fi
}

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

list_menu() {
  local all_lists="📃 Add"
  local lists
  lists=$(
    ls "$list_directory" -t
  )

  if [[ -n "$lists" ]]; then
    all_lists+=$'\n'
    all_lists+=$lists
  fi
  
  local list=$(
    echo "$all_lists" |
    $LAUNCHER -i\
    -p "$list_mode"
  )

  case $list in
    "📃 Add")
      list_add
      ;;
    *)
      list_inner_menu "$list"
      ;;
  esac
}

list_inner_menu() {
  local list_name="$1"
  local list_path=$(
    find "$list_directory"\
    -type f -name "$list_name"
  )
  if [[ -n "$list_path" ]]; then
    local all_list_items="📃 Add item"
    local list_items=$(cat "$list_path")
    
    if [[ -n "$list_items" ]]; then
      all_list_items+=$'\n'
      all_list_items+=$list_items
    fi

    all_list_items+="\n📝 Rename list\n📝 Edit list\n🗑️ Remove list\n↩️ Back"

    local list_item=$(
      echo -e "$all_list_items" |
      $LAUNCHER -i\
      -p "$list_name"
    )

    case $list_item in
      "📃 Add item")
        local item_content="$(
          $LAUNCHER -i -p "Item content"
        )"

        if [[ -n "$item_content" ]]; then
          echo "$item_content" >> "$list_path"
        fi

        list_inner_menu "$list_name"
        ;;
      "📝 Rename list")
        local new_list_name="$(
          $LAUNCHER -i -p "New name"\
          -filter "$list_name"
        )"
        
        if [[ -n "$new_list_name" ]]; then
          local new_list_path="$list_directory/$new_list_name"
          mv "$list_path" "$new_list_path"
          list_inner_menu "$new_list_name"
        else
          list_inner_menu "$list_name"
        fi
        ;;
      "📝 Edit list")
        $TERMINAL --class floating $EDITOR "$list_path"
        list_inner_menu "$list_name"
        ;;
      "🗑️ Remove list")
        rm "$list_path"
        list_menu
        ;;
      "↩️ Back")
        list_menu
        ;;
      "");;
      *)
        if grep -q "^$list_item\$" "$list_path"; then
          local action=$(
            echo -e "📝 Rename item\n🗑️ Remove item\n↩️ Back" |
            $LAUNCHER -i -p "$list_item"
          )
          case $action in
            "📝 Rename item")
              local new_content="$(
                $LAUNCHER -i -p "New item content"\
                -filter "$list_item"
              )"
              if [[ -n "$new_content" ]]; then
                sed -i "s/^$list_item\$/$new_content/" "$list_path"
              fi
              list_inner_menu "$list_name"
              ;;
            "🗑️ Remove item")
              sed -i "/^$list_item$/d" "$list_path"
              list_inner_menu "$list_name"
              ;;
            "");;
            "↩️ Back" | *)
              list_inner_menu "$list_name"
              ;;
          esac
        fi
        ;;
    esac
  fi
}

list_add() {
  local list_name="$(
    $LAUNCHER -i -p "List name"
  )"
  local list_path="$list_directory/$list_name"
  touch "$list_path"

  list_inner_menu "$list_name"
}

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

main() {
  local mode=$(
    echo -e $modes |
    $LAUNCHER -i -p ""
  )

  case $mode in
    $note_mode)
      note_menu
      ;;
    $todo_mode)
      todo_menu
      ;;
    $list_mode)
      list_menu
      ;;
    $book_mode)
      document_menu "$book_directory" "$mode" "$book_ext"
      ;;
    $article_mode)
      document_menu "$article_directory" "$mode" "$article_ext"
      ;;
    $whiteboard_mode)
      whiteboard_menu
      ;;
    $power_mode)
      power_menu
      ;;
  esac
}

main

