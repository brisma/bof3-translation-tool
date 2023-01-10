#!/bin/bash

BIN_TO_EXPORT="BATTLE/BATTLE/BATTLE.16.bin
BATTLE/BATTLE/BATTLE.4.bin
BMAGIC/MAGIC003/MAGIC003.4.bin
BMAGIC/MAGIC060/MAGIC060.1.bin
BOSS/BOSS025/BOSS025.14.bin
ETC/BATE/BATE.1.bin
ETC/COMMU00/COMMU00.1.bin
ETC/COMMU01/COMMU01.8.bin
ETC/COMMU02/COMMU02.9.bin
ETC/COMMU03/COMMU03.7.bin
ETC/COMMU05/COMMU05.8.bin
ETC/GAME/GAME.1.bin
ETC/SHISU/SHISU.1.bin
ETC/SHOP/SHOP.1.bin
ETC/SISYOU/SISYOU.1.bin
ETC/START/START.9.bin
SCENARIO/SCENA10/SCENA10.1.bin
SCENARIO/SCENA17/SCENA17.1.bin
WORLD00/AREA002/AREA002.14.bin
WORLD00/AREA003/AREA003.11.bin
WORLD00/AREA005/AREA005.11.bin
WORLD00/AREA008/AREA008.11.bin
WORLD00/AREA015/AREA015.11.bin
WORLD00/AREA020/AREA020.11.bin
WORLD00/AREA022/AREA022.11.bin
WORLD00/AREA023/AREA023.11.bin
WORLD00/AREA027/AREA027.11.bin
WORLD00/AREA028/AREA028.11.bin
WORLD00/AREA030/AREA030.5.bin
WORLD00/AREA032/AREA032.11.bin
WORLD00/AREA035/AREA035.11.bin
WORLD01/AREA040/AREA040.11.bin
WORLD01/AREA042/AREA042.11.bin
WORLD01/AREA044/AREA044.11.bin
WORLD01/AREA051/AREA051.11.bin
WORLD01/AREA052/AREA052.11.bin
WORLD01/AREA054/AREA054.11.bin
WORLD01/AREA056/AREA056.11.bin
WORLD01/AREA067/AREA067.11.bin
WORLD01/AREA069/AREA069.11.bin
WORLD01/AREA071/AREA071.11.bin
WORLD01/AREA075/AREA075.11.bin
WORLD02/AREA077/AREA077.11.bin
WORLD02/AREA080/AREA080.11.bin
WORLD02/AREA082/AREA082.11.bin
WORLD02/AREA083/AREA083.11.bin
WORLD02/AREA086/AREA086.11.bin
WORLD02/AREA091/AREA091.11.bin
WORLD02/AREA095/AREA095.11.bin
WORLD02/AREA099/AREA099.11.bin
WORLD02/AREA103/AREA103.11.bin
WORLD02/AREA105/AREA105.11.bin
WORLD02/AREA107/AREA107.11.bin
WORLD02/AREA108/AREA108.11.bin
WORLD02/AREA111/AREA111.11.bin
WORLD02/AREA112/AREA112.11.bin
WORLD03/AREA117/AREA117.11.bin
WORLD03/AREA118/AREA118.11.bin
WORLD03/AREA119/AREA119.11.bin
WORLD03/AREA120/AREA120.11.bin
WORLD03/AREA134/AREA134.11.bin
WORLD03/AREA135/AREA135.11.bin
WORLD03/AREA140/AREA140.11.bin
WORLD03/AREA141/AREA141.11.bin
WORLD03/AREA142/AREA142.11.bin
WORLD03/AREA144/AREA144.11.bin
WORLD03/AREA145/AREA145.11.bin
WORLD04/AREA164/AREA164.11.bin
WORLD04/AREA165/AREA165.11.bin
WORLD04/AREA166/AREA166.11.bin
WORLD04/AREA167/AREA167.11.bin
WORLD04/AREA168/AREA168.11.bin
WORLD04/AREA169/AREA169.11.bin
WORLD04/AREA170/AREA170.11.bin
WORLD04/AREA171/AREA171.11.bin
WORLD04/AREA172/AREA172.11.bin
WORLD04/AREA173/AREA173.11.bin
WORLD04/AREA175/AREA175.11.bin
WORLD04/AREA188/AREA188.11.bin
WORLD04/AREA197/AREA197.11.bin"

GFX_TO_REMOVE="AREA030.21.bin.4b.128w.128x32.256r.bmp
AREA089.21.bin.4b.128w.128x32.256r.bmp
AREA129.21.bin.4b.128w.128x32.256r.bmp
AREA152.6.bin.8b.64w.64x32.1024r.bmp
COMMU01.1.bin.4b.128w.128x32.256r.bmp
COMMU02B.1.bin.4b.128w.128x32.256r.bmp
COMMU05.1.bin.4b.128w.128x32.256r.bmp
MAGIC013.5.bin.4b.128w.128x32.256r.bmp
MAGIC038.8.bin.4b.128w.128x32.256r.bmp
MAGIC039.5.bin.4b.128w.128x32.256r.bmp
MAGIC040.5.bin.4b.128w.128x32.256r.bmp
MAGIC043.5.bin.4b.128w.128x32.256r.bmp
MAGIC062.5.bin.4b.128w.128x32.256r.bmp
MAGIC069.5.bin.4b.128w.128x32.256r.bmp
MAGIC082.5.bin.4b.128w.128x32.256r.bmp
MAGIC083.5.bin.4b.128w.128x32.256r.bmp
MAGIC088.5.bin.4b.128w.128x32.256r.bmp
MAGIC225.5.bin.4b.128w.128x32.256r.bmp
SHISU.2.bin.4b.128w.128x32.256r.bmp
SHOP.2.bin.4b.128w.128x32.256r.bmp
SISYOU.2.bin.4b.128w.128x32.256r.bmp
START.4.bin.4b.128w.128x32.256r.bmp
STATUS.2.bin.4b.128w.128x32.256r.bmp
TURIMODE.4.bin.4b.128w.128x32.256r.bmp
TURISHAR.2.bin.8b.64w.64x32.256r.bmp
TURISHAR.3.bin.8b.64w.64x32.256r.bmp"

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

# Rimuovo le grafiche doppie
while read -r file; do
  if [ -f "GFX/$BIN/$file" ]; then
    rm GFX/$BIN/$file
  fi
done <<< "$GFX_TO_REMOVE"

# Copio i file BIN da modificare
mkdir -p BINARY/$BIN
while read -r file; do
  if [ -f "UNPACKED/$BIN/$file" ]; then
    cp UNPACKED/$BIN/$file BINARY/$BIN
  fi
done <<< "$BIN_TO_EXPORT"

# Crea la cartella dei file da iniettare
mkdir -p INJECT/$BIN

# Indicizza i dump di WORLD
python bof3tool.py index -i DUMP/$BIN/WORLD/*.json --output-strings DUMP/dump_world_$BIN.json --output-pointers DUMP/pointers_world_$BIN.json

# Indicizza i dump di MENU
python bof3tool.py index -i DUMP/$BIN/MENU/*.json --output-strings DUMP/dump_menu_$BIN.json --output-pointers DUMP/pointers_menu_$BIN.json