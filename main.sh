#!/bin/sh

source ./config.sh

source ./document.sh
source ./note.sh
source ./todo.sh
source ./list.sh
source ./whiteboard.sh
source ./power.sh

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
    $draw_on_screen_mode)
      $draw_on_screen_cmd
      ;;
    $power_mode)
      power_menu
      ;;
  esac
}

main

