#!/bin/bash

BIN=$1
if [ -z "$1" ]; then
  echo "Error: no folder was specified with data to dump"
  exit 1
fi

# Platform detection
if [[ ! -f "$BIN/ETC/WARNING.EMI" && ! -f "$BIN/ETC/CAPLOGO.EMI" ]]; then
  PLATFORM="USA"
elif [[ -f "$BIN/ETC/WARNING.EMI" ]]; then
  PLATFORM="PAL"
elif [[ -f "$BIN/ETC/CAPLOGO.EMI" ]]; then
  PLATFORM="PSP"
  if [ ! -f "$BIN/BOOT.BIN" ]; then
    echo "Error: no BOOT.BIN for PSP platform found"
    exit 1
  fi
fi

echo "Platform detected: $PLATFORM"

BIN_DUMP_COMMANDS_COMMON=(
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.4.bin -o DUMP/$BIN/BINARY/BATTLE.4.bin.json --offset 0x1A2B0 --quantity 4 --skip 4 --repeat 7 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.4.bin -o DUMP/$BIN/BINARY/BATTLE.4.bin.json --offset 0x1A400 --quantity 12 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.4.bin -o DUMP/$BIN/BINARY/BATTLE.4.bin.json --offset 0x1A41A --quantity 12 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.4.bin -o DUMP/$BIN/BINARY/BATTLE.4.bin.json --offset 0x1A434 --quantity 12 --skip 1 --repeat 8 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.16.bin -o DUMP/$BIN/BINARY/BATTLE.16.bin.json --offset 0x20530 --quantity 4 --skip 2 --repeat 3 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.16.bin -o DUMP/$BIN/BINARY/BATTLE.16.bin.json --offset 0x2055C --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.16.bin -o DUMP/$BIN/BINARY/BATTLE.16.bin.json --offset 0x20660 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.16.bin -o DUMP/$BIN/BINARY/BATTLE.16.bin.json --offset 0x2069C --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.16.bin -o DUMP/$BIN/BINARY/BATTLE.16.bin.json --offset 0x206D8 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.16.bin -o DUMP/$BIN/BINARY/BATTLE.16.bin.json --offset 0x20700 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BATTLE/BATTLE/BATTLE.16.bin -o DUMP/$BIN/BINARY/BATTLE.16.bin.json --offset 0x2073C --quantity 4 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BMAGIC/MAGIC003/MAGIC003.4.bin -o DUMP/$BIN/BINARY/MAGIC003.4.bin.json --offset 0x1EA1 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BMAGIC/MAGIC003/MAGIC003.4.bin -o DUMP/$BIN/BINARY/MAGIC003.4.bin.json --offset 0x1EA5 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BMAGIC/MAGIC003/MAGIC003.4.bin -o DUMP/$BIN/BINARY/MAGIC003.4.bin.json --offset 0x1EAD --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BMAGIC/MAGIC003/MAGIC003.4.bin -o DUMP/$BIN/BINARY/MAGIC003.4.bin.json --offset 0x1EBA --quantity 2 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BMAGIC/MAGIC003/MAGIC003.4.bin -o DUMP/$BIN/BINARY/MAGIC003.4.bin.json --offset 0x1EC7 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BMAGIC/MAGIC060/MAGIC060.1.bin -o DUMP/$BIN/BINARY/MAGIC060.1.bin.json --offset 0x1F64 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x50 --quantity 7 --skip 13 --repeat 10 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x57 --quantity 1 --skip 19 --repeat 10 --trim --raw"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x7AF0 --quantity 8 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x7F18 --quantity 4 --repeat 8 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x7F40 --quantity 8 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x7F84 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x7FBC --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x7FC0 --quantity 7 --skip 1 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x7FE8 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x7FEC --quantity 7 --skip 1 --repeat 15 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x8064 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x80F4 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x8114 --quantity 3 --skip 3 --repeat 3 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x8224 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x8260 --quantity 8 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/BATE/BATE.1.bin -o DUMP/$BIN/BINARY/BATE.1.bin.json --offset 0x8290 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU00/COMMU00.1.bin -o DUMP/$BIN/BINARY/COMMU00.1.bin.json --offset 0x3B00 --quantity 5 --skip 4 --repeat 60 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU02/COMMU02.9.bin -o DUMP/$BIN/BINARY/COMMU02.9.bin.json --offset 0x3C --quantity 4 --skip 1 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU02/COMMU02.9.bin -o DUMP/$BIN/BINARY/COMMU02.9.bin.json --offset 0xA0A8 --quantity 4 --skip 4 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU02/COMMU02.9.bin -o DUMP/$BIN/BINARY/COMMU02.9.bin.json --offset 0xA410 --quantity 4 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU02/COMMU02.9.bin -o DUMP/$BIN/BINARY/COMMU02.9.bin.json --offset 0xA418 --quantity 8 --repeat 3 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU03/COMMU03.7.bin -o DUMP/$BIN/BINARY/COMMU03.7.bin.json --offset 0x4 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU03/COMMU03.7.bin -o DUMP/$BIN/BINARY/COMMU03.7.bin.json --offset 0xC --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU03/COMMU03.7.bin -o DUMP/$BIN/BINARY/COMMU03.7.bin.json --offset 0x11 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU03/COMMU03.7.bin -o DUMP/$BIN/BINARY/COMMU03.7.bin.json --offset 0x17 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU03/COMMU03.7.bin -o DUMP/$BIN/BINARY/COMMU03.7.bin.json --offset 0x1C --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU03/COMMU03.7.bin -o DUMP/$BIN/BINARY/COMMU03.7.bin.json --offset 0x26 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU03/COMMU03.7.bin -o DUMP/$BIN/BINARY/COMMU03.7.bin.json --offset 0x2C --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU03/COMMU03.7.bin -o DUMP/$BIN/BINARY/COMMU03.7.bin.json --offset 0x34 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU03/COMMU03.7.bin -o DUMP/$BIN/BINARY/COMMU03.7.bin.json --offset 0x3C --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU05/COMMU05.8.bin -o DUMP/$BIN/BINARY/COMMU05.8.bin.json --offset 0xD5C --quantity 8 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x34 --quantity 7 --skip 13 --repeat 10 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x3B --quantity 1 --skip 19 --repeat 10 --trim --raw"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x8F3C --quantity 4 --repeat 8 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x8F64 --quantity 8 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x8FA8 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x8FE0 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x8FE4 --quantity 7 --skip 1 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x900C --quantity 3 --skip 1 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x9010 --quantity 7 --skip 1 --repeat 15 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x9088 --quantity 3 --skip 1 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x9118 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x9138 --quantity 3 --skip 3 --repeat 3 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x9248 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x9284 --quantity 8 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHISU/SHISU.1.bin -o DUMP/$BIN/BINARY/SHISU.1.bin.json --offset 0x92B4 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x114 --quantity 7 --skip 13 --repeat 10 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x11B --quantity 1 --skip 19 --repeat 10 --trim --raw"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14C14 --quantity 4 --repeat 8 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14C3C --quantity 8 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14C80 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14CB8 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14CBC --quantity 7 --skip 1 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14CE4 --quantity 3 --skip 1 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14CE8 --quantity 7 --skip 1 --repeat 15 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14D60 --quantity 3 --skip 1 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14DF0 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14E10 --quantity 3 --skip 3 --repeat 3 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14F20 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14F5C --quantity 8 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x14F8C --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x1511C --quantity 8 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x15138 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x152DC --quantity 8 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SHOP/SHOP.1.bin -o DUMP/$BIN/BINARY/SHOP.1.bin.json --offset 0x15360 --quantity 8 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/SISYOU/SISYOU.1.bin -o DUMP/$BIN/BINARY/SISYOU.1.bin.json --offset 0x3438 --quantity 4 --repeat 7 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x7C --quantity 7 --skip 13 --repeat 10 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x83 --quantity 1 --skip 19 --repeat 10 --trim --raw"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1E0 --quantity 12 --repeat 3 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x204 --quantity 8 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x214 --quantity 12 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x229 --quantity 6 --skip 15 --repeat 6 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x228 --quantity 1 --skip 20 --repeat 6 --trim --raw"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x300 --quantity 5 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1A914 --quantity 5 --skip 159 --repeat 8 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BD30 --quantity 4 --repeat 8 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BD58 --quantity 8 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BD9C --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BDD4 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BDD8 --quantity 7 --skip 1 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BE00 --quantity 3 --skip 1 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BE04 --quantity 7 --skip 1 --repeat 15 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BE7C --quantity 3 --skip 1 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BF0C --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1BF2C --quantity 3 --skip 3 --repeat 3 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C03C --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C078 --quantity 8 --repeat 4 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C0A8 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C126 --quantity 4 --skip 4 --repeat 3 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C17E --quantity 6 --skip 2 --repeat 6 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C590 --quantity 4 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C8C8 --quantity 8 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C8D0 --quantity 12 --repeat 3 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C8F4 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1C91C --quantity 12 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/START/START.9.bin -o DUMP/$BIN/BINARY/START.9.bin.json --offset 0x1CA08 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/SCENARIO/SCENA10/SCENA10.1.bin -o DUMP/$BIN/BINARY/SCENA10.1.bin.json --offset 0x7C74 --quantity 12 --trim"
)

