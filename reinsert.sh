#!/bin/bash

BIN=$1
if [ -z "$1" ]; then
  echo "Errore: non è stata specificata la cartella da ricostruire"
  exit 1
fi

# Creo la cartella TEMP (e la elimino se esiste già)
if [ -d "TEMP" ]; then
  rm -r "TEMP"
fi
mkdir -p TEMP/DUMP

# Copio dump e puntatori in TEMP/DUMP
cp DUMP/dump_world_$BIN.json TEMP/DUMP
cp DUMP/pointers_world_$BIN.json TEMP/DUMP
cp DUMP/dump_menu_$BIN.json TEMP/DUMP
cp DUMP/pointers_menu_$BIN.json TEMP/DUMP

# Espando i dump nei loro sottofile
python bof3tool.py expand --input-strings TEMP/DUMP/dump_world_$BIN.json --input-pointers TEMP/DUMP/pointers_world_$BIN.json -o TEMP/DUMP/$BIN
python bof3tool.py expand --input-strings TEMP/DUMP/dump_menu_$BIN.json --input-pointers TEMP/DUMP/pointers_menu_$BIN.json -o TEMP/DUMP/$BIN

# Reinserisco i dump in file binari in BIN
for file in TEMP/DUMP/$BIN/*.json
do
    filename=$(basename -- "$file")
    python bof3tool.py reinsert -i "$file" -o "TEMP/BIN/$BIN/${filename%.*}"
done

# Copio le grafiche in TEMP/GFX
mkdir -p TEMP/GFX/$BIN
cp -r GFX/$BIN TEMP/GFX

# Converto tutte le grafiche in file RAW in BIN
for file in TEMP/GFX/$BIN/*.bmp
do
    bin_name=$(echo $(basename $file) | cut -d'.' -f1-3)
    bpp=$(echo $file | cut -d'.' -f4 | cut -d'b' -f1)
    tile_w_h=$(echo $file | cut -d'.' -f6)
    tile_w=$(echo $tile_w_h | cut -d'x' -f1)
    tile_h=$(echo $tile_w_h | cut -d'x' -f2)
    resize_width=$(echo $file | cut -d'.' -f5 | cut -d'w' -f1)
    python bof3tool.py bmp2raw -i "$file" -o "TEMP/BIN/$BIN/$bin_name" --bpp "$bpp" --tile-width "$tile_w" --tile-height "$tile_h" --resize-width "$resize_width"
done

# Duplico le grafiche necessarie
while read -r original duplicate; do
  if [ -f "TEMP/BIN/$BIN/$original" ]; then
    cp TEMP/BIN/$BIN/$original TEMP/BIN/$BIN/$duplicate
  fi
done < gfx_to_duplicate.txt

# Copio i file binari e duplico i mancanti
if [ "$(ls -A BINARY/$BIN)" ]; then
  cp -R BINARY/$BIN/* TEMP/BIN/$BIN
fi
while read -r original duplicate; do
  if [ -f "TEMP/BIN/$BIN/$original" ]; then
    cp TEMP/BIN/$BIN/$original TEMP/BIN/$BIN/$duplicate
  fi
done < bin_to_duplicate.txt

# Copio i file da iniettare
if [ "$(ls -A INJECT/$BIN)" ]; then
  cp -R INJECT/$BIN/* TEMP/BIN/$BIN
fi

# Copio la cartella contenente i file EMI spacchettati in TEMP
cp -R UNPACKED/$BIN TEMP

# Sostituisco i nuovi file binari creati (dump/gfx) nelle cartelle dei file spacchettati temporanee
for file in $(find TEMP/$BIN -type f)
do
  filename=$(basename "$file")
  if [ -f "TEMP/BIN/$BIN/$filename" ]
  then
    cp -v "TEMP/BIN/$BIN/$filename" "$file"
  fi
done

# Reimpacchetta tutti i file JSON in file EMI
for file in $(find TEMP/$BIN -type f -name '*.json')
do
  dir=$(dirname "$file")
  python bof3tool.py pack -i "$file" -o "$dir"
done

# Creo la cartella di OUTPUT
mkdir -p OUTPUT/$BIN

# Copia tutti i file EMI rigenerati in OUTPUT preservando l'alberatura
rsync -aim --include="*/" --include="*.EMI" --exclude="*" --delete-excluded TEMP/$BIN/ OUTPUT/$BIN

# Elimino la cartella TEMP
rm -rf TEMP

# Verifico se il contenuto dei nuovi file è cambiato, se non lo è li cancello
for file in $(find "$BIN" -type f); do
  echo $file
  if [ -f "OUTPUT/$file" ]; then
    diff "$file" "OUTPUT/$file"
    if [ $? -eq 0 ]; then
      rm "OUTPUT/$file"
    fi
  fi
done

find "OUTPUT/$BIN" -type d -empty -delete