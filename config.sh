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

power_mode="⚡ Power"
modes+="\n"
modes+=$power_mode
