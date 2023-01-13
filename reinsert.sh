#!/bin/bash

BIN=$1
if [ -z "$1" ]; then
  echo "Error: no folder was specified with original data"
  exit 1
fi

# Platform detection
if [[ ! -f "$BIN/ETC/WARNING.EMI" && ! -f "$BIN/ETC/CAPLOGO.EMI" ]]; then
  PLATFORM="USA"
elif [[ -f "$BIN/ETC/WARNING.EMI" ]]; then
  PLATFORM="PAL"
elif [[ -f "$BIN/ETC/CAPLOGO.EMI" ]]; then
  PLATFORM="PSP"
fi

echo "Platform detected: $PLATFORM"

BIN_TO_RAW_REINSERT="BATTLE/BATTLE/BATTLE.4.bin
BOSS/BOSS025/BOSS025.14.bin
ETC/COMMU00/COMMU00.1.bin
ETC/COMMU01/COMMU01.8.bin
ETC/COMMU05/COMMU05.8.bin
ETC/GAME/GAME.1.bin
BMAGIC/MAGIC060/MAGIC060.1.bin
SCENARIO/SCENA10/SCENA10.1.bin
ETC/SISYOU/SISYOU.1.bin"

ENEMIES_TO_REINSERT="WORLD00/AREA002/AREA002.14.bin
WORLD00/AREA003/AREA003.11.bin
WORLD00/AREA005/AREA005.11.bin
WORLD00/AREA008/AREA008.11.bin
WORLD00/AREA009/AREA009.11.bin
WORLD00/AREA010/AREA010.11.bin
WORLD00/AREA011/AREA011.11.bin
WORLD00/AREA012/AREA012.11.bin
WORLD00/AREA015/AREA015.11.bin
WORLD00/AREA018/AREA018.11.bin
WORLD00/AREA019/AREA019.11.bin
WORLD00/AREA020/AREA020.11.bin
WORLD00/AREA022/AREA022.11.bin
WORLD00/AREA023/AREA023.11.bin
WORLD00/AREA026/AREA026.11.bin
WORLD00/AREA027/AREA027.11.bin
WORLD00/AREA028/AREA028.11.bin
WORLD00/AREA032/AREA032.11.bin
WORLD00/AREA035/AREA035.11.bin
WORLD01/AREA040/AREA040.11.bin
WORLD01/AREA041/AREA041.11.bin
WORLD01/AREA042/AREA042.11.bin
WORLD01/AREA043/AREA043.11.bin
WORLD01/AREA044/AREA044.11.bin
WORLD01/AREA048/AREA048.11.bin
WORLD01/AREA051/AREA051.11.bin
WORLD01/AREA052/AREA052.11.bin
WORLD01/AREA054/AREA054.11.bin
WORLD01/AREA056/AREA056.11.bin
WORLD01/AREA067/AREA067.11.bin
WORLD01/AREA069/AREA069.11.bin
WORLD01/AREA071/AREA071.11.bin
WORLD01/AREA075/AREA075.11.bin
WORLD02/AREA077/AREA077.11.bin
WORLD02/AREA079/AREA079.11.bin
WORLD02/AREA080/AREA080.11.bin
WORLD02/AREA081/AREA081.11.bin
WORLD02/AREA082/AREA082.11.bin
WORLD02/AREA083/AREA083.11.bin
WORLD02/AREA085/AREA085.11.bin
WORLD02/AREA086/AREA086.11.bin
WORLD02/AREA091/AREA091.11.bin
WORLD02/AREA092/AREA092.11.bin
WORLD02/AREA095/AREA095.11.bin
WORLD02/AREA096/AREA096.11.bin
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
WORLD03/AREA136/AREA136.11.bin
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
WORLD04/AREA196/AREA196.11.bin
WORLD04/AREA197/AREA197.11.bin
WORLD04/AREA198/AREA198.11.bin"

