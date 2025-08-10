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
