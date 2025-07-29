#!/bin/sh

LAUNCHER="rofi -dmenu" # LAUNCHER=dmenu
TERMINAL=kitty
EDITOR=nvim
VIEWER=zathura

emojis=📗📘📙📜📃📓🗒️📝✒️🖊️🖋️✏️📋🧑🏻‍🏫📈📉📊✅☑️❎⬜🎶🎵▶️⏯️⏸️⏹️🗑️↩️🎥📽️📀🎬⚙️📶🌐🕸️

modes=""

note_mode="📑 Notes"
note_directory="/data/notes/"
modes+=$note_mode

todo_mode="☑️ Todos"
todo_directory="/data/todos/"
modes+="\n"
modes+=$todo_mode

list_mode="📃 Lists"
list_directory="/data/lists/"
modes+="\n"
modes+=$list_mode

book_mode="📘 Books"
book_directory="/data/books/"
book_ext=".pdf$|.djvu$|.epub$"
modes+="\n"
modes+=$book_mode

article_mode="📜 Articles"
article_directory="/data/articles/"
article_ext=".pdf$|.djvu$"
modes+="\n"
modes+=$article_mode

# by default requires xournalpp
# can be replaced with any other whiteboard application
whiteboard_mode="🧑🏻‍🏫 Whiteboards"
whiteboard_directory="/data/whiteboards/"
whiteboard_cmd="xournalpp"
whiteboard_ext=".xopp$"
whiteboard_template="$(pwd)/whiteboard_template.xopp"
modes+="\n"
modes+=$whiteboard_mode

power_mode="⚡ Power"
modes+="\n"
modes+=$power_mode