BIN_TO_DUPLICATE="AREA030.5.bin AREA089.5.bin
AREA030.5.bin AREA129.5.bin
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

# Create TEMP folder (remove/recreate if exists)
echo "Creating TEMP folder..."
if [ -d "TEMP" ]; then
  rm -rf "TEMP"
  echo "Removed old TEMP folder and creating a new one"
fi
mkdir -p TEMP/DUMP
echo "Done"

# Copy all dump files to TEMP/DUMP/platform
echo "Copying all dump files..."
cp -rv DUMP/$BIN TEMP/DUMP
echo "Done"

# Expand all indexed dumps to TEMP/DUMP/platform/[WORLD|MENU|ENEMIES]
echo "Expanding all indexed dumps..."
python bof3tool.py expand --input-strings TEMP/DUMP/$BIN/dump_world.json --input-pointers TEMP/DUMP/$BIN/pointers_world.json -o TEMP/DUMP/$BIN/WORLD
python bof3tool.py expand --input-strings TEMP/DUMP/$BIN/dump_menu.json --input-pointers TEMP/DUMP/$BIN/pointers_menu.json -o TEMP/DUMP/$BIN/MENU
python bof3tool.py expand --input-strings TEMP/DUMP/$BIN/dump_enemies.json --input-pointers TEMP/DUMP/$BIN/pointers_enemies.json -o TEMP/DUMP/$BIN/ENEMIES
echo "Done"