BIN_DUMP_COMMANDS_USA=("${BIN_DUMP_COMMANDS_COMMON[@]}")
BIN_DUMP_COMMANDS_USA+=(
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BOSS/BOSS025/BOSS025.14.bin -o DUMP/$BIN/BINARY/BOSS025.14.bin.json --offset 0x1AA8 --quantity 12 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU01/COMMU01.8.bin -o DUMP/$BIN/BINARY/COMMU01.8.bin.json --offset 0x4134 --quantity 8 --repeat 20 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x32434 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x33164 --quantity 12 --skip 6 --repeat 92 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x337DC --quantity 12 --skip 4 --repeat 16 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x338DC --quantity 12 --skip 12 --repeat 83 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x340A4 --quantity 12 --skip 10 --repeat 68 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x3467C --quantity 12 --skip 8 --repeat 52 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x34F20 --quantity 12 --skip 8 --repeat 227 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x111AC --quantity 12 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x111B8 --quantity 20 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x111CC --quantity 16 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x111DC --quantity 12 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x111E8 --quantity 32 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x11208 --quantity 16 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x11220 --quantity 28 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x1123C --quantity 24 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x11254 --quantity 32 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x115C0 --quantity 4 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x115D4 --quantity 5 --repeat 2 --trim"
)

BIN_DUMP_COMMANDS_PAL=("${BIN_DUMP_COMMANDS_COMMON[@]}")
BIN_DUMP_COMMANDS_PAL+=(
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BOSS/BOSS025/BOSS025.14.bin -o DUMP/$BIN/BINARY/BOSS025.14.bin.json --offset 0x1AD4 --quantity 12 --repeat 2 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/COMMU01/COMMU01.8.bin -o DUMP/$BIN/BINARY/COMMU01.8.bin.json --offset 0x40A8 --quantity 8 --repeat 20 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x324B8 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x331E8 --quantity 12 --skip 6 --repeat 92 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x33860 --quantity 12 --skip 4 --repeat 16 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x33960 --quantity 12 --skip 12 --repeat 83 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x34128 --quantity 12 --skip 10 --repeat 68 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x34700 --quantity 12 --skip 8 --repeat 52 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x34FA4 --quantity 12 --skip 8 --repeat 227 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x111CC --quantity 12 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x111D8 --quantity 20 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x111EC --quantity 16 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x111FC --quantity 12 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x11208 --quantity 32 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x11228 --quantity 16 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x11240 --quantity 28 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x1125C --quantity 24 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x11274 --quantity 32 --repeat 1 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x115E0 --quantity 4 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/WORLD00/AREA030/AREA030.5.bin -o DUMP/$BIN/BINARY/AREA030.5.bin.json --offset 0x115F4 --quantity 5 --repeat 2 --trim"
)

