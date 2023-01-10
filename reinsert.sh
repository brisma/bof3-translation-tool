#!/bin/bash

BIN_TO_DUPLICATE="AREA005.11.bin AREA009.11.bin
AREA005.11.bin AREA010.11.bin
AREA005.11.bin AREA012.11.bin
AREA005.11.bin AREA018.11.bin
AREA005.11.bin AREA019.11.bin
AREA030.5.bin AREA089.5.bin
AREA030.5.bin AREA129.5.bin
AREA044.11.bin AREA048.11.bin
AREA095.11.bin AREA096.11.bin
AREA135.11.bin AREA136.11.bin
BATTLE.16.bin BATTLE2.16.bin
BATTLE.16.bin BOSS001.13.bin
BATTLE.16.bin BOSS002.16.bin
BATTLE.16.bin BOSS004.13.bin
BATTLE.16.bin BOSS007.16.bin
BATTLE.16.bin BOSS008.16.bin
BATTLE.16.bin BOSS012.16.bin
BATTLE.16.bin BOSS013.16.bin
BATTLE.16.bin BOSS014.16.bin
BATTLE.16.bin BOSS015.16.bin
BATTLE.16.bin BOSS017.16.bin
BATTLE.16.bin BOSS018.16.bin
BATTLE.16.bin BOSS019.16.bin
BATTLE.16.bin BOSS020.16.bin
BATTLE.16.bin BOSS021.16.bin
BATTLE.16.bin BOSS022.13.bin
BATTLE.16.bin BOSS023.16.bin
BATTLE.16.bin BOSS024.16.bin
BATTLE.16.bin BOSS025.13.bin
BATTLE.16.bin BOSS027.16.bin
BATTLE.16.bin BOSS028.16.bin
BATTLE.16.bin BOSS029.16.bin
BATTLE.16.bin BOSS030.16.bin
BATTLE.16.bin BOSS031.13.bin
BATTLE.16.bin BOSS032.16.bin
BATTLE.16.bin BOSS033.16.bin
BATTLE.16.bin BOSS034.16.bin
BATTLE.16.bin BOSS035.16.bin
BATTLE.16.bin BOSS036.16.bin
BATTLE.16.bin BOSS037.16.bin
BATTLE.16.bin BOSS038.16.bin
BATTLE.16.bin BOSS040.16.bin
BATTLE.16.bin BOSS042.16.bin
BATTLE.16.bin BOSS046.16.bin
BATTLE.16.bin BOSS047.16.bin
BATTLE.16.bin BOSS049.16.bin
BATTLE.16.bin BOSS050.16.bin
BATTLE.16.bin BOSS051.16.bin
BATTLE.16.bin BOSS052.16.bin
BATTLE.16.bin BOSS054.16.bin
BATTLE.16.bin BOSS055.16.bin
BATTLE.4.bin BATTLE2.4.bin
BATTLE.4.bin BOSS001.1.bin
BATTLE.4.bin BOSS002.4.bin
BATTLE.4.bin BOSS004.1.bin
BATTLE.4.bin BOSS007.4.bin
BATTLE.4.bin BOSS008.4.bin
BATTLE.4.bin BOSS012.4.bin
BATTLE.4.bin BOSS013.4.bin
BATTLE.4.bin BOSS014.4.bin
BATTLE.4.bin BOSS015.4.bin
BATTLE.4.bin BOSS017.4.bin
BATTLE.4.bin BOSS018.4.bin
BATTLE.4.bin BOSS019.4.bin
BATTLE.4.bin BOSS020.4.bin
BATTLE.4.bin BOSS021.4.bin
BATTLE.4.bin BOSS022.1.bin
BATTLE.4.bin BOSS023.4.bin
BATTLE.4.bin BOSS024.4.bin
BATTLE.4.bin BOSS025.1.bin
BATTLE.4.bin BOSS027.4.bin
BATTLE.4.bin BOSS028.4.bin
BATTLE.4.bin BOSS029.4.bin
BATTLE.4.bin BOSS030.4.bin
BATTLE.4.bin BOSS031.1.bin
BATTLE.4.bin BOSS032.4.bin
BATTLE.4.bin BOSS033.4.bin
BATTLE.4.bin BOSS034.4.bin
BATTLE.4.bin BOSS035.4.bin
BATTLE.4.bin BOSS036.4.bin
BATTLE.4.bin BOSS037.4.bin
BATTLE.4.bin BOSS038.4.bin
BATTLE.4.bin BOSS040.4.bin
BATTLE.4.bin BOSS042.4.bin
BATTLE.4.bin BOSS046.4.bin
BATTLE.4.bin BOSS047.4.bin
BATTLE.4.bin BOSS049.4.bin
BATTLE.4.bin BOSS050.4.bin
BATTLE.4.bin BOSS051.4.bin
BATTLE.4.bin BOSS052.4.bin
BATTLE.4.bin BOSS054.4.bin
BATTLE.4.bin BOSS055.4.bin
BOSS025.14.bin BOSS027.17.bin
COMMU00.1.bin AREA175.15.bin
COMMU00.1.bin AREA176.15.bin
COMMU00.1.bin AREA177.15.bin
COMMU00.1.bin AREA178.15.bin
COMMU00.1.bin AREA179.15.bin
COMMU00.1.bin AREA180.15.bin
COMMU00.1.bin AREA181.15.bin
COMMU00.1.bin AREA182.15.bin
COMMU00.1.bin AREA183.15.bin
COMMU00.1.bin AREA184.15.bin
COMMU00.1.bin AREA185.15.bin
COMMU02.9.bin COMMU02B.8.bin
START.9.bin STATUS.1.bin"

GFX_TO_DUPLICATE="DEMO.6.bin TURISHAR.3.bin
DEMO.5.bin TURISHAR.2.bin
MAGIC008.2.bin MAGIC013.5.bin
MAGIC008.2.bin MAGIC038.8.bin
MAGIC008.2.bin MAGIC039.5.bin
MAGIC008.2.bin MAGIC040.5.bin
MAGIC008.2.bin MAGIC043.5.bin
MAGIC008.2.bin MAGIC062.5.bin
MAGIC008.2.bin MAGIC069.5.bin
MAGIC008.2.bin MAGIC082.5.bin
MAGIC008.2.bin MAGIC083.5.bin
MAGIC008.2.bin MAGIC088.5.bin
MAGIC008.2.bin MAGIC225.5.bin
BATE.2.bin COMMU01.1.bin
BATE.2.bin COMMU02B.1.bin
BATE.2.bin COMMU05.1.bin
BATE.2.bin SHISU.2.bin
BATE.2.bin SHOP.2.bin
BATE.2.bin SISYOU.2.bin
BATE.2.bin START.4.bin
BATE.2.bin STATUS.2.bin
BATE.2.bin AREA030.21.bin
BATE.2.bin AREA089.21.bin
BATE.2.bin AREA129.21.bin
AREA030.14.bin TURIMODE.4.bin
AREA151.6.bin AREA152.6.bin"

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
done <<< "$GFX_TO_DUPLICATE"

# Copio i file binari e duplico i mancanti
if [ "$(ls -A BINARY/$BIN)" ]; then
  cp -R BINARY/$BIN/* TEMP/BIN/$BIN
fi
while read -r original duplicate; do
  if [ -f "TEMP/BIN/$BIN/$original" ]; then
    cp TEMP/BIN/$BIN/$original TEMP/BIN/$BIN/$duplicate
  fi
done <<< "$BIN_TO_DUPLICATE"

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