# Reinsert all WORLD dump files
echo "Reinserting all WORLD dump files..."
for file in TEMP/DUMP/$BIN/WORLD/*.json
do
    filename=$(basename -- "$file")
    python bof3tool.py reinsert -i "$file" -o "TEMP/BIN/$BIN/${filename%.*}"
done
echo "Done"

# Reinsert all MENU dump files
echo "Reinserting all MENU dump files..."
for file in TEMP/DUMP/$BIN/MENU/*.json
do
    filename=$(basename -- "$file")
    python bof3tool.py reinsert -i "$file" -o "TEMP/BIN/$BIN/${filename%.*}"
done
echo "Done"

# Raw Reinsert of all enemies names
echo "Copying enemies binary files..."
while read -r file; do
  if [ -f "UNPACKED/$BIN/$file" ]; then
    cp -v UNPACKED/$BIN/$file TEMP/DUMP/$BIN/ENEMIES
  fi
done <<< "$ENEMIES_TO_REINSERT"
echo "Done"

echo "Raw reinserts of all enemies names..."
python bof3tool.py rawreinsert -i TEMP/DUMP/$BIN/ENEMIES/*.json
mv -v TEMP/DUMP/$BIN/ENEMIES/*.bin TEMP/BIN/$BIN
echo "Done"

# Copy all binary files from BEFORE_REINSERT
mkdir -p TEMP/DUMP/$BIN/BINARY
echo "Copying all binary files from BEFORE_REINSERT..."
if [ "$(ls -A INJECT/$BIN/BEFORE_REINSERT)" ]; then
  rsync -a INJECT/$BIN/BEFORE_REINSERT/ TEMP/DUMP/$BIN/BINARY
fi
echo "Done"

# Raw Reinsert all binary files
echo "Raw Reinsert all binary files..."
while read -r filepath; do
  filename=$(basename "$filepath")
  if [[ -f "UNPACKED/$BIN/$filepath" && ! -f "TEMP/DUMP/$BIN/BINARY/$filename" ]]; then
    cp -v UNPACKED/$BIN/$filepath TEMP/DUMP/$BIN/BINARY
  fi
done <<< "$BIN_TO_RAW_REINSERT"
if [ -n "$(find "TEMP/DUMP/$BIN/BINARY" -name '*.json' -print -quit)" ]; then
  python bof3tool.py rawreinsert -i TEMP/DUMP/$BIN/BINARY/*.json
fi
mv -v TEMP/DUMP/$BIN/BINARY/*.bin TEMP/BIN/$BIN
echo "Done"

# Copy graphics to TEMP/GFX/platform
echo "Copying graphics to TEMP/GFX/$BIN"
mkdir -p TEMP/GFX/$BIN
cp -rv GFX/$BIN TEMP/GFX
echo "Done"

# Convert all graphics file from BMP to binary files
echo "Converting all BMPs to binary files..."
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
echo "Done"

# Duplicate missing graphics binary files
echo "Duplicating missing graphics binary files"
while read -r original duplicate; do
  if [ -f "TEMP/BIN/$BIN/$original" ]; then
    cp -v TEMP/BIN/$BIN/$original TEMP/BIN/$BIN/$duplicate
  fi
done <<< "$GFX_TO_DUPLICATE"
echo "Done"

# Copy all missing binary files and duplicate its
if [ "$(ls -A BINARY/$BIN)" ]; then
  echo "Copying missing binary files..."
  rsync -a BINARY/$BIN/ TEMP/BIN/$BIN
  echo "Done"
fi

echo "Duplicating missing binary files..."
while read -r original duplicate; do
  if [ -f "TEMP/BIN/$BIN/$original" ]; then
    cp -v TEMP/BIN/$BIN/$original TEMP/BIN/$BIN/$duplicate
  fi
done <<< "$BIN_TO_DUPLICATE"
echo "Done"

# Copy all binary files from AFTER_REINSERT
echo "Copying all binary files from AFTER_REINSERT"
if [ "$(ls -A INJECT/$BIN/AFTER_REINSERT)" ]; then
  rsync -a INJECT/$BIN/AFTER_REINSERT/ TEMP/BIN/$BIN
fi
echo "Done"

# Copy original UNPACKED folder to TEMP/UNPACKED/platform
echo "Copying original UNPACKED folder to TEMP/UNPACKED/$BIN..."
mkdir -p TEMP/UNPACKED
cp -r UNPACKED/$BIN TEMP/UNPACKED
echo "Done"

# Replace original binary files with newly created
echo "Replacing original binary files with newly created..."
for file in $(find TEMP/UNPACKED/$BIN -type f)
do
  filename=$(basename "$file")
  if [ -f "TEMP/BIN/$BIN/$filename" ]; then
    cp -v "TEMP/BIN/$BIN/$filename" "$file"
  fi
done
echo "Done"

# Repack all JSON files into EMI files
echo "Repacking all JSON files into EMI files..."
for file in $(find TEMP/UNPACKED/$BIN -type f -name '*.json')
do
  dir=$(dirname "$file")
  python bof3tool.py pack -i "$file" -o "$dir"
done
echo "Done"

# Create OUTPUT/platform folder (remove/recreate if exists)
echo "Creating OUTPUT/$BIN folder..."
if [ -d "OUTPUT/$BIN" ]; then
  rm -rf "OUTPUT/$BIN"
  echo "Removed old OUTPUT/$BIN folder and creating a new one"
fi
mkdir -p OUTPUT/$BIN
echo "Done"

# Copy all EMI files to OUTPUT/platform folder (preserving file tree)
echo "Copying all EMI files to OUTPUT/$BIN..."
rsync -am --include="*/" --include="*.EMI" --exclude="*" --delete-excluded TEMP/UNPACKED/$BIN/ OUTPUT/$BIN
echo "Done"

# Remove TEMP folder
echo "Removing TEMP folder..."
rm -rf TEMP
echo "Done"

# Check if the contents of the new EMI files have changed, if not delete them
echo "Keeping only updated EMI files..."
for file in $(find "$BIN" -type f); do
  if [ -f "OUTPUT/$file" ]; then
    diff "$file" "OUTPUT/$file"
    if [ $? -eq 0 ]; then
      rm "OUTPUT/$file"
    fi
  fi
done
echo "Done"

# Remove empty folders
echo "Removing empty folders..."
find "OUTPUT/$BIN" -type d -empty -delete
echo "Done"