BIN_DUMP_COMMANDS_PSP=(
  "python bof3tool.py rawdump -i UNPACKED/$BIN/BMAGIC/MAGIC060/MAGIC060.1.bin -o DUMP/$BIN/BINARY/MAGIC060.1.bin.json --offset 0x1F00 --quantity 8 --repeat 5 --trim"
  "python bof3tool.py rawdump -i UNPACKED/$BIN/ETC/GAME/GAME.1.bin -o DUMP/$BIN/BINARY/GAME.1.bin.json --offset 0x3242C --quantity 8 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_sound.json --offset 0x2D6CD8 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_sound.json --offset 0x2D6CE0 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_sound.json --offset 0x2D6CE8 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_sound.json --offset 0x2D6CF0 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_sound.json --offset 0x2D6CFA --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_sound.json --offset 0x2D6D00 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_sound.json --offset 0x2D6D05 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_sound.json --offset 0x2D6D0B --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_sound.json --offset 0x2D6D10 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_characters.json --offset 0x2DDCC8 --quantity 5 --skip 159 --repeat 8 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_characters.json --offset 0x2EF4D4 --quantity 5 --repeat 7 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DF6E8 --quantity 10 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DF6F3 --quantity 17 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DF705 --quantity 15 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DF715 --quantity 12 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DF722 --quantity 30 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DF741 --quantity 13 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DF755 --quantity 25 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DF76F --quantity 22 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DF786 --quantity 30 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DFBE6 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2DFBE9 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2FAB80 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_fishing.json --offset 0x2FAB84 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2DF208 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2DF20D --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2DF214 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2DF21A --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2DF221 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC604 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC609 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC610 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC616 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC61D --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC638 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC63D --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC644 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC64B --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC664 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC669 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC670 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC676 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2EC67D --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F48F1 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F48F6 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F48FD --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F4903 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F490A --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F4924 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F4929 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F4930 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F4937 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F493D --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F497C --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F4981 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F4988 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F498E --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F4995 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F8984 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F8989 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F8990 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F8996 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F899D --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F89B8 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F89BD --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F89C4 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F89CB --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F89E4 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F89E9 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F89F0 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F89F6 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F89FD --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9624 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9629 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9630 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9636 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F963D --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9658 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F965D --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9664 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F966B --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9684 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9689 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9690 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9696 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F969D --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9F44 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9F49 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9F50 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9F56 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9F5D --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9F78 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9F7D --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9F84 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9F8B --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9FA4 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9FA9 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9FB0 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9FB6 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_menu_title.json --offset 0x2F9FBD --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_gear_data_rule.json --offset 0x2DFB1A --quantity 4 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2DFBED --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2DFBF2 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2EC394 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2EC39A --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2EC39E --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2F8714 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2F871A --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2F871E --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2F93B4 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2F93BA --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2F93BE --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2F9CD4 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2F9CDA --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2F9CDE --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_equip_guide_exp_next.json --offset 0x2FAC68 --quantity 5 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2EC37E --quantity 3 --skip 1 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2EC4DB --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2EC5D4 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2EC5F2 --quantity 3 --skip 3 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2EFDBC --quantity 3 --skip 1 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F4958 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F86FE --quantity 3 --skip 1 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F885B --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F8954 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F8972 --quantity 3 --skip 3 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F939E --quantity 3 --skip 1 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F94FB --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F95F4 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F9612 --quantity 3 --skip 3 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F9CBE --quantity 3 --skip 1 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F9E1B --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F9F14 --quantity 3 --skip 3 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pwr_def_int_agl.json --offset 0x2F9F32 --quantity 3 --skip 3 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pois_conf_gene.json --offset 0x2EC4D1 --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pois_conf_gene.json --offset 0x2ECFAA --quantity 4 --skip 1 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pois_conf_gene.json --offset 0x2EFE9D --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pois_conf_gene.json --offset 0x2F8851 --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pois_conf_gene.json --offset 0x2F8AB8 --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pois_conf_gene.json --offset 0x2F94F1 --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_pois_conf_gene.json --offset 0x2F9E11 --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_tactics.json --offset 0x2EC50C --quantity 7 --skip 13 --repeat 10 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_tactics.json --offset 0x2EC513 --quantity 1 --skip 19 --repeat 10 --trim --raw"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_tactics.json --offset 0x2F888C --quantity 7 --skip 13 --repeat 10 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_tactics.json --offset 0x2F8893 --quantity 1 --skip 19 --repeat 10 --trim --raw"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_tactics.json --offset 0x2F952C --quantity 7 --skip 13 --repeat 10 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_tactics.json --offset 0x2F9533 --quantity 1 --skip 19 --repeat 10 --trim --raw"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_tactics.json --offset 0x2F9E4C --quantity 7 --skip 13 --repeat 10 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_tactics.json --offset 0x2F9E53 --quantity 1 --skip 19 --repeat 10 --trim --raw"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2EC3D7 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2EC3DB --quantity 4 --skip 1 --repeat 5 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2EC3F4 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2EC3F8 --quantity 4 --skip 1 --repeat 16 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F8757 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F875B --quantity 4 --skip 1 --repeat 5 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F8774 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F8778 --quantity 4 --skip 1 --repeat 16 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F93F7 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F93FB --quantity 4 --skip 1 --repeat 5 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F9414 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F9418 --quantity 4 --skip 1 --repeat 16 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F9D17 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F9D1B --quantity 4 --skip 1 --repeat 5 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F9D34 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_use_sort_drop.json --offset 0x2F9D38 --quantity 4 --skip 1 --repeat 16 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_lists.json --offset 0x2E59C0 --quantity 12 --skip 6 --repeat 92 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_lists.json --offset 0x2E6038 --quantity 12 --skip 4 --repeat 16 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_lists.json --offset 0x2E6138 --quantity 12 --skip 12 --repeat 83 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_lists.json --offset 0x2E6900 --quantity 12 --skip 10 --repeat 68 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_lists.json --offset 0x2E6ED8 --quantity 12 --skip 8 --repeat 52 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_lists.json --offset 0x2EF15A --quantity 8 --repeat 20 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_lists.json --offset 0x2EF232 --quantity 8 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_lists.json --offset 0x2F3444 --quantity 12 --skip 8 --repeat 227 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_lists.json --offset 0x2EF968 --quantity 5 --skip 4 --repeat 60 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2EC786 --quantity 6 --skip 15 --repeat 6 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2EC785 --quantity 1 --skip 20 --repeat 6 --trim --raw"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2ECB98 --quantity 4 --skip 1 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2ECBA7 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2ECBAC --quantity 2 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2ECBAF --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2ECBB3 --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2ECEF6 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2ECEFB --quantity 10 --skip 1 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2EF760 --quantity 2 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2EF763 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2EF767 --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2EF771 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2EF80F --quantity 4 --skip 1 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2EF81E --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F0199 --quantity 3 --skip 5 --repeat 7 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F0418 --quantity 12 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F0432 --quantity 12 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F044C --quantity 12 --skip 1 --repeat 8 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F47D7 --quantity 4 --skip 2 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F4801 --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F48E8 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F48EC --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F8B68 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F8B6C --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_commands.json --offset 0x2F8E0C --quantity 4 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2F5000 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2F5005 --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2F500B --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2F5010 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2ECF1C --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2ECF22 --quantity 7 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2ECF2A --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2ECF2F --quantity 7 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2ECF37 --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2ECF3E --quantity 10 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2EF580 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2EF584 --quantity 3 --skip 1 --repeat 2 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2FACEB --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2EF5D4 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2EF79C --quantity 3 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2F8E16 --quantity 7 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2F8E1E --quantity 6 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_desc.json --offset 0x2F8E3E --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_start.json --offset 0x2EC6D0 --quantity 10 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_start.json --offset 0x2EC6DB --quantity 10 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_start.json --offset 0x2EC6E6 --quantity 14 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_start.json --offset 0x2EC6F5 --quantity 11 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_start.json --offset 0x2EC703 --quantity 4 --skip 4 --repeat 3 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_start.json --offset 0x2EC75B --quantity 6 --skip 2 --repeat 4 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2E0664 --quantity 12 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2EF8D4 --quantity 7 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2EF8DB --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2EF8E2 --quantity 7 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2EF8E9 --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2F4A0E --quantity 9 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2F4A1A --quantity 5 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2F4A27 --quantity 2 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2F4A34 --quantity 4 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2F75F0 --quantity 10 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2F75FB --quantity 10 --repeat 1 --trim"
  "python bof3tool.py rawdump -i $BIN/BOOT.BIN -o DUMP/$BIN/BINARY/BOOT.BIN_various.json --offset 0x2F8E58 --quantity 5 --repeat 2 --trim"
)

