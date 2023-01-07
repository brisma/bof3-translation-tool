#!/bin/bash

BIN=$1
if [ -z "$1" ]; then
  echo "Errore: non è stata specificata una cartella con i dati da dumpare"
  exit 1
fi

# Rimuovi tutte le AREA non utilizzate per entrambe le versioni
files_to_delete="AREA006 AREA025 AREA029 AREA036 AREA063 AREA064 AREA070 AREA072 AREA073 AREA076 AREA084 AREA093 AREA102 AREA106 AREA109 AREA110 AREA124 AREA125 AREA127 AREA137 AREA138 AREA139 AREA146 AREA156 AREA158 AREA159 AREA160 AREA161 AREA162 AREA163 AREA190"

for file in $files_to_delete; do
  find $BIN -name "$file.EMI" -delete
done

# Unpack di tutti i file EMI
for dir in $BIN/*/
do
    dir=${dir%*/}
    if [ -d "$dir" ]; then
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

# Sposta tutte le grafiche in GFX
mkdir -p GFX/$BIN
rsync -aim --include="*/" --include="*.bmp" --exclude="*" --delete-excluded UNPACKED/$BIN/ GFX/$BIN

# Indicizza i dump di WORLD
python bof3tool.py index -i DUMP/$BIN/WORLD/*.json --output-strings dump_world_$BIN.json --output-pointers pointers_world_$BIN.json

# Indicizza i dump di MENU
python bof3tool.py index -i DUMP/$BIN/MENU/*.json --output-strings dump_menu_$BIN.json --output-pointers pointers_menu_$BIN.json