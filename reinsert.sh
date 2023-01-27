#!/bin/bash

BIN=$1
if [ -z "$1" ]; then
  echo "Error: no folder was specified with original data"
  exit 1
fi

EXTRA_TABLE="$2"

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

GFX_RAW_FILES="AREA016.6.bin
AREA016.8.bin
AREA030.14.bin
AREA033.6.bin
AREA033.8.bin
AREA045.6.bin
AREA045.8.bin
AREA065.6.bin
AREA065.8.bin
AREA087.6.bin
AREA087.8.bin
AREA088.6.bin
AREA088.8.bin
AREA089.14.bin
AREA115.6.bin
AREA115.8.bin
AREA121.6.bin
AREA121.8.bin
AREA128.8.bin
AREA129.14.bin
AREA151.8.bin
AREA151.6.bin
AREA152.8.bin
TURIMODE.4.bin"

GFX_REINSERT_COMMANDS_USA=(
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA016.6.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA016.6.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA016.8.bin.4.2.8b.64w.64x32.128r.tim -o TEMP/GFX/$BIN/AREA016.8.bin.4.2 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA030.14.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA030.14.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA030.14.bin.3.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA030.14.bin.3 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA030.14.bin.4.2.4b.128w.128x32.256r.tim -o TEMP/GFX/$BIN/AREA030.14.bin.4.2 --tile-width 128 --tile-height 32 --resize-width 128"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA033.6.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA033.6.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA045.6.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA045.6.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA065.6.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA065.6.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA087.6.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA087.6.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA088.6.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA088.6.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA115.6.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA115.6.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA121.6.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA121.6.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA128.8.bin.4.1.4b.128w.128x32.256r.tim -o TEMP/GFX/$BIN/AREA128.8.bin.4.1 --tile-width 128 --tile-height 32 --resize-width 128"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/AREA151.6.bin.1.8b.64w.64x32.256r.tim -o TEMP/GFX/$BIN/AREA151.6.bin.1 --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/BATE.2.bin.4b.128w.128x32.256r.tim -o TEMP/BIN/$BIN/BATE.2.bin --tile-width 128 --tile-height 32 --resize-width 128"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/BATL_DRA.1.bin.8b.64w.64x64.128r.tim -o TEMP/BIN/$BIN/BATL_DRA.1.bin --tile-width 64 --tile-height 64 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/BATL_OVR.2.bin.8b.64w.64x32.256r.tim -o TEMP/BIN/$BIN/BATL_OVR.2.bin --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/DEMO.5.bin.8b.64w.64x32.256r.tim -o TEMP/BIN/$BIN/DEMO.5.bin --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/DEMO.6.bin.8b.64w.64x32.256r.tim -o TEMP/BIN/$BIN/DEMO.6.bin --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/FIRST.4.bin.4b.128w.128x32.256r.tim -o TEMP/BIN/$BIN/FIRST.4.bin --tile-width 128 --tile-height 32 --resize-width 128"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/FIRST.5.bin.4b.128w.128x32.256r.tim -o TEMP/BIN/$BIN/FIRST.5.bin --tile-width 128 --tile-height 32 --resize-width 128"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/FIRST.6.bin.4b.128w.128x32.256r.tim -o TEMP/BIN/$BIN/FIRST.6.bin --tile-width 128 --tile-height 32 --resize-width 128"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/MAGIC008.2.bin.4b.128w.128x32.256r.tim -o TEMP/BIN/$BIN/MAGIC008.2.bin --tile-width 128 --tile-height 32 --resize-width 128"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/MAGIC067.7.bin.4b.128w.64x16.64r.tim -o TEMP/BIN/$BIN/MAGIC067.7.bin --tile-width 64 --tile-height 16 --resize-width 128"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/SCENA17.2.bin.8b.64w.64x32.256r.tim -o TEMP/BIN/$BIN/SCENA17.2.bin --tile-width 64 --tile-height 32 --resize-width 64"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/SCENA17.3.bin.4b.128w.128x32.256r.tim -o TEMP/BIN/$BIN/SCENA17.3.bin --tile-width 128 --tile-height 32 --resize-width 128"
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/START.6.bin.4b.128w.128x32.256r.tim -o TEMP/BIN/$BIN/START.6.bin --tile-width 128 --tile-height 32 --resize-width 128"
)

GFX_REINSERT_COMMANDS_PAL=("${GFX_REINSERT_COMMANDS_USA[@]}")
GFX_REINSERT_COMMANDS_PAL+=(
  "python bof3tool.py tim2raw -i TEMP/GFX/$BIN/LOAD.1.bin.4b.128w.128x32.256r.tim -o TEMP/BIN/$BIN/LOAD.1.bin --tile-width 128 --tile-height 32 --resize-width 128"
)

GFX_REINSERT_COMMANDS_PSP=("${GFX_REINSERT_COMMANDS_USA[@]}")

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
    python bof3tool.py reinsert -i "$file" -o "TEMP/BIN/$BIN/${filename%.*}" $EXTRA_TABLE
done
echo "Done"