BIN_TO_EDIT="SCENARIO/SCENA17/SCENA17.1.bin"

ENEMIES_TO_DUMP="WORLD00/AREA002/AREA002.14.bin
WORLD00/AREA003/AREA003.11.bin
WORLD00/AREA005/AREA005.11.bin
WORLD00/AREA006/AREA006.11.bin
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
WORLD00/AREA024/AREA024.12.bin
WORLD00/AREA026/AREA026.11.bin
WORLD00/AREA027/AREA027.11.bin
WORLD00/AREA028/AREA028.11.bin
WORLD00/AREA029/AREA029.11.bin
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
WORLD01/AREA063/AREA063.11.bin
WORLD01/AREA064/AREA064.11.bin
WORLD01/AREA067/AREA067.11.bin
WORLD01/AREA069/AREA069.11.bin
WORLD01/AREA070/AREA070.11.bin
WORLD01/AREA071/AREA071.11.bin
WORLD01/AREA072/AREA072.11.bin
WORLD01/AREA073/AREA073.11.bin
WORLD01/AREA075/AREA075.11.bin
WORLD02/AREA076/AREA076.11.bin
WORLD02/AREA077/AREA077.11.bin
WORLD02/AREA079/AREA079.11.bin
WORLD02/AREA080/AREA080.11.bin
WORLD02/AREA081/AREA081.11.bin
WORLD02/AREA082/AREA082.11.bin
WORLD02/AREA083/AREA083.11.bin
WORLD02/AREA084/AREA084.11.bin
WORLD02/AREA085/AREA085.11.bin
WORLD02/AREA086/AREA086.11.bin
WORLD02/AREA091/AREA091.11.bin
WORLD02/AREA092/AREA092.11.bin
WORLD02/AREA095/AREA095.11.bin
WORLD02/AREA096/AREA096.11.bin
WORLD02/AREA099/AREA099.11.bin
WORLD02/AREA102/AREA102.11.bin
WORLD02/AREA103/AREA103.11.bin
WORLD02/AREA105/AREA105.11.bin
WORLD02/AREA106/AREA106.11.bin
WORLD02/AREA107/AREA107.11.bin
WORLD02/AREA108/AREA108.11.bin
WORLD02/AREA109/AREA109.11.bin
WORLD02/AREA110/AREA110.11.bin
WORLD02/AREA111/AREA111.11.bin
WORLD02/AREA112/AREA112.11.bin
WORLD03/AREA117/AREA117.11.bin
WORLD03/AREA118/AREA118.11.bin
WORLD03/AREA119/AREA119.11.bin
WORLD03/AREA120/AREA120.11.bin
WORLD03/AREA124/AREA124.11.bin
WORLD03/AREA125/AREA125.11.bin
WORLD03/AREA127/AREA127.11.bin
WORLD03/AREA134/AREA134.11.bin
WORLD03/AREA135/AREA135.11.bin
WORLD03/AREA136/AREA136.11.bin
WORLD03/AREA137/AREA137.11.bin
WORLD03/AREA138/AREA138.11.bin
WORLD03/AREA139/AREA139.11.bin
WORLD03/AREA140/AREA140.11.bin
WORLD03/AREA141/AREA141.11.bin
WORLD03/AREA142/AREA142.11.bin
WORLD03/AREA144/AREA144.11.bin
WORLD03/AREA145/AREA145.11.bin
WORLD03/AREA146/AREA146.11.bin
WORLD04/AREA158/AREA158.11.bin
WORLD04/AREA159/AREA159.11.bin
WORLD04/AREA160/AREA160.11.bin
WORLD04/AREA161/AREA161.11.bin
WORLD04/AREA162/AREA162.11.bin
WORLD04/AREA163/AREA163.11.bin
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

