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