# Reinsert all MENU dump files
echo "Reinserting all MENU dump files..."
for file in TEMP/DUMP/$BIN/MENU/*.json
do
    filename=$(basename -- "$file")
    python bof3tool.py reinsert -i "$file" -o "TEMP/BIN/$BIN/${filename%.*}" $EXTRA_TABLE
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
python bof3tool.py rawreinsert -i TEMP/DUMP/$BIN/ENEMIES/*.json $EXTRA_TABLE
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
  python bof3tool.py rawreinsert -i TEMP/DUMP/$BIN/BINARY/*.json $EXTRA_TABLE
fi
mv -v TEMP/DUMP/$BIN/BINARY/*.bin TEMP/BIN/$BIN
echo "Done"

# Copy graphics to TEMP/GFX/platform
echo "Copying graphics to TEMP/GFX/$BIN"
mkdir -p TEMP/GFX/$BIN
cp -rv GFX/$BIN TEMP/GFX
echo "Done"

# Moving all RAW images to TEMP/GFX/platform/RAW
mkdir -p TEMP/GFX/$BIN/RAW
echo "Moving all RAW images files..."
for raw in $GFX_RAW_FILES; do
  find UNPACKED/$BIN -name $raw -exec cp -v {} "TEMP/GFX/$BIN/RAW" \;
done
echo "Done"

# Splitting all RAW images into 4 parts
echo "Splitting all RAW images into 4 parts in TEMP/GFX/platform/RAW..."
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/* -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024 --quantity 4
echo "Done"

# Split again the 4BPP RAW images parts...
echo "Splitting 4BPP RAW images parts..."
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA016.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA030.14.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA033.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA045.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA065.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA087.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA088.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA089.14.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA115.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA121.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA128.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA129.14.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA151.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i TEMP/GFX/$BIN/RAW/AREA152.8.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
if [ $PLATFORM == "PSP" ]; then
  python bof3tool.py split -i TEMP/GFX/$BIN/RAW/TURIMODE.4.bin.4 -o TEMP/GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
fi
echo "Done"

# Convert all TIM files to RAW splitted files
echo "Converting all TIM files to RAW splitted files..."
if [ $PLATFORM == "USA" ]; then
  for cmd in "${GFX_REINSERT_COMMANDS_USA[@]}"; do
    $cmd
  done
elif [ $PLATFORM == "PAL" ]; then
  for cmd in "${GFX_REINSERT_COMMANDS_PAL[@]}"; do
    $cmd
  done
elif [ $PLATFORM == "PSP" ]; then
  for cmd in "${GFX_REINSERT_COMMANDS_PSP[@]}"; do
    $cmd
  done
fi
echo "Done"

# Copy duplicated splitted raw files and font (ENDKANJI.1.bin)
echo "Copying duplicated splitted RAW parts and Font..."
cp -v TEMP/GFX/$BIN/AREA016.6.bin.1 TEMP/GFX/$BIN/RAW/AREA016.6.bin.1
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA016.8.bin.4.2
cp -v TEMP/GFX/$BIN/AREA030.14.bin.1 TEMP/GFX/$BIN/RAW/AREA030.14.bin.1
cp -v TEMP/GFX/$BIN/AREA030.14.bin.3 TEMP/GFX/$BIN/RAW/AREA030.14.bin.3
cp -v TEMP/GFX/$BIN/AREA030.14.bin.4.2 TEMP/GFX/$BIN/RAW/AREA030.14.bin.4.2
cp -v TEMP/GFX/$BIN/AREA033.6.bin.1 TEMP/GFX/$BIN/RAW/AREA033.6.bin.1
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA033.8.bin.4.2
cp -v TEMP/GFX/$BIN/AREA045.6.bin.1 TEMP/GFX/$BIN/RAW/AREA045.6.bin.1
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA045.8.bin.4.2
cp -v TEMP/GFX/$BIN/AREA065.6.bin.1 TEMP/GFX/$BIN/RAW/AREA065.6.bin.1
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA065.8.bin.4.2
cp -v TEMP/GFX/$BIN/AREA087.6.bin.1 TEMP/GFX/$BIN/RAW/AREA087.6.bin.1
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA087.8.bin.4.2
cp -v TEMP/GFX/$BIN/AREA088.6.bin.1 TEMP/GFX/$BIN/RAW/AREA088.6.bin.1
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA088.8.bin.4.2
cp -v TEMP/GFX/$BIN/AREA030.14.bin.1 TEMP/GFX/$BIN/RAW/AREA089.14.bin.1
cp -v TEMP/GFX/$BIN/AREA030.14.bin.3 TEMP/GFX/$BIN/RAW/AREA089.14.bin.3
cp -v TEMP/GFX/$BIN/AREA030.14.bin.4.2 TEMP/GFX/$BIN/RAW/AREA089.14.bin.4.2
cp -v TEMP/GFX/$BIN/AREA115.6.bin.1 TEMP/GFX/$BIN/RAW/AREA115.6.bin.1
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA115.8.bin.4.2
cp -v TEMP/GFX/$BIN/AREA121.6.bin.1 TEMP/GFX/$BIN/RAW/AREA121.6.bin.1
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA121.8.bin.4.2
cp -v TEMP/GFX/$BIN/AREA128.8.bin.4.1 TEMP/GFX/$BIN/RAW/AREA128.8.bin.4.1
cp -v TEMP/GFX/$BIN/AREA030.14.bin.1 TEMP/GFX/$BIN/RAW/AREA129.14.bin.1
cp -v TEMP/GFX/$BIN/AREA030.14.bin.3 TEMP/GFX/$BIN/RAW/AREA129.14.bin.3
cp -v TEMP/GFX/$BIN/AREA030.14.bin.4.2 TEMP/GFX/$BIN/RAW/AREA129.14.bin.4.2
cp -v TEMP/GFX/$BIN/AREA151.6.bin.1 TEMP/GFX/$BIN/RAW/AREA151.6.bin.1
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA151.8.bin.4.2
cp -v TEMP/GFX/$BIN/AREA016.8.bin.4.2 TEMP/GFX/$BIN/RAW/AREA152.8.bin.4.2

if [ $PLATFORM == "USA" ]; then
    cp -v TEMP/BIN/$BIN/FIRST.4.bin TEMP/BIN/$BIN/ENDKANJI.1.bin
elif [ $PLATFORM == "PAL" ]; then
    cp -v TEMP/BIN/$BIN/FIRST.4.bin TEMP/BIN/$BIN/ENDKANJI.1.bin
elif [ $PLATFORM == "PSP" ]; then
  cp -v TEMP/GFX/$BIN/AREA030.14.bin.1 TEMP/GFX/$BIN/RAW/TURIMODE.4.bin.1
  cp -v TEMP/GFX/$BIN/AREA030.14.bin.3 TEMP/GFX/$BIN/RAW/TURIMODE.4.bin.3
  cp -v TEMP/GFX/$BIN/AREA030.14.bin.4.2 TEMP/GFX/$BIN/RAW/TURIMODE.4.bin.4.2
  cp -v TEMP/BIN/$BIN/FIRST.5.bin TEMP/BIN/$BIN/ENDKANJI.1.bin
fi

echo "Done"

# Merge all RAW splitted files
echo "Merging all RAW splitted files..."
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA016.6.bin.* -o TEMP/BIN/$BIN/AREA016.6.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA016.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA016.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA016.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA016.8.bin.* -o TEMP/BIN/$BIN/AREA016.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA030.14.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA030.14.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA030.14.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA030.14.bin.* -o TEMP/BIN/$BIN/AREA030.14.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA033.6.bin.* -o TEMP/BIN/$BIN/AREA033.6.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA033.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA033.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA033.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA033.8.bin.* -o TEMP/BIN/$BIN/AREA033.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA045.6.bin.* -o TEMP/BIN/$BIN/AREA045.6.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA045.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA045.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA045.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA045.8.bin.* -o TEMP/BIN/$BIN/AREA045.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA065.6.bin.* -o TEMP/BIN/$BIN/AREA065.6.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA065.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA065.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA065.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA065.8.bin.* -o TEMP/BIN/$BIN/AREA065.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA087.6.bin.* -o TEMP/BIN/$BIN/AREA087.6.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA087.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA087.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA087.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA087.8.bin.* -o TEMP/BIN/$BIN/AREA087.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA088.6.bin.* -o TEMP/BIN/$BIN/AREA088.6.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA088.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA088.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA088.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA088.8.bin.* -o TEMP/BIN/$BIN/AREA088.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA089.14.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA089.14.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA089.14.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA089.14.bin.* -o TEMP/BIN/$BIN/AREA089.14.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA115.6.bin.* -o TEMP/BIN/$BIN/AREA115.6.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA115.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA115.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA115.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA115.8.bin.* -o TEMP/BIN/$BIN/AREA115.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA121.6.bin.* -o TEMP/BIN/$BIN/AREA121.6.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA121.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA121.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA121.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA121.8.bin.* -o TEMP/BIN/$BIN/AREA121.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA128.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA128.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA128.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA128.8.bin.* -o TEMP/BIN/$BIN/AREA128.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA129.14.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA129.14.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA129.14.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA129.14.bin.* -o TEMP/BIN/$BIN/AREA129.14.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA151.6.bin.* -o TEMP/BIN/$BIN/AREA151.6.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA151.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA151.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA151.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA151.8.bin.* -o TEMP/BIN/$BIN/AREA151.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA152.8.bin.4.* -o TEMP/GFX/$BIN/RAW/AREA152.8.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
rm -f TEMP/GFX/$BIN/RAW/AREA152.8.bin.4.*
python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/AREA152.8.bin.* -o TEMP/BIN/$BIN/AREA152.8.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024

if [ $PLATFORM == "PSP" ]; then
  python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/TURIMODE.4.bin.4.* -o TEMP/GFX/$BIN/RAW/TURIMODE.4.bin.4 --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256
  rm -f TEMP/GFX/$BIN/RAW/TURIMODE.4.bin.4.*
  python bof3tool.py merge -i TEMP/GFX/$BIN/RAW/TURIMODE.4.bin.* -o TEMP/BIN/$BIN/TURIMODE.4.bin --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024
fi

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