GFX_RAW_FILES="AREA016.6.bin
AREA016.8.bin
AREA030.14.bin
AREA033.6.bin
AREA045.6.bin
AREA065.6.bin
AREA087.6.bin
AREA088.6.bin
AREA104.8.bin
AREA115.6.bin
AREA121.6.bin
AREA128.8.bin
AREA151.6.bin
BATE.2.bin
BATL_DRA.1.bin
BATL_OVR.2.bin
DEMO.5.bin
DEMO.6.bin
FIRST.4.bin
FIRST.5.bin
FIRST.6.bin
LOAD.1.bin
MAGIC008.2.bin
MAGIC067.7.bin
SCENA17.2.bin
SCENA17.3.bin
START.6.bin"

GFX_DUMP_COMMANDS_COMMON=(
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA016.6.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD00/AREA016/AREA016.7.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA016.8.bin.4.2 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 128 --clut UNPACKED/$BIN/WORLD00/AREA016/AREA016.9.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA030.14.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD00/AREA030/AREA030.15.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA030.14.bin.3 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD00/AREA030/AREA030.15.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA030.14.bin.4.2 --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD00/AREA030/AREA030.15.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA033.6.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD00/AREA033/AREA033.7.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA045.6.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD01/AREA045/AREA045.7.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA065.6.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD01/AREA065/AREA065.7.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA087.6.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD02/AREA087/AREA087.7.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA088.6.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD02/AREA088/AREA088.7.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA104.8.bin.4.2 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 128 --clut UNPACKED/$BIN/WORLD02/AREA104/AREA104.9.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA115.6.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD03/AREA115/AREA115.7.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA121.6.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD03/AREA121/AREA121.7.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA128.8.bin.4.1 --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD03/AREA128/AREA128.9.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/AREA151.6.bin.1 --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/WORLD03/AREA151/AREA151.7.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/BATE.2.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/BATE/BATE.5.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/BATL_DRA.1.bin --bpp 8 --width 64 --tile-width 64 --tile-height 64 --resize-width 128 --clut UNPACKED/$BIN/BATTLE/BATL_DRA/BATL_DRA.2.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/BATL_OVR.2.bin --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/BATTLE/BATL_OVR/BATL_OVR.3.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/DEMO.5.bin --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/DEMO/DEMO.8.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/DEMO.6.bin --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/DEMO/DEMO.8.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/MAGIC008.2.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/BMAGIC/MAGIC008/MAGIC008.3.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/MAGIC067.7.bin --bpp 4 --width 128 --tile-width 64 --tile-height 16 --resize-width 64 --clut UNPACKED/$BIN/BMAGIC/MAGIC067/MAGIC067.8.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/SCENA17.2.bin --bpp 8 --width 64 --tile-width 64 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/SCENARIO/SCENA17/SCENA17.4.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/SCENA17.3.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/SCENARIO/SCENA17/SCENA17.5.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/START.6.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/START/START.7.bin"
)

