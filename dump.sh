#!/bin/bash

BIN=$1
if [ -z "$1" ]; then
  echo "Errore: non è stata specificata una cartella con i dati da dumpare"
  exit 1
fi

# Rimuove le cartelle/file che non contengono testo da tradurre
dirs_to_delete="BENEMY BGM BMAG_XA BPLCHAR PLCHAR SCE_XA MODULE PSMF dummy.bin"

for dir in $dirs_to_delete; do
  if [ -d "$BIN/$dir" ]; then
    rm -rf "$BIN/$dir"
  fi
  if [ -f "$BIN/$dir" ]; then
    rm "$BIN/$dir"
  fi
done

# Rimuovi tutte le AREA non utilizzate per entrambe le versioni
files_to_delete="AREA006 AREA025 AREA029 AREA036 AREA063 AREA064 AREA070 AREA072 AREA073 AREA076 AREA084 AREA093 AREA102 AREA106 AREA109 AREA110 AREA124 AREA125 AREA127 AREA137 AREA138 AREA139 AREA146 AREA156 AREA158 AREA159 AREA160 AREA161 AREA162 AREA163 AREA190"

for file in $files_to_delete; do
  find $BIN -name "$file.EMI" -delete
done

# Unpack di tutti i file EMI
for dir in $BIN/*/
do
    dir=${dir%*/}
    if [ -d "$dir" ] && [ -n "$(find "$dir" -name '*.EMI' -print -quit)" ]; then
        python bof3tool.py unpack -i $dir/*.EMI -o UNPACKED/$dir --dump-text --dump-graphic
    fi
done

# Muovi i dump di tutti i testi WORLD nella cartella DUMP/piattaforma/WORLD
for world in WORLD00 WORLD01 WORLD02 WORLD03 WORLD04; do
  find UNPACKED/$BIN/$world/ -name "*.bin.json" -execdir sh -c "mkdir -p ../../../../DUMP/$BIN/WORLD && mv \$1 ../../../../DUMP/$BIN/WORLD" sh {} \;
done

# Muovi i dump di tutti i menu nella cartella DUMP/piattaforma/MENU
for menu in BATTLE BOSS ETC; do
  find UNPACKED/$BIN/$menu/ -name "*.bin.json" -execdir sh -c "mkdir -p ../../../../DUMP/$BIN/MENU && mv \$1 ../../../../DUMP/$BIN/MENU" sh {} \;
done

# Sposta tutte le grafiche in GFX/piattaforma
mkdir -p GFX/$BIN
find "UNPACKED/$BIN/" -name "*.bmp" -exec mv {} "GFX/$BIN" \;

# Crea la cartella dei file da iniettare
mkdir -p INJECT/$BIN

# Indicizza i dump di WORLD
python bof3tool.py index -i DUMP/$BIN/WORLD/*.json --output-strings DUMP/dump_world_$BIN.json --output-pointers DUMP/pointers_world_$BIN.json

# Indicizza i dump di MENU
python bof3tool.py index -i DUMP/$BIN/MENU/*.json --output-strings DUMP/dump_menu_$BIN.json --output-pointers DUMP/pointers_menu_$BIN.json