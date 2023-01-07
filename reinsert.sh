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
cp dump_world_$BIN.json TEMP/DUMP
cp pointers_world_$BIN.json TEMP/DUMP
cp dump_menu_$BIN.json TEMP/DUMP
cp pointers_menu_$BIN.json TEMP/DUMP

# Espando i dump nei loro sottofile
python bof3tool.py expand --input-strings TEMP/DUMP/dump_world_$BIN.json --input-pointers TEMP/DUMP/pointers_world_$BIN.json -o TEMP/DUMP/$BIN
python bof3tool.py expand --input-strings TEMP/DUMP/dump_menu_$BIN.json --input-pointers TEMP/DUMP/pointers_menu_$BIN.json -o TEMP/DUMP/$BIN

# Reinserisco i dump in file binari in BIN
for file in TEMP/DUMP/$BIN/*.json
do
    filename=$(basename -- "$file")
    python bof3tool.py reinsert -i "$file" -o "TEMP/BIN/$BIN/${filename%.*}"
done

# TODO: copio le grafiche in TEMP/GFX

# TODO: converto tutte le grafiche in file RAW in BIN

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