GFX_DUMP_COMMANDS_USA=("${GFX_DUMP_COMMANDS_COMMON[@]}")
GFX_DUMP_COMMANDS_USA+=(
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/FIRST.4.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/FIRST/FIRST.9.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/FIRST.5.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/FIRST/FIRST.11.bin"
)

GFX_DUMP_COMMANDS_PAL=("${GFX_DUMP_COMMANDS_COMMON[@]}")
GFX_DUMP_COMMANDS_PAL+=(
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/FIRST.4.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/FIRST/FIRST.9.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/FIRST.5.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/FIRST/FIRST.11.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/LOAD.1.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/LOAD/LOAD.2.bin"
)

GFX_DUMP_COMMANDS_PSP=("${GFX_DUMP_COMMANDS_COMMON[@]}")
GFX_DUMP_COMMANDS_PSP+=(
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/FIRST.5.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/FIRST/FIRST.10.bin"
  "python bof3tool.py raw2tim -i GFX/$BIN/RAW/FIRST.6.bin --bpp 4 --width 128 --tile-width 128 --tile-height 32 --resize-width 256 --clut UNPACKED/$BIN/ETC/FIRST/FIRST.12.bin"
)

# Removes folders that do not contain text/graphics to be translated
dirs_to_delete="BENEMY BGM BMAG_XA BPLCHAR PLCHAR SCE_XA MODULE PSMF"

for dir in $dirs_to_delete; do
  if [ -d "$BIN/$dir" ]; then
    echo "Removing unused folder $dir"...
    rm -rf "$BIN/$dir"
  fi
done

# Remove all unused dumps
dumps_to_delete="AREA006.12.bin.json
AREA025.12.bin.json
AREA029.12.bin.json
AREA036.12.bin.json
AREA063.12.bin.json
AREA064.12.bin.json
AREA070.12.bin.json
AREA072.12.bin.json
AREA073.12.bin.json
AREA076.12.bin.json
AREA084.12.bin.json
AREA093.12.bin.json
AREA102.12.bin.json
AREA106.12.bin.json
AREA109.12.bin.json
AREA110.12.bin.json
AREA124.12.bin.json
AREA125.12.bin.json
AREA127.12.bin.json
AREA137.12.bin.json
AREA138.12.bin.json
AREA139.12.bin.json
AREA146.12.bin.json
AREA156.12.bin.json
AREA158.12.bin.json
AREA159.12.bin.json
AREA160.12.bin.json
AREA161.12.bin.json
AREA162.12.bin.json
AREA163.12.bin.json
AREA190.12.bin.json"

# Unpack all EMI files
echo "Unpacking all EMI files..."
for dir in $BIN/*/
do
    dir=${dir%*/}
    if [ -d "$dir" ] && [ -n "$(find "$dir" -name '*.EMI' -print -quit)" ]; then
        python bof3tool.py unpack -i $dir/*.EMI -o UNPACKED/$dir --dump-text
    fi
done
echo "Done"

echo "Removing all unused dumps if exists..."
for file in $dumps_to_delete; do
  find $BIN -name "$file" -delete
done
echo "Done"

# Move all text dumps of WORLD in the DUMP/platform/WORLD folder
mkdir -p DUMP/$BIN/WORLD
echo "Moving all WORLD JSON files..."
for world in WORLD00 WORLD01 WORLD02 WORLD03 WORLD04; do
  find UNPACKED/$BIN/$world -name "*.bin.json" -exec mv -v {} DUMP/$BIN/WORLD \;
done
echo "Done"

# Move all text dumps of MENU in the DUMP/platform/MENU folder
mkdir -p DUMP/$BIN/MENU
echo "Moving all MENU JSON files..."
for menu in BATTLE BOSS ETC; do
  find UNPACKED/$BIN/$menu -name "*.bin.json" -exec mv -v {} DUMP/$BIN/MENU \;
done
echo "Done"

# Raw Dump and move all enemies names from binary files to DUMP/platform/ENEMIES folder
mkdir -p DUMP/$BIN/ENEMIES
echo "Dumping and moving all ENEMY JSON files..."
while read -r file; do
  if [ -f "UNPACKED/$BIN/$file" ]; then
    python bof3tool.py rawdump -i UNPACKED/$BIN/$file --offset 0x48 --quantity 8 --skip 128 --repeat 8 --trim
    mv -v UNPACKED/$BIN/$file.json DUMP/$BIN/ENEMIES
  fi
done <<< "$ENEMIES_TO_DUMP"
echo "Done"

# Raw Dump of all binary files to DUMP/platform/BINARY folder
echo "Raw Dumping all BINARY files ($PLATFORM)..."
if [ $PLATFORM == "USA" ]; then
  for cmd in "${BIN_DUMP_COMMANDS_USA[@]}"; do
    $cmd
  done
elif [ $PLATFORM == "PAL" ]; then
  for cmd in "${BIN_DUMP_COMMANDS_PAL[@]}"; do
    $cmd
  done
elif [ $PLATFORM == "PSP" ]; then
  for cmd in "${BIN_DUMP_COMMANDS_PSP[@]}"; do
    $cmd
  done
fi
echo "Done"

# Moving all RAW images to GFX/platform/RAW
mkdir -p GFX/$BIN/RAW
echo "Moving all RAW images files..."
for raw in $GFX_RAW_FILES; do
  find UNPACKED/$BIN -name $raw -exec cp -v {} "GFX/$BIN/RAW" \;
done
echo "Done"

# Splitting all AREA RAW images into 4 parts
echo "Splitting all AREA RAW images into 4 parts in GFX/platform/RAW..."
python bof3tool.py split -i GFX/$BIN/RAW/AREA* -o GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 1024 --quantity 4
echo "Done"

# Split again the 4BPP RAW images parts...
echo "Splitting 4BPP RAW images parts..."
python bof3tool.py split -i GFX/$BIN/RAW/AREA016.8.bin.4 -o GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i GFX/$BIN/RAW/AREA030.14.bin.4 -o GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i GFX/$BIN/RAW/AREA104.8.bin.4 -o GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
python bof3tool.py split -i GFX/$BIN/RAW/AREA128.8.bin.4 -o GFX/$BIN/RAW --bpp 8 --tile-width 64 --tile-height 32 --resize-width 256 --quantity 2
echo "Done"

# Convert all RAW splitted files to TIM files
echo "Converting all RAW splitted files to TIM files..."
if [ $PLATFORM == "USA" ]; then
  for cmd in "${GFX_DUMP_COMMANDS_USA[@]}"; do
    $cmd
  done
elif [ $PLATFORM == "PAL" ]; then
  for cmd in "${GFX_DUMP_COMMANDS_PAL[@]}"; do
    $cmd
  done
elif [ $PLATFORM == "PSP" ]; then
  for cmd in "${GFX_DUMP_COMMANDS_PSP[@]}"; do
    $cmd
  done
fi
echo "Done"

# Move all TIM files to GFX/platform folder and remove RAW folder
echo "Moving all TIM files..."
find "GFX/$BIN/RAW" -name "*.tim" -exec mv -v {} "GFX/$BIN" \;
rm -rf GFX/$BIN/RAW
echo "Done"

# Copy binary files to be manual edited
mkdir -p BINARY/$BIN
echo "Copying all BINARY files..."
while read -r file; do
  if [ -f "UNPACKED/$BIN/$file" ]; then
    cp -v UNPACKED/$BIN/$file BINARY/$BIN
  fi
done <<< "$BIN_TO_EDIT"
echo "Done"

# Create the folders of files to be injected (before/after raw reinsert)
mkdir -p INJECT/$BIN/BEFORE_REINSERT
mkdir -p INJECT/$BIN/AFTER_REINSERT

echo "Indexing WORLD, MENU and ENEMIES dumps..."

# Index all dumps into DUMP/platform/WORLD and remove old duplicated files
python bof3tool.py index -i DUMP/$BIN/WORLD/*.json --output-strings DUMP/$BIN/dump_world.json --output-pointers DUMP/$BIN/pointers_world.json
rm -rf DUMP/$BIN/WORLD

# Index all dumps into DUMP/platform/MENU and remove old duplicated files
python bof3tool.py index -i DUMP/$BIN/MENU/*.json --output-strings DUMP/$BIN/dump_menu.json --output-pointers DUMP/$BIN/pointers_menu.json
rm -rf DUMP/$BIN/MENU

# Index all dumps into DUMP/platform/ENEMIES and remove old duplicated files
python bof3tool.py index -i DUMP/$BIN/ENEMIES/*.json --output-strings DUMP/$BIN/dump_enemies.json --output-pointers DUMP/$BIN/pointers_enemies.json
rm -rf DUMP/$BIN/ENEMIES

echo "Done"