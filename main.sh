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

whiteboard_menu() {
  local all_whiteboards="🧑🏻‍🏫 Add"
  local whiteboards
  whiteboards=$(
    find "$whiteboard_directory"\
    -type f\
    -name "*.xopp"\
    -printf "%f\n" |
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

