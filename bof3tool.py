import argparse
import json
import struct
import re
import numpy as np
from pathlib import Path
from PIL import Image
from PIL import ImagePalette

version = '1.0.3'

# Map of files containing graphics to dump
gfx_map = {
    'ENDKANJI.1.bin': '4b.128w.128x32.256r',
    'FIRST.4.bin': '4b.128w.128x32.256r',
    'SCENA17.3.bin': '4b.128w.128x32.256r',
    'BATL_OVR.2.bin': '8b.64w.64x32.256r',
    'LOAD.1.bin': '4b.128w.128x32.256r',
    'START.6.bin': '4b.128w.128x32.256r',
    'BATL_DRA.1.bin': '8b.64w.64x32.128r',
    'DEMO.6.bin': '8b.64w.64x32.256r',
    'FIRST.5.bin': '4b.128w.128x32.256r',
    'FIRST.6.bin': '4b.128w.128x32.256r',
    'TURIMODE.4.bin': '8b.64w.64x32.1024r',
    'TURISHAR.2.bin': '8b.64w.64x32.256r',
    'TURISHAR.3.bin': '8b.64w.64x32.256r',
    'MAGIC008.2.bin': '4b.128w.128x32.256r',
    'MAGIC013.5.bin': '4b.128w.128x32.256r',
    'MAGIC038.8.bin': '4b.128w.128x32.256r',
    'MAGIC039.5.bin': '4b.128w.128x32.256r',
    'MAGIC040.5.bin': '4b.128w.128x32.256r',
    'MAGIC043.5.bin': '4b.128w.128x32.256r',
    'MAGIC062.5.bin': '4b.128w.128x32.256r',
    'MAGIC067.7.bin': '4b.128w.64x16.64r',
    'MAGIC069.5.bin': '4b.128w.128x32.256r',
    'MAGIC082.5.bin': '4b.128w.128x32.256r',
    'MAGIC083.5.bin': '4b.128w.128x32.256r',
    'MAGIC088.5.bin': '4b.128w.128x32.256r',
    'MAGIC225.5.bin': '4b.128w.128x32.256r',
    'BATE.2.bin': '4b.128w.128x32.256r',
    'COMMU01.1.bin': '4b.128w.128x32.256r',
    'COMMU02B.1.bin': '4b.128w.128x32.256r',
    'COMMU05.1.bin': '4b.128w.128x32.256r',
    'FIRST.5.bin': '4b.128w.128x32.256r',
    'SHISU.2.bi': '4b.128w.128x32.256r',
    'SHOP.2.bin': '4b.128w.128x32.256r',
    'SISYOU.2.bin': '4b.128w.128x32.256r',
    'START.4.bin': '4b.128w.128x32.256r',
    'STATUS.2.bin': '4b.128w.128x32.256r',
    'SCENA17.2.bin': '8b.64w.64x32.256r',
    'AREA016.6.bin': '8b.64w.64x32.1024r',
    'AREA016.8.bin': '8b.64w.64x32.1024r',
    'AREA030.14.bin': '8b.64w.64x32.1024r',
    'AREA030.21.bin': '4b.128w.128x32.256r',
    'AREA033.6.bin': '8b.64w.64x32.1024r',
    'AREA033.8.bin': '8b.64w.64x32.1024r',
    'AREA045.6.bin': '8b.64w.64x32.1024r',
    'AREA045.8.bin': '8b.64w.64x32.1024r',
    'AREA065.6.bin': '8b.64w.64x32.1024r',
    'AREA065.8.bin': '8b.64w.64x32.1024r',
    'AREA087.6.bin': '8b.64w.64x32.1024r',
    'AREA087.8.bin': '8b.64w.64x32.1024r',
    'AREA088.6.bin': '8b.64w.64x32.1024r',
    'AREA088.8.bin': '8b.64w.64x32.1024r',
    'AREA089.14.bin': '8b.64w.64x32.1024r',
    'AREA089.21.bin': '4b.128w.128x32.256r',
    'AREA115.6.bin': '8b.64w.64x32.1024r',
    'AREA115.8.bin': '8b.64w.64x32.1024r',
    'AREA121.6.bin': '8b.64w.64x32.1024r',
    'AREA121.8.bin': '8b.64w.64x32.1024r',
    'AREA128.8.bin': '4b.128w.64x32.2048r',
    'AREA129.14.bin': '8b.64w.64x32.1024r',
    'AREA129.21.bin': '4b.128w.128x32.256r',
    'AREA151.6.bin': '8b.64w.64x32.1024r',
    'AREA151.8.bin': '8b.64w.64x32.1024r',
    'AREA152.6.bin': '8b.64w.64x32.1024r',
    'AREA152.8.bin': '8b.64w.64x32.1024r'
}

def extract_gfx_values(format):
    numbers = re.findall(r'\d+', format)
    return {
        'bpp': int(numbers[0]),
        'width': int(numbers[1]),
        'tile_w': int(numbers[2]),
        'tile_h': int(numbers[3]),
        'width_resized': int(numbers[4])
    }

# Alternates array bytes
def swap_bytes(data):
    return np.vstack((data[1::2], data[::2])).T.flatten()

# 16 colors positive CLUT palette
palette_4bpp = np.array([
    0x00, 0x00, 0x10, 0x00, 0x00, 0x02, 0x10, 0x02, 0x00, 0x40, 0x10, 0x40, 0x00, 0x42, 0x10, 0x42,
    0x18, 0x63, 0x1f, 0x00, 0xe0, 0x03, 0xff, 0x03, 0x00, 0x7c, 0x1f, 0x7c, 0xe0, 0x7f, 0xff, 0x7f
], dtype=np.ubyte)

# 16 colors negative CLUT palette
palette_4bpp_negative = swap_bytes(np.flip(palette_4bpp))

# 256 colors positive CLUT palette
palette_8bpp = np.array([
    0x00, 0x00, 0x10, 0x00, 0x00, 0x02, 0x10, 0x02, 0x00, 0x40, 0x10, 0x40, 0x00, 0x42, 0x18, 0x63,
    0x78, 0x63, 0x34, 0x7b, 0x88, 0x00, 0x8c, 0x00, 0x90, 0x00, 0x94, 0x00, 0x98, 0x00, 0x9c, 0x00,
    0x00, 0x01, 0x04, 0x01, 0x08, 0x01, 0x0c, 0x01, 0x10, 0x01, 0x14, 0x01, 0x18, 0x01, 0x1c, 0x01,
    0x80, 0x01, 0x84, 0x01, 0x88, 0x01, 0x8c, 0x01, 0x90, 0x01, 0x94, 0x01, 0x98, 0x01, 0x9c, 0x01,
    0x00, 0x02, 0x04, 0x02, 0x08, 0x02, 0x0c, 0x02, 0x10, 0x02, 0x14, 0x02, 0x18, 0x02, 0x1c, 0x02,
    0x80, 0x02, 0x84, 0x02, 0x88, 0x02, 0x8c, 0x02, 0x90, 0x02, 0x94, 0x02, 0x98, 0x02, 0x9c, 0x02,
    0x00, 0x03, 0x04, 0x03, 0x08, 0x03, 0x0c, 0x03, 0x10, 0x03, 0x14, 0x03, 0x18, 0x03, 0x1c, 0x03,
    0x80, 0x03, 0x84, 0x03, 0x88, 0x03, 0x8c, 0x03, 0x90, 0x03, 0x94, 0x03, 0x98, 0x03, 0x9c, 0x03,
    0x00, 0x20, 0x04, 0x20, 0x08, 0x20, 0x0c, 0x20, 0x10, 0x20, 0x14, 0x20, 0x18, 0x20, 0x1c, 0x20,
    0x80, 0x20, 0x84, 0x20, 0x88, 0x20, 0x8c, 0x20, 0x90, 0x20, 0x94, 0x20, 0x98, 0x20, 0x9c, 0x20,
    0x00, 0x21, 0x04, 0x21, 0x08, 0x21, 0x0c, 0x21, 0x10, 0x21, 0x14, 0x21, 0x18, 0x21, 0x1c, 0x21,
    0x80, 0x21, 0x84, 0x21, 0x88, 0x21, 0x8c, 0x21, 0x90, 0x21, 0x94, 0x21, 0x98, 0x21, 0x9c, 0x21,
    0x00, 0x22, 0x04, 0x22, 0x08, 0x22, 0x0c, 0x22, 0x10, 0x22, 0x14, 0x22, 0x18, 0x22, 0x1c, 0x22,
    0x80, 0x22, 0x84, 0x22, 0x88, 0x22, 0x8c, 0x22, 0x90, 0x22, 0x94, 0x22, 0x98, 0x22, 0x9c, 0x22,
    0x00, 0x23, 0x04, 0x23, 0x08, 0x23, 0x0c, 0x23, 0x10, 0x23, 0x14, 0x23, 0x18, 0x23, 0x1c, 0x23,
    0x80, 0x23, 0x84, 0x23, 0x88, 0x23, 0x8c, 0x23, 0x90, 0x23, 0x94, 0x23, 0x98, 0x23, 0x9c, 0x23,
    0x00, 0x40, 0x04, 0x40, 0x08, 0x40, 0x0c, 0x40, 0x10, 0x40, 0x14, 0x40, 0x18, 0x40, 0x1c, 0x40,
    0x80, 0x40, 0x84, 0x40, 0x88, 0x40, 0x8c, 0x40, 0x90, 0x40, 0x94, 0x40, 0x98, 0x40, 0x9c, 0x40,
    0x00, 0x41, 0x04, 0x41, 0x08, 0x41, 0x0c, 0x41, 0x10, 0x41, 0x14, 0x41, 0x18, 0x41, 0x1c, 0x41,
    0x80, 0x41, 0x84, 0x41, 0x88, 0x41, 0x8c, 0x41, 0x90, 0x41, 0x94, 0x41, 0x98, 0x41, 0x9c, 0x41,
    0x00, 0x42, 0x04, 0x42, 0x08, 0x42, 0x0c, 0x42, 0x10, 0x42, 0x14, 0x42, 0x18, 0x42, 0x1c, 0x42,
    0x80, 0x42, 0x84, 0x42, 0x88, 0x42, 0x8c, 0x42, 0x90, 0x42, 0x94, 0x42, 0x98, 0x42, 0x9c, 0x42,
    0x00, 0x43, 0x04, 0x43, 0x08, 0x43, 0x0c, 0x43, 0x10, 0x43, 0x14, 0x43, 0x18, 0x43, 0x1c, 0x43,
    0x80, 0x43, 0x84, 0x43, 0x88, 0x43, 0x8c, 0x43, 0x90, 0x43, 0x94, 0x43, 0x98, 0x43, 0x9c, 0x43,
    0x00, 0x60, 0x04, 0x60, 0x08, 0x60, 0x0c, 0x60, 0x10, 0x60, 0x14, 0x60, 0x18, 0x60, 0x1c, 0x60,
    0x80, 0x60, 0x84, 0x60, 0x88, 0x60, 0x8c, 0x60, 0x90, 0x60, 0x94, 0x60, 0x98, 0x60, 0x9c, 0x60,
    0x00, 0x61, 0x04, 0x61, 0x08, 0x61, 0x0c, 0x61, 0x10, 0x61, 0x14, 0x61, 0x18, 0x61, 0x1c, 0x61,
    0x80, 0x61, 0x84, 0x61, 0x88, 0x61, 0x8c, 0x61, 0x90, 0x61, 0x94, 0x61, 0x98, 0x61, 0x9c, 0x61,
    0x00, 0x62, 0x04, 0x62, 0x08, 0x62, 0x0c, 0x62, 0x10, 0x62, 0x14, 0x62, 0x18, 0x62, 0x1c, 0x62,
    0x80, 0x62, 0x84, 0x62, 0x88, 0x62, 0x8c, 0x62, 0x90, 0x62, 0x94, 0x62, 0x98, 0x62, 0x9c, 0x62,
    0x00, 0x63, 0x04, 0x63, 0x08, 0x63, 0x0c, 0x63, 0x10, 0x63, 0x14, 0x63, 0xff, 0x7b, 0x94, 0x52,
    0x10, 0x42, 0x1f, 0x00, 0xe0, 0x03, 0xff, 0x03, 0x00, 0x7c, 0x1f, 0x7c, 0xe0, 0x7f, 0xff, 0x7f
], dtype=np.ubyte)

# 256 colors negative CLUT palette
palette_8bpp_negative = swap_bytes(np.flip(palette_8bpp))

# Convert from BGR to RGB
def bgr_to_rgb(data):
    output = np.copy(data)

    for i in range(0, output.size, 2):
        pixel = struct.unpack_from("<H", output, i)[0]
        r = pixel & 0x1f
        g = (pixel >> 5) & 0x1f
        b = (pixel >> 10) & 0x1f
        a = pixel & 0x8000
        pixel = a | (r << 10) | (g << 5) | b
        output[i:i+2] = np.frombuffer(struct.pack("<H", pixel), dtype=np.ubyte)

    return output

# Rearrange tiles inside image array
def rearrange_tile(image, width, tile_w, tile_h):
    image_h, image_w = image.shape

    image = np.stack(np.array(np.hsplit(image, image_w // tile_w)).reshape(image_w // tile_w, image_h // tile_h, tile_h, tile_w), axis = 1)
    img_reshaped = image.reshape((image_h // tile_h) * (image_w // tile_w), tile_h, tile_w)

    h_grid = image_h // tile_h // (width // tile_w) * (image_w // tile_w)
    w_grid = width // tile_w

    image_rearranged = img_reshaped.reshape(h_grid, w_grid, tile_h, tile_w)
    image_rearranged = image_rearranged.transpose([0, 2, 1, 3])
    image_rearranged = image_rearranged.reshape(tile_h * h_grid, tile_w * w_grid)

    return image_rearranged

# Check if valid EMI
def check_valid_emi(emi_data):
    if emi_data.size >= 4096: # TOC of 2048 bytes + one block of 2048 bytes minimum
        return emi_data[8:16].tobytes() == b'MATH_TBL'
    else:
        return False

# Check if valid TIM
def check_valid_tim(tim_data):
    if tim_data.size > 8:
        header = tim_data[0:4].tobytes()
        bpp = tim_data[4:8].tobytes()

        return header == b'\x10\x00\x00\x00' and bpp in [b'\x08\x00\x00\x00', b'\x09\x00\x00\x00']
    else:
        return False

# Count how many text block are present
def count_multi_text(data):
    if data[0:4].tobytes() == b'\x08\x00\x00\x00':
        return 2
    else:
        return 1

# Read binary file
def read_file(bin_path):
    return np.fromfile(bin_path, dtype=np.ubyte)

# Write binary file
def write_file(bin_path, bin_data):
    Path(bin_path).unlink(missing_ok=True)
    Path(bin_path.parent).mkdir(parents=True, exist_ok=True)
    bin_data.tofile(bin_path)

# Check and read JSON file
def read_json(json_path):
    try:
        with json_path.open(encoding="UTF-8") as source:
            return json.load(source)
    except ValueError:
        raise Exception(f'File {input} is not valid JSON file.')

# Write JSON file
def write_json(json_path, json_data):
    with json_path.open("w", encoding="UTF-8") as target:
        try:
            json.dump(json_data, target, ensure_ascii=False, indent=4)
        except Exception as err:
            print(f'Error writing JSON file {json_path}: {err}.')

# Decode BIN data into UTF-8 text
def decode_text(data, extra_table):
    text = ''
    data_offset = 0
    
    while data_offset < data.size:
        b = data[data_offset]
        data_offset += 1

        if b == 0x00: # <END>
            text += '<END>'
        elif b == 0x01: # <NL>
            text += '<NL>'
        elif b == 0x02: # <CLEAR>
            text += '<CLEAR>'
        elif b == 0x03: # <PLAYER>
            text += '<PLAYER>'
        elif b == 0x04: # <Character name>
            pg = data[data_offset]
            data_offset += 1
            if pg == 0x00:
                text += '<RYU>'
            elif pg == 0x01:
                text += '<NINA>'
            elif pg == 0x02:
                text += '<GARR>'
            elif pg == 0x03:
                text += '<TEEPO>'
            elif pg == 0x04:
                text += '<REI>'
            elif pg == 0x05:
                text += '<MOMO>'
            elif pg == 0x06:
                text += '<PECO>'
            else:
                text += f'<HEX 04><HEX {pg:02x}>'
        elif b == 0x05: # <COLOR>
            color = data[data_offset]
            data_offset += 1
            if color == 0x01:
                text += '<PURPLE>'
            elif color == 0x02:
                text += '<RED>'
            elif color == 0x03:
                text += '<CYAN>'
            elif color == 0x04:
                text += '<YELLOW>'
            elif color == 0x05:
                text += '<PINK>'
            elif color == 0x06:
                text += '<GREEN>'
            elif color == 0x07:
                text += '<BLACK>'
            else:
                text += f'<HEX 05><HEX {color:02x}>'
        elif b == 0x06: # <END_COLOR>
            text += '<END_COLOR>'
        elif b == 0x07: # <ITEM xx>
            item = data[data_offset]
            data_offset += 1
            text += f'<ITEM {item:02x}>'
        elif b == 0x10: # <FAST>
            text += '<FAST>'
        elif b == 0x11: # <END_FAST>
            text += '<END_FAST>'
        elif b == 0x0B: # <PAUSE>
            text += '<PAUSE>'
        elif b == 0x0C: # <POS xx>
            position = data[data_offset]
            data_offset += 1
            text += f'<POS {position:02x}>'
        elif b == 0x0D: # <TEXT_ANIMATION>
            text += '<TEXT_ANIMATION>'
        elif b == 0x0a: # <SOUND xx>
            sound = data[data_offset]
            data_offset += 1
            text += f'<SOUND {sound:02x}>'
        elif b == 0x0e: # <EFFECT xx>
            effect = effect = data[data_offset]
            data_offset += 1

            if effect == 0x0f:
                value = data[data_offset]
                data_offset += 1
                text += f'<EFFECT {value:02x}>'
            elif effect == 0x00:
                text += '<EFFECT_DEFAULT>'
            else:
                text += f'<HEX 0e><HEX {effect:02x}>'
        elif b == 0x0f: # <RUMBLE>
            data_offset += 2 # skip 0402
            text += f'<RUMBLE>'
        elif b == 0x14: # <CHOICE xx_xx>
            choice1 = data[data_offset]
            data_offset += 2 # skip 0C
            choice2 = data[data_offset]
            data_offset += 1
            text += f'<CHOICE {choice1:02x}_{choice2:02x}>'
        elif b == 0x16: # <TIME xx>
            time = data[data_offset]
            data_offset += 1
            text += f'<TIME {time:02x}>'
        elif b == 0x20: # <END_TEXT>
            text += '<END_TEXT>'
        elif b >= 0x30 and b <= 0x39: # 0-9
            text += chr(b)
        elif b == 0x3A: # (
            text += '('        
        elif b == 0x3B: # )
            text += ')'
        elif b == 0x3C: # ,
            text += ','
        elif b == 0x3D: # -
            text += '-'
        elif b == 0x3E: # .
            text += '.'
        elif b == 0x3F: # /
            text += '/'
        elif b == 0x40: # =
            text += '='
        elif b >= 0x41 and b <= 0x5A: # A-Z
            text += chr(b)
        elif b == 0x5B: # ܅
            text += '܅'
        elif b == 0x5C: # ?
            text += '?'
        elif b == 0x5D: # !
            text += '!'
        elif b == 0x5E: # ♥️
            text += '♥️'
        elif b == 0x5F: # ♫
            text += '♫'
        elif b >= 0x61 and b <= 0x7A: # a-z
            text += chr(b)
        elif b == 0x7B: # ↑
            text += '↑'
        elif b == 0x7C: # ↓
            text += '↓'
        elif b == 0x7D: # ←
            text += '←'
        elif b == 0x7E: # →
            text += '→'
        elif b == 0x80: # ◯
            text += '◯'
        elif b == 0x81: # ×
            text += '×'
        elif b == 0x82: # △
            text += '△'
        elif b == 0x83: # □
            text += '□'
        elif b == 0x84: # ★
            text += '★'
        elif b == 0x85: # ⏵
            text += '⏵'
        elif b == 0x86: # ↖
            text += '↖'
        elif b == 0x87: # ↘
            text += '↘'
        elif b == 0x88: # ↗
            text += '↗'
        elif b == 0x89: # ↙
            text += '↙'
        elif b == 0x8A: # ©
            text += '©'
        elif b == 0x8B: # +
            text += '+'
        elif b == 0x8C: # ~
            text += '~'
        elif b == 0x8D: # &
            text += '&'
        elif b == 0x8E: # '
            text += '\''
        elif b == 0x8F: # :
            text += ':'
        elif b == 0x90: # "
            text += '"'
        elif b == 0x91: # ;
            text += ';'
        elif b == 0x92: # ·
            text += '·'
        elif b == 0x93: # %
            text += '%'
        elif b == 0xFF: # space
            text += ' '
        elif format(b, '02x') in extra_table:
            text += extra_table[format(b, '02x')]
        else:
            text += f'<HEX {b:02x}>'

    return text

# Encode UTF-8 text into BIN data
def encode_text(data, extra_table):
    text_bytes = np.array([], dtype=np.ubyte)
    data_offset = 0

    while data_offset < len(data):
        b = data[data_offset]
        data_offset += 1

        if b == '<':
            # Manages tags
            tag = ''
            tag_char = None
            while tag_char != '>' and data_offset < len(data):
                tag_char = data[data_offset]
                data_offset += 1
                if tag_char != '>': tag += tag_char

            if tag == 'END':
                text_bytes = np.hstack((text_bytes, np.array([0x00], dtype=np.ubyte)))
            elif tag == 'NL':
                text_bytes = np.hstack((text_bytes, np.array([0x01], dtype=np.ubyte)))
            elif tag == 'CLEAR':
                text_bytes = np.hstack((text_bytes, np.array([0x02], dtype=np.ubyte)))
            elif tag == 'PLAYER':
                text_bytes = np.hstack((text_bytes, np.array([0x03], dtype=np.ubyte)))
            elif tag == 'RYU':
                text_bytes = np.hstack((text_bytes, np.array([0x04, 0x00], dtype=np.ubyte)))
            elif tag == 'NINA':
                text_bytes = np.hstack((text_bytes, np.array([0x04, 0x01], dtype=np.ubyte)))
            elif tag == 'GARR':
                text_bytes = np.hstack((text_bytes, np.array([0x04, 0x02], dtype=np.ubyte)))
            elif tag == 'TEEPO':
                text_bytes = np.hstack((text_bytes, np.array([0x04, 0x03], dtype=np.ubyte)))  
            elif tag == 'REI':
                text_bytes = np.hstack((text_bytes, np.array([0x04, 0x04], dtype=np.ubyte))) 
            elif tag == 'MOMO':
                text_bytes = np.hstack((text_bytes, np.array([0x04, 0x05], dtype=np.ubyte))) 
            elif tag == 'PECO':
                text_bytes = np.hstack((text_bytes, np.array([0x04, 0x06], dtype=np.ubyte))) 
            elif tag == 'PURPLE':
                text_bytes = np.hstack((text_bytes, np.array([0x05, 0x01], dtype=np.ubyte))) 
            elif tag == 'RED':
                text_bytes = np.hstack((text_bytes, np.array([0x05, 0x02], dtype=np.ubyte))) 
            elif tag == 'CYAN':
                text_bytes = np.hstack((text_bytes, np.array([0x05, 0x03], dtype=np.ubyte))) 
            elif tag == 'YELLOW':
                text_bytes = np.hstack((text_bytes, np.array([0x05, 0x04], dtype=np.ubyte))) 
            elif tag == 'PINK':
                text_bytes = np.hstack((text_bytes, np.array([0x05, 0x05], dtype=np.ubyte))) 
            elif tag == 'GREEN':
                text_bytes = np.hstack((text_bytes, np.array([0x05, 0x06], dtype=np.ubyte))) 
            elif tag == 'BLACK':
                text_bytes = np.hstack((text_bytes, np.array([0x05, 0x07], dtype=np.ubyte))) 
            elif tag == 'END_COLOR':
                text_bytes = np.hstack((text_bytes, np.array([0x06], dtype=np.ubyte))) 
            elif tag == 'FAST':
                text_bytes = np.hstack((text_bytes, np.array([0x10], dtype=np.ubyte))) 
            elif tag == 'END_FAST':
                text_bytes = np.hstack((text_bytes, np.array([0x11], dtype=np.ubyte))) 
            elif tag == 'PAUSE':
                text_bytes = np.hstack((text_bytes, np.array([0x0B], dtype=np.ubyte))) 
            elif tag == 'TEXT_ANIMATION':
                text_bytes = np.hstack((text_bytes, np.array([0x0D], dtype=np.ubyte)))
            elif tag == 'EFFECT_DEFAULT':
                text_bytes = np.hstack((text_bytes, np.array([0x0E, 0x00], dtype=np.ubyte)))
            elif tag == 'RUMBLE':
                text_bytes = np.hstack((text_bytes, np.array([0x0F, 0x04, 0x02], dtype=np.ubyte))) 
            elif tag == 'END_TEXT':
                text_bytes = np.hstack((text_bytes, np.array([0x20], dtype=np.ubyte))) 
            else:
                tag = tag.split(' ')
                if len(tag) == 2:
                    if tag[0] == 'ITEM':
                        text_bytes = np.hstack((text_bytes, np.array([0x07, int(tag[1], 16)], dtype=np.ubyte))) 
                    elif tag[0] == 'POS':
                        text_bytes = np.hstack((text_bytes, np.array([0x0C, int(tag[1], 16)], dtype=np.ubyte))) 
                    elif tag[0] == 'SOUND':
                        text_bytes = np.hstack((text_bytes, np.array([0x0A, int(tag[1], 16)], dtype=np.ubyte))) 
                    elif tag[0] == 'EFFECT':
                        text_bytes = np.hstack((text_bytes, np.array([0x0E, 0x0F, int(tag[1], 16)], dtype=np.ubyte))) 
                    elif tag[0] == 'CHOICE':
                        text_bytes = np.hstack((text_bytes, np.array([0x14, int(tag[1].split('_')[0], 16), 0x0C, int(tag[1].split('_')[1], 16)], dtype=np.ubyte))) 
                    elif tag[0] == 'TIME':
                        text_bytes = np.hstack((text_bytes, np.array([0x16, int(tag[1], 16)], dtype=np.ubyte))) 
                    elif tag[0] == 'HEX':
                        text_bytes = np.hstack((text_bytes, np.array([int(tag[1], 16)], dtype=np.ubyte))) 
                    else:
                        raise Exception(f'Tag <{" ".join(tag)}> in string "{data}" not valid.')
                else:
                    print(f'Tag <{" ".join(tag)}> not managed, skipped.')
        else:
            # Normal characters
            if ord(b) >= 0x30 and ord(b) <= 0x39: # 0-9
                text_bytes = np.hstack((text_bytes, np.frombuffer(b.encode('utf8'), dtype=np.ubyte)))
            elif b == '(': # (
                text_bytes = np.hstack((text_bytes, np.array([0x3A], dtype=np.ubyte)))
            elif b == ')': # )
                text_bytes = np.hstack((text_bytes, np.array([0x3B], dtype=np.ubyte)))
            elif b == ',': # ,
                text_bytes = np.hstack((text_bytes, np.array([0x3C], dtype=np.ubyte)))
            elif b == '-': # -
                text_bytes = np.hstack((text_bytes, np.array([0x3D], dtype=np.ubyte)))
            elif b == '.': # .
                text_bytes = np.hstack((text_bytes, np.array([0x3E], dtype=np.ubyte)))
            elif b == '/': # /
                text_bytes = np.hstack((text_bytes, np.array([0x3F], dtype=np.ubyte)))
            elif b == '=': # =
                text_bytes = np.hstack((text_bytes, np.array([0x40], dtype=np.ubyte)))
            elif ord(b) >= 0x41 and ord(b) <= 0x5A: # A-Z
                text_bytes = np.hstack((text_bytes, np.frombuffer(b.encode('utf8'), dtype=np.ubyte)))
            elif b == '܅': # ܅
                text_bytes = np.hstack((text_bytes, np.array([0x5B], dtype=np.ubyte)))
            elif b == '?': # ?
                text_bytes = np.hstack((text_bytes, np.array([0x5C], dtype=np.ubyte)))
            elif b == '!': # !
                text_bytes = np.hstack((text_bytes, np.array([0x5D], dtype=np.ubyte)))
            elif b == '♥️': # ♥️
                text_bytes = np.hstack((text_bytes, np.array([0x5E], dtype=np.ubyte)))
            elif b == '♫': # ♫
                text_bytes = np.hstack((text_bytes, np.array([0x5F], dtype=np.ubyte)))
            elif ord(b) >= 0x61 and ord(b) <= 0x7A: # a-z
                text_bytes = np.hstack((text_bytes, np.frombuffer(b.encode('utf8'), dtype=np.ubyte)))
            elif b == '↑': # ↑
                text_bytes = np.hstack((text_bytes, np.array([0x7B], dtype=np.ubyte)))
            elif b == '↓': # ↓
                text_bytes = np.hstack((text_bytes, np.array([0x7C], dtype=np.ubyte)))
            elif b == '←': # ←
                text_bytes = np.hstack((text_bytes, np.array([0x7D], dtype=np.ubyte)))
            elif b == '→': # →
                text_bytes = np.hstack((text_bytes, np.array([0x7E], dtype=np.ubyte)))
            elif b == '◯': # ◯
                text_bytes = np.hstack((text_bytes, np.array([0x80], dtype=np.ubyte)))
            elif b == '×': # ×
                text_bytes = np.hstack((text_bytes, np.array([0x81], dtype=np.ubyte)))
            elif b == '△': # △
                text_bytes = np.hstack((text_bytes, np.array([0x82], dtype=np.ubyte)))
            elif b == '□': # □
                text_bytes = np.hstack((text_bytes, np.array([0x83], dtype=np.ubyte)))
            elif b == '★': # ★
                text_bytes = np.hstack((text_bytes, np.array([0x84], dtype=np.ubyte)))
            elif b == '⏵': # ⏵
                text_bytes = np.hstack((text_bytes, np.array([0x85], dtype=np.ubyte)))
            elif b == '↖': # ↖
                text_bytes = np.hstack((text_bytes, np.array([0x86], dtype=np.ubyte)))
            elif b == '↘': # ↘
                text_bytes = np.hstack((text_bytes, np.array([0x87], dtype=np.ubyte)))
            elif b == '↗': # ↗
                text_bytes = np.hstack((text_bytes, np.array([0x88], dtype=np.ubyte)))
            elif b == '↙': # ↙
                text_bytes = np.hstack((text_bytes, np.array([0x89], dtype=np.ubyte)))
            elif b == '©': # ©
                text_bytes = np.hstack((text_bytes, np.array([0x8A], dtype=np.ubyte)))
            elif b == '+': # +
                text_bytes = np.hstack((text_bytes, np.array([0x8B], dtype=np.ubyte)))
            elif b == '~': # ~
                text_bytes = np.hstack((text_bytes, np.array([0x8C], dtype=np.ubyte)))
            elif b == '&': # &
                text_bytes = np.hstack((text_bytes, np.array([0x8D], dtype=np.ubyte)))
            elif b == '\'': # '
                text_bytes = np.hstack((text_bytes, np.array([0x8E], dtype=np.ubyte)))
            elif b == ':': # :
                text_bytes = np.hstack((text_bytes, np.array([0x8F], dtype=np.ubyte)))
            elif b == '"': # "
                text_bytes = np.hstack((text_bytes, np.array([0x90], dtype=np.ubyte)))
            elif b == ';': # ;
                text_bytes = np.hstack((text_bytes, np.array([0x91], dtype=np.ubyte)))
            elif b == '·': # ·
                text_bytes = np.hstack((text_bytes, np.array([0x92], dtype=np.ubyte)))
            elif b == '%': # %
                text_bytes = np.hstack((text_bytes, np.array([0x93], dtype=np.ubyte)))
            elif b == ' ': # space
                text_bytes = np.hstack((text_bytes, np.array([0xFF], dtype=np.ubyte)))
            elif b in extra_table:
                text_bytes = np.hstack((text_bytes, np.array(bytearray.fromhex(extra_table[b]), dtype=np.ubyte)))
            else:
                raise Exception(f'Character "{b}" in string "{data}" is not allowed.')

    return text_bytes

# Unpack EMI file into BIN files
def unpack(input, output_dir='', dump_txt=False, dump_gfx=False, extra_table={}, verbose=False):
    json_path = Path(output_dir) / f'{input.stem}.json'

    emi_file = read_file(input)
    json_data = {}

    if not check_valid_emi(emi_file):
        raise Exception(f'File {input} is not valid EMI file.')

    (Path(output_dir) / input.stem).mkdir(parents=True, exist_ok=True)

    emi_toc = emi_file[0:2048]
    emi_current_offset = 2048

    emi_data_blocks = struct.unpack('<I', emi_toc[0:4])[0] # uint32 little endian
    emi_unknown = emi_toc[4:8].tobytes().hex().upper()
    emi_header = emi_toc[8:16].tobytes().decode('utf-8')

    json_data['emi_file_name'] = input.name
    json_data['emi_size'] = emi_file.size
    json_data['emi_data_blocks'] = emi_data_blocks
    json_data['emi_unknown'] = emi_unknown
    json_data['emi_header'] = emi_header
    json_data['data_blocks'] = []

    print(f'Unpacking {input} into {json_path} and data blocks({emi_data_blocks})...')

    if verbose:
        print(f'EMI Original size: {emi_file.size}')
        print(f'EMI Data blocks: {emi_data_blocks}')
        print(f'EMI unknown: {emi_unknown}')
        print(f'EMI header: {emi_header}')

    for data_block_number in range(1, emi_data_blocks + 1):
        bin_path = Path(output_dir) / f'{input.stem}' / f'{input.stem}.{data_block_number}.bin'
        data_block_toc = emi_toc[data_block_number * 16:(data_block_number * 16) + 16]

        data_block_size = struct.unpack('<I', data_block_toc[0:4])[0] # uint32 little endian
        data_block_padding_size = 2048 - (data_block_size % 2048) if 2048 - (data_block_size % 2048) != 2048 else 0
        data_block_ram_location = data_block_toc[7:3:-1].tobytes().hex().upper() # uint32 little endian
        data_block_crc = data_block_toc[8:12].tobytes().hex().upper() # uint32 little endian
        data_block_type = data_block_toc[12:14].tobytes().hex().upper() # uint16 little endian
        data_block_toc_padding = data_block_toc[14:16].tobytes().hex().upper() # uint16 little endian

        is_graphic = data_block_type == '0300'
        is_text = data_block_ram_location in ['80010000', '00010000', '8001A000', '0001A000']

        data_block = {
            'data_block_file_name': str(Path(f'{input.stem}/{input.stem}.{data_block_number}.bin')),
            'data_block_number': data_block_number,
            'data_block_size': data_block_size,
            'data_block_padding_size': data_block_padding_size,
            'data_block_ram_location': data_block_ram_location,
            'data_block_crc': data_block_crc,
            'data_block_type': data_block_type,
            'data_block_toc_padding': data_block_toc_padding,
            'is_graphic': is_graphic,
            'is_text': is_text
        }

        json_data['data_blocks'].append(data_block)

        if verbose:
            print(f'--- Data block {data_block_number} ---')
            print(f' Size: {data_block_size} bytes')
            print(f' Padding block: {data_block_padding_size} bytes')
            print(f' RAM Location: {data_block_ram_location}')
            print(f' CRC Hex: {data_block_crc}')
            print(f' Type Hex: {data_block_type}')
            print(f' Padding Hex: {data_block_toc_padding}')
            print(f' Contains graphic: {is_graphic}')
            print(f' Contains text: {is_text}')
            if is_text:
                print(f' Text block full at {data_block_size * 100 / (data_block_size + data_block_padding_size):.0f}%')

        write_file(bin_path, emi_file[emi_current_offset:emi_current_offset + data_block_size])
        emi_current_offset = emi_current_offset + data_block_size + data_block_padding_size
        print(f'{bin_path} created.')

        if is_text and dump_txt:
            dump_text(input=bin_path, extra_table=extra_table)

        if is_graphic and dump_gfx:
            if f'{input.stem}.{data_block_number}.bin' in gfx_map:
                img_data = extract_gfx_values(gfx_map[f'{input.stem}.{data_block_number}.bin'])
                raw_to_bmp(bin_path, None, img_data['bpp'], img_data['width'], img_data['tile_w'], img_data['tile_h'], img_data['width_resized'])

    write_json(json_path=json_path, json_data=json_data)
    print(f'EMI {input} unpacked into {emi_data_blocks} files.')

# Pack BIN files into EMI file
def pack(input, output_dir='', verbose=False):
    emi_path = Path(output_dir) / f'{input.stem}.EMI'

    json_data = read_json(input)
    emi_toc = np.full(2048, 0x2E, dtype=np.ubyte) # create new empty toc

    emi_size = json_data.get('emi_size')
    emi_data_blocks = json_data.get('emi_data_blocks')
    emi_unknown = json_data.get('emi_unknown')
    emi_header = json_data.get('emi_header')

    print(f'Packing {input} into {emi_path}...')
    if verbose:
        print(f'EMI Original size: {emi_size}')
        print(f'EMI Data blocks: {emi_data_blocks}')
        print(f'EMI unknown: {emi_unknown}')
        print(f'EMI header: {emi_header}')

    emi_toc[0:4] = np.frombuffer(struct.pack('<I', emi_data_blocks), dtype=np.ubyte)
    emi_toc[4:8] = bytearray.fromhex(emi_unknown)
    emi_toc[8:16] = np.frombuffer(emi_header.encode('utf-8'), dtype=np.ubyte)

    data_blocks = np.full(emi_size - 2048, 0x5F, dtype=np.ubyte)
    data_blocks_offset = 0

    for data_block_number in range(1, emi_data_blocks + 1):
        data_block = json_data.get('data_blocks')[data_block_number - 1]
        data_block_file_name = data_block.get('data_block_file_name')
        data_block_size = data_block.get('data_block_size')
        data_block_padding_size = data_block.get('data_block_padding_size')
        data_block_ram_location = data_block.get('data_block_ram_location')
        data_block_crc = data_block.get('data_block_crc')
        data_block_type = data_block.get('data_block_type')
        data_block_toc_padding = data_block.get('data_block_toc_padding')
        is_graphic = data_block.get('is_graphic')
        is_text = data_block.get('is_text')
        data_bin = read_file(input.parent / data_block_file_name)
        data_bin_size = data_bin.size
        data_bin_padding_size = 2048 - (data_bin_size % 2048) if 2048 - (data_bin_size % 2048) != 2048 else 0
        
        if verbose:
            print(f'--- Data block {data_block_number} ---')
            print(f' Original Size: {data_block_size} bytes')
            print(f' Original padding block: {data_block_padding_size} bytes')
            print(f' New Size: {data_bin_size} bytes')
            print(f' New padding block: {data_bin_padding_size} bytes')
            print(f' RAM Location: {data_block_ram_location}')
            print(f' Original CRC Hex: {data_block_crc}')
            print(f' New CRC Hex: {data_bin[0:4].tobytes().hex().upper()}')
            print(f' Type Hex: {data_block_type}')
            print(f' Padding Hex: {data_block_toc_padding}')
            print(f' Contains graphic: {is_graphic}')
            print(f' Contains text: {is_text}')
            if is_text:
                print(f' Original text block full at {data_block_size * 100 / (data_block_size + data_block_padding_size):.0f}%')
                print(f' New text block full at {data_bin_size * 100 / (data_bin_size + data_bin_padding_size):.0f}%')

        if not data_bin_size <= data_block_size + data_block_padding_size:
            if is_text:
                if data_bin_size + data_block_padding_size > 22528: # Over 0x5800 bytes limit
                    raise Exception(f'Text data block {data_block_number} is too big even after expansion to 22528 bytes, cannot be injected.')
                else:
                    print(f'New text data block expanded to {data_block_size + data_block_padding_size} bytes (<= 22528 bytes limit)')
            else:
                raise Exception(f'Data block {data_block_number} is too big, cannot be injected.')

        data_block_toc = np.full(16, 0x2E, dtype=np.ubyte)
        data_block_toc[0:4] = np.frombuffer(struct.pack('<I', data_bin_size), dtype=np.ubyte)
        data_block_toc[7:3:-1] = bytearray.fromhex(data_block_ram_location)
        data_block_toc[8:12] = data_bin[0:4]
        data_block_toc[12:14] = bytearray.fromhex(data_block_type)

        emi_toc[data_block_number * 16:(data_block_number * 16) + 16] = data_block_toc
        data_blocks[data_blocks_offset:data_blocks_offset + data_bin_size] = data_bin
        data_blocks_offset = data_blocks_offset + data_bin_size + data_bin_padding_size

    write_file(emi_path, np.concatenate([emi_toc, data_blocks]))
    print(f'{emi_path} created.')

# Dump text from BIN file
def dump_text(input, output=None, extra_table={}, verbose=False):
    if not output:
        output = input.parent / f'{input.name}.json'
    else:
        output = Path(output)

    bin = read_file(input)
    texts_number = count_multi_text(bin)
    extra_table = dict((k.lower(), v) for k, v in extra_table.items()) # key in lower case when dumping

    json_data = {}
    blocks = []

    if texts_number == 2:
        blocks.append(('block0', struct.unpack('<L', bin[0:4])[0], struct.unpack('<L', bin[4:8])[0]))
        blocks.append(('block1', struct.unpack('<L', bin[4:8])[0], bin.size))
    else:
        blocks.append(('block0', 0, bin.size))

    for block, start, end in blocks:
        data = bin[start:end]
        pointers_size = struct.unpack('<H', data[0:2])[0]
        print(f'Dumping {pointers_size // 2} strings from {block} of {input} into {output}...')

        strings = []
        finish = False

        for i in range(0, pointers_size, 2):
            start_offset = struct.unpack('<H', data[i:i+2])[0]
            end_offset = struct.unpack('<H', data[i+2:i+4])[0] if i+2 < pointers_size else data.size

            if end_offset < start_offset:
                finish = True
                print('Reached end of valid pointers, skipping next.')
                decoded_text = decode_text(data[start_offset:end_offset if end_offset >= start_offset else data.size], extra_table)
                strings.append(decoded_text)
                continue

            if finish:
                strings.append(0)
            else:
                decoded_text = decode_text(data[start_offset:end_offset if end_offset >= start_offset else data.size], extra_table)
                if verbose and decoded_text != '':
                    print(f' Original data: {" ".join(["{:02x}".format(x) for x in data[start_offset:end_offset]])}')
                    print(f' Decoded text: {decoded_text}')

                strings.append(decoded_text)
        
        json_data[block] = strings

    write_json(output, json_data)
    print('Text dumped.')

# Translate a JSON using Amazon Translate (ML)
def translate_texts(input, output, source_lang, target_lang, verbose=False):
    strings_json = read_json(input)

    if len(strings_json) <= 0:
        raise Exception('Empty JSON file.')

    output = Path(output)
    
    import boto3
    client = boto3.client('translate')
    translated_strings = {}
    lines_translated = 0
    characterd_translated = 0

    for block in strings_json.keys():
        print(f"Translating {len(strings_json[block])} strings of {block} from '{source_lang}' to '{target_lang}' using Amazon Translate (ML)...")
        translated_strings[block] = []

        for line in strings_json[block]:
            if line != "":
                translate_response = client.translate_text(
                    Text=line,
                    SourceLanguageCode=source_lang,
                    TargetLanguageCode=target_lang,
                    Settings={
                        'Formality': 'INFORMAL'
                    }
                )
                translated_line = translate_response['TranslatedText']
                lines_translated = lines_translated + 1
                characterd_translated = characterd_translated + len(line)

                if verbose:
                    print(f' Original text: {line}...')
                    print(f' Translated text: {translated_line}...')

                translated_strings[block].append(translated_line)
            else:
                translated_strings[block].append(line)

    write_json(output, translated_strings)
    print(f"File {input} translated into {output} from '{source_lang}' to '{target_lang}' using Amazon Translate (ML).")
    print(f"{lines_translated} strings translated for a total of {characterd_translated} characters.")

# Reinsert text into BIN file
def reinsert_text(input, output=None, extra_table={}, verbose=False):
    if not output:
        output = input.parent / f'{input.stem}.bin'
    else:
        output = Path(output)

    extra_table = dict((k, v.lower()) for k, v in extra_table.items()) # value in lower case when reinserting
    json_data = read_json(input)
    blocks = json_data.keys()
    output_data = np.array([], dtype=np.ubyte)

    is_multi_block = len(blocks) > 1

    if is_multi_block:
        # Create an empty buffer for blocks pointers
        output_data = np.zeros(len(blocks) * 4, dtype=np.ubyte)

    for index, block in enumerate(blocks):
        # Write block pointer offset
        if is_multi_block:
            output_data[index*4:(index+1)*4] = np.frombuffer(struct.pack('<L', output_data.size), dtype=np.ubyte)

        strings = json_data[block]
        print(f'Reinserting {len(strings)} strings from {block} of {input} into {output}...')

        bin_pointers = np.full(len(strings) * 2, 0x00, dtype=np.ubyte)
        bin_text = np.array([], dtype=np.ubyte)
        offset = bin_pointers.size
        bin_pointers[0:2] = np.frombuffer(struct.pack('<H', offset), dtype=np.ubyte)

        for i in range(0, len(strings), 1):
            if strings[i] == 0:
                # Needed only for AREA030.19.bin, AREA089.19.bin, AREA129.19.bin
                pointer_recycled = bin_pointers.size

                if i == len(strings) - 1:
                    pointer_recycled = offset

                bin_pointers[i*2:(i*2)+2] = np.frombuffer(struct.pack('<H', pointer_recycled), dtype=np.ubyte)
            elif strings[i] == '':
                bin_pointers[i*2:(i*2)+2] = np.frombuffer(struct.pack('<H', offset), dtype=np.ubyte)
            else:
                text_encoded = encode_text(strings[i], extra_table)

                if verbose and strings[i] != '':
                    print(f' Original text: {strings[i]}')
                    print(f' Encoded data: {" ".join(["{:02x}".format(x) for x in text_encoded])}')

                bin_pointers[i*2:(i*2)+2] = np.frombuffer(struct.pack('<H', offset), dtype=np.ubyte)
                offset += text_encoded.size
                bin_text = np.hstack((bin_text, text_encoded))

        output_data = np.concatenate([output_data, np.concatenate([bin_pointers, bin_text], dtype=np.ubyte)], dtype=np.ubyte)

    write_file(output, np.array(output_data, dtype=np.ubyte))
    print('Text reinserted.')

# Index all texts into single file
def index_texts(inputs, output_strings, output_pointers, verbose=False):
    strings_json = {'blocks': [""]}
    pointers_json = {}
    info = {}

    print(f'Indexing {len(inputs)} JSON files into {output_strings}/{output_pointers}...')

    for input in inputs:
        json_data = read_json(input)
        blocks = json_data.keys()

        for block in blocks:
            if input.name not in pointers_json:
                pointers_json[input.name] = {}

            pointers_json[input.name][block] = []

            if block not in info:
                info[block] = {
                    'repeated_lines': 0,
                    'indexed_lines': 0
                }

            if verbose:
                print(f' Indexing {input.name} JSON {block}...')

            for string in json_data[block]:
                if string in strings_json['blocks']:
                    pointer = strings_json['blocks'].index(string)
                    if verbose and string != '':
                        print(f' String "{string}" found at position {pointer}.')
                    pointers_json[input.name][block].append(pointer)
                    if string != '':
                        info[block]['repeated_lines'] += 1
                else:
                    strings_json['blocks'].append(string)
                    if verbose and string != '':
                        print(f' String "{string}" is new, adding at position {len(strings_json["blocks"]) - 1}.')
                    pointers_json[input.name][block].append(strings_json['blocks'].index(string))
                    info[block]['indexed_lines'] += 1

    write_json(Path(output_strings), strings_json)
    write_json(Path(output_pointers), pointers_json)

    for block in info:
        print(f"Indexed {info[block]['indexed_lines']} strings ({info[block]['repeated_lines']} repeated strings) for {block}.")

# Expand an indexed file into multiple files
def expand_texts(input_strings, input_pointers, output_dir='', verbose=False):
    strings_json = read_json(input_strings)
    pointers_json = read_json(input_pointers)

    if len(strings_json) <= 0 and len(pointers_json) <= 0:
        raise Exception('Invalid strings/pointers files.')

    Path(output_dir).mkdir(parents=True, exist_ok=True)
    print(f'Expanding {len(pointers_json)} files...')

    strings = {}
    string_expanded = 0

    for filename, blocks in pointers_json.items():
        if verbose:
            print(f' Recreating file {filename}...')

        for block in blocks:
            if verbose:
                print(f' Expanding block {block}...')

            strings[block] = []

            for pointer in pointers_json[filename][block]:
                if strings_json['blocks'][pointer] != "":
                    string_expanded += 1
                    if verbose:
                        print(f' Adding string "{strings_json["blocks"][pointer]}" at position {pointer} into {filename} file.')
                strings[block].append(strings_json['blocks'][pointer])

        write_json(Path(output_dir) / filename, strings)
        print(f'File {filename} recreated.')
    
    print(f'Expanded {len(pointers_json)} files using {string_expanded} indexed strings.')

# Convert RAW graphic to TIM (PSX)
def raw_to_tim(input, output, bpp, raw_width, tile_w=None, tile_h = None, resize_width = None):
    if not output:
        if tile_w and tile_h and resize_width:
            output = input.parent / f'{input.name}.{bpp}b.{raw_width}w.{tile_w}x{tile_h}.{resize_width}r.tim'
        else:
            output = input.parent / f'{input.name}.{bpp}b.{raw_width}w.tim'
    else:
        output = Path(output)
    
    raw = read_file(input)
    raw_height = raw.size // raw_width * 2 if bpp == 4 else raw.size // raw_width

    if resize_width and tile_w and resize_width % tile_w != 0:
        raise Exception(f'Image resize width {resize_width} not multiple of {tile_w}.')

    if resize_width and raw_height % tile_h != 0:
        raise Exception(f'Image height {raw_height} not multiple of {tile_h}.')

    if resize_width and tile_w and tile_h:
        print(f'Coverting RAW {input.name} in TIM {output} using {bpp}bpp, final width size {resize_width} using tile of {tile_w}x{tile_h}...')
    else:
        print(f'Coverting RAW {input.name} in TIM {output} using {bpp}bpp, size {raw_width}x{raw_height}...')

    tim_header = np.full(96 if bpp == 4 else 1056, 0x00, dtype=np.ubyte) # TIM hedaer + CLUTs
    tim_header[0:4] = np.frombuffer(struct.pack('<I', 0x10), dtype=np.ubyte) # TIM Header 10 00 00 00

    if bpp == 4:
        raw = raw.reshape(raw_height, raw_width // 2)

        # Rearrange tile inside image
        if resize_width and tile_w and tile_h:
            raw = rearrange_tile(raw, resize_width // 2, tile_w // 2, tile_h)

        tim_header[4:8] = np.frombuffer(struct.pack('<I', 0x08), dtype=np.ubyte) # TIM 4bpp 08 00 00 00
        tim_header[8:12] = np.frombuffer(struct.pack('<I', 12 + 32 + 32), dtype=np.ubyte) # size of CLUTs + 12
        tim_header[12:14] = np.frombuffer(struct.pack('<H', 0), dtype=np.ubyte) # palette memory address X
        tim_header[14:16] = np.frombuffer(struct.pack('<H', 0), dtype=np.ubyte) # palette memory address Y
        tim_header[16:18] = np.frombuffer(struct.pack('<H', 16), dtype=np.ubyte) # number of colors in each CLUT
        tim_header[18:20] = np.frombuffer(struct.pack('<H', 2), dtype=np.ubyte) # number of CLUTs
        tim_header[20:52] = palette_4bpp # positive 4bpp palette
        tim_header[52:84] = palette_4bpp_negative # negative 4bpp palette
        tim_header[84:88] = np.frombuffer(struct.pack('<I', 12 + raw.nbytes), dtype=np.ubyte) # size of raw
        tim_header[88:90] = np.frombuffer(struct.pack('<H', 0), dtype=np.ubyte) # image memory address X
        tim_header[90:92] = np.frombuffer(struct.pack('<H', 0), dtype=np.ubyte) # image memory address Y
        h, w = raw.shape
        tim_header[92:94] = np.frombuffer(struct.pack('<H', w // 2), dtype=np.ubyte) # width / 2
        tim_header[94:96] = np.frombuffer(struct.pack('<H', h), dtype=np.ubyte) # size of raw / width * 2

    if bpp == 8:
        raw = raw.reshape(raw_height, raw_width)

        # Rearrange tile inside image
        if resize_width and tile_w and tile_h:
            raw = rearrange_tile(raw, resize_width, tile_w, tile_h)

        tim_header[4:8] = np.frombuffer(struct.pack('<I', 0x09), dtype=np.ubyte) # TIM 8bpp 09 00 00 00
        tim_header[8:12] = np.frombuffer(struct.pack('<I', 12 + 512 + 512), dtype=np.ubyte) # size of CLUTs + 12
        tim_header[12:14] = np.frombuffer(struct.pack('<H', 0), dtype=np.ubyte) # palette memory address X
        tim_header[14:16] = np.frombuffer(struct.pack('<H', 0), dtype=np.ubyte) # palette memory address Y
        tim_header[16:18] = np.frombuffer(struct.pack('<H', 256), dtype=np.ubyte) # number of colors in each CLUT
        tim_header[18:20] = np.frombuffer(struct.pack('<H', 2), dtype=np.ubyte) # number of CLUTs
        tim_header[20:532] = palette_8bpp # positive 8bpp palette
        tim_header[532:1044] = palette_8bpp_negative # negative 8bpp palette
        tim_header[1044:1048] = np.frombuffer(struct.pack('<I', 12 + raw.nbytes), dtype=np.ubyte) # size of raw
        tim_header[1048:1050] = np.frombuffer(struct.pack('<H', 0), dtype=np.ubyte) # image memory address X
        tim_header[1050:1052] = np.frombuffer(struct.pack('<H', 0), dtype=np.ubyte) # image memory address Y
        h, w = raw.shape
        tim_header[1052:1054] = np.frombuffer(struct.pack('<H', w // 2), dtype=np.ubyte) # width
        tim_header[1054:1056] = np.frombuffer(struct.pack('<H', h), dtype=np.ubyte) # size of raw / width
    
    write_file(output, np.concatenate([tim_header, raw.flatten()]))
    print('Done.')

# Convert TIM (PSX) to RAW graphic
def tim_to_raw(input, output, tile_w=None, tile_h = None, resize_width = None):
    if not output:
        output = input.parent / f'{input.stem}.bin'
    else:
        output = Path(output)

    tim = read_file(input)

    if not check_valid_tim(tim):
        raise Exception(f'File {input} is not valid TIM file.')

    print(f'Extracting TIM info from {input.name}...')

    bpp = struct.unpack('<I', tim[4:8])[0] # 8 -> 4bpp, 9 -> 8bpp
    clut_size = struct.unpack('<I', tim[8:12])[0] - 12
    image_width = struct.unpack('<H', tim[20 + clut_size + 8:20 + clut_size + 10])[0] * 2
    image_height = struct.unpack('<H', tim[20 + clut_size + 10:20 + clut_size + 12])[0]
    image_size = struct.unpack('<I', tim[20 + clut_size:20 + clut_size + 4])[0] - 12
    raw = tim[20 + clut_size + 12: 20 + clut_size + 12 + image_size]

    if resize_width and tile_w and resize_width % tile_w != 0:
        raise Exception(f'Image resize width {resize_width} not multiple of {tile_w}.')

    if resize_width and image_height % tile_h != 0:
        raise Exception(f'Image height {image_height} not multiple of {tile_h}.')

    if resize_width and tile_w and tile_h:
        print(f'Coverting TIM {input.name} in RAW graphic {output} using {bpp}bpp, final width size {resize_width} using tile of {tile_w}x{tile_h}...')
    else:
        print(f'Coverting TIM {input.name} in RAW graphic {output} using {bpp}bpp, size {image_width if bpp == 9 else image_width // 2}x{image_height}...')

    raw = raw.reshape(image_height, image_width)

    # Rearrange tile inside image
    if resize_width and tile_w and tile_h:
        raw = rearrange_tile(raw, resize_width // 2 if bpp == 8 else resize_width, tile_w // 2 if bpp == 8 else tile_w, tile_h)
        
    write_file(output, raw.flatten())
    print('Done.')

# Convert RAW graphic to BMP
def raw_to_bmp(input, output, bpp, raw_width, tile_w=None, tile_h = None, resize_width = None, negative=False):
    if not output:
        if tile_w and tile_h and resize_width:
            output = input.parent / f'{input.name}.{bpp}b.{raw_width}w.{tile_w}x{tile_h}.{resize_width}r.bmp'
        else:
            output = input.parent / f'{input.name}.{bpp}b.{raw_width}w.bmp'
    else:
        output = Path(output)

    raw = read_file(input)
    raw_height = raw.size // raw_width * 2 if bpp == 4 else raw.size // raw_width

    if resize_width and tile_w and resize_width % tile_w != 0:
        raise Exception(f'Image resize width {resize_width} not multiple of {tile_w}.')

    if resize_width and raw_height % tile_h != 0:
        raise Exception(f'Image height {raw_height} not multiple of {tile_h}.')

    if resize_width and tile_w and tile_h:
        print(f'Coverting RAW {input.name} in BMP {output} using {bpp}bpp, final width size {resize_width} using tile of {tile_w}x{tile_h}...')
    else:
        print(f'Coverting RAW {input.name} in BMP {output} using {bpp}bpp, size {raw_width}x{raw_height}...')

    image = None

    if bpp == 4:
        raw_8bit = np.dstack((np.bitwise_and(raw, 0x0f), np.bitwise_and(raw >> 4, 0x0f))).flatten()
        image = Image.frombytes("P", (raw_width, raw_8bit.size // raw_width), raw_8bit.tobytes(), 'raw', "P", 0, 1)
        palette = ImagePalette.raw("BGR;15", np.array(bgr_to_rgb(palette_8bpp if not negative else palette_8bpp_negative)))
        image.palette = palette

    if bpp == 8:
        image = Image.frombytes("P", (raw_width, raw.size // raw_width), raw.tobytes(), 'raw', "P", 0, 1)
        palette = ImagePalette.raw("BGR;15", np.array(bgr_to_rgb(palette_8bpp if not negative else palette_8bpp_negative)))
        image.palette = palette

    # Rearrange tile inside image
    if resize_width and tile_w and tile_h:
        palette = image.getpalette()
        image = Image.fromarray(rearrange_tile(np.asarray(image), resize_width, tile_w, tile_h))
        image.putpalette(palette)

    image.save(output, 'BMP')
    print('Done.')

# Convert BMP to RAW graphic
def bmp_to_raw(input, output, bpp, tile_w=None, tile_h = None, resize_width = None):
    if not output:
        output = input.parent / f'{input.name}.{bpp}bpp.bin'
    else:
        output = Path(output)

    bmp = Image.open(input)

    if resize_width and tile_w and resize_width % tile_w != 0:
        raise Exception(f'Image resize width {resize_width} not multiple of {tile_w}.')

    if resize_width and bmp.height % tile_h != 0:
        raise Exception(f'Image height {bmp.height} not multiple of {tile_h}.')

    if resize_width and tile_w and tile_h:
        print(f'Coverting BMP {input.name} in RAW graphic {output} using {bpp}bpp, final width size {resize_width} using tile of {tile_w}x{tile_h}...')
    else:
        print(f'Coverting BMP {input.name} in RAW graphic {output} using {bpp}bpp, size {bmp.width}x{bmp.height}...')

    if bpp == 4:
        if resize_width and tile_w and tile_h:
            bmp = Image.fromarray(rearrange_tile(np.asarray(bmp), resize_width, tile_w, tile_h))
        image = np.frombuffer(bmp.tobytes(encoder_name='raw'), dtype=np.ubyte)
        image_4bit = np.add(np.bitwise_and(image[::2], 0x0f), np.bitwise_and(image[1::2] << 4, 0xf0))
        write_file(output, image_4bit)

    if bpp == 8:
        if resize_width and tile_w and tile_h:
            bmp = Image.fromarray(rearrange_tile(np.asarray(bmp), resize_width, tile_w, tile_h))
        image = np.frombuffer(bmp.tobytes(encoder_name='raw'), dtype=np.ubyte)
        write_file(output, image)
    
    print('Done.')

def main(command_line=None):
    # Parser for extra table characters
    class ParseExtraTable(argparse.Action):
        def __call__(self, parser, namespace, values, option_string=None):
            setattr(namespace, self.dest, dict())
            for value in values:
                key, value = value.split('=')
                getattr(namespace, self.dest)[key] = value

    parser = argparse.ArgumentParser(prog='bof3tool.py', description='Breath of Fire III Tool (PSX/PSP)')
    subparser = parser.add_subparsers(help='Description', required=True, dest='command')

    unpack_parser = subparser.add_parser('unpack', help='unpack EMI files into BIN files', )
    unpack_parser.add_argument('-i', '--input', help='input .EMI files', type=Path, required=True, nargs='*')
    unpack_parser.add_argument('-o', '--output-directory', dest='output_dir', help='output directory', type=str, required=False, default='')
    unpack_parser.add_argument('--dump-text', dest='dump_txt', default=False, action='store_true', help='dump text')
    unpack_parser.add_argument('--dump-graphic', dest='dump_gfx', default=False, action='store_true', help='dump graphic')
    unpack_parser.add_argument('--extra-table', help="extra table (ex. A0=à A1=è A2=ò)", action=ParseExtraTable, required=False, nargs='+', default={})
    unpack_parser.add_argument('--verbose', default=False, action='store_true', help='show verbose logs')

    pack_parser = subparser.add_parser('pack', help='pack BIN files into EMI file')
    pack_parser.add_argument('-i', '--input', help='input .JSON files', type=Path, required=True, nargs='*')
    pack_parser.add_argument('-o', '--output-directory', dest='output_dir', help='output directory', type=str, required=False, default='')
    pack_parser.add_argument('--verbose', default=False, action='store_true', help='show verbose logs')

    dump = subparser.add_parser('dump', help='dump text from BIN file')
    dump.add_argument('-i', '--input', help='input .BIN (text) files', type=Path, required=True, nargs='*')
    dump.add_argument('-o', '--output', help='output .JSON file', type=str, required=False, default=None)
    dump.add_argument('--extra-table', help="extra table (ex. A0=à A1=è A2=ò)", action=ParseExtraTable, required=False, nargs='+', default={})
    dump.add_argument('--verbose', default=False, action='store_true', help='show verbose logs')

    translate = subparser.add_parser('translate', help='translate a JSON file using Amazon Translate (ML)')
    translate.add_argument('-i', '--input', help='input .JSON file', type=Path, required=True)
    translate.add_argument('-o', '--output', help='output .JSON file', type=str, required=False, default=None)
    translate.add_argument('--source-language', dest='source_lang', help='source language code (default en)', type=str, required=False, default='en')
    translate.add_argument('--target-language', dest='target_lang', help='target language code (fr, de, it...)', type=str, required=True, default=None)
    translate.add_argument('--verbose', default=False, action='store_true', help='show verbose logs')

    reinsert = subparser.add_parser('reinsert', help='reinsert text into BIN file')
    reinsert.add_argument('-i', '--input', help='input .JSON files', type=Path, required=True, nargs='*')
    reinsert.add_argument('-o', '--output', help='output .BIN (text) file', type=str, required=False, default=None)
    reinsert.add_argument('--extra-table', help="extra table (ex. à=A0 è=A1 ò=A2)", action=ParseExtraTable, required=False, nargs='+', default={})
    reinsert.add_argument('--verbose', default=False, action='store_true', help='show verbose logs')

    index = subparser.add_parser('index', help='index all texts into single file')
    index.add_argument('-i', '--input', help='input .JSON files', type=Path, required=True, nargs='*')
    index.add_argument('--output-strings', dest='output_strings', help='output .JSON file of strings', type=str, required=True)
    index.add_argument('--output-pointers', dest='output_pointers', help='output .JSON file of pointers', type=str, required=True)
    index.add_argument('--verbose', default=False, action='store_true', help='show verbose logs')

    expand = subparser.add_parser('expand', help='expand an indexed file into multiple files')
    expand.add_argument('--input-strings', dest='input_strings', help='input .JSON strings file', type=Path, required=True)
    expand.add_argument('--input-pointers', dest='input_pointers', help='input .JSON pointers file', type=Path, required=True)
    expand.add_argument('-o', '--output-directory', dest='output_dir', help='output directory', type=str, required=False, default='')
    expand.add_argument('--verbose', default=False, action='store_true', help='show verbose logs')

    raw2tim = subparser.add_parser('raw2tim', help='convert graphic RAW to TIM (PSX)')
    raw2tim.add_argument('-i', '--input', help='input .BIN (RAW) files', type=Path, required=True, nargs='*')
    raw2tim.add_argument('-o', '--output', help='output .TIM (PSX) file', type=str, required=False, default=None)
    raw2tim.add_argument('--bpp', help='bits per pixel', type=int, required=True, choices=[4, 8])
    raw2tim.add_argument('--width', help='image width', type=int, required=True, choices=[64, 128, 256, 512])
    raw2tim.add_argument('--tile-width', dest='tile_w', help='tile width', type=int, required=False, default=None)
    raw2tim.add_argument('--tile-height', dest='tile_h', help='tile height', type=int, required=False, default=None)
    raw2tim.add_argument('--resize-width', dest='resize_width', help='resize width', type=int, required=False, default=None)

    tim2raw = subparser.add_parser('tim2raw', help='convert TIM (PSX) to graphic RAW')
    tim2raw.add_argument('-i', '--input', help='input .TIM (PSX) files', type=Path, required=True, nargs='*')
    tim2raw.add_argument('-o', '--output', help='output .BIN (RAW) file', type=str, required=False, default=None)
    tim2raw.add_argument('--tile-width', dest='tile_w', help='tile width', type=int, required=False, default=None)
    tim2raw.add_argument('--tile-height', dest='tile_h', help='tile height', type=int, required=False, default=None)
    tim2raw.add_argument('--resize-width', dest='resize_width', help='resize width', type=int, required=False, default=None)

    raw2bmp = subparser.add_parser('raw2bmp', help='convert graphic RAW to BMP')
    raw2bmp.add_argument('-i', '--input', help='input .BIN (RAW) files', type=Path, required=True, nargs='*')
    raw2bmp.add_argument('-o', '--output', help='output .BMP file', type=str, required=False, default=None)
    raw2bmp.add_argument('--bpp', dest='bpp', help='bits per pixel', type=int, required=True, choices=[4, 8])
    raw2bmp.add_argument('--width', dest='width', help='image width', type=int, required=True, choices=[64, 128, 256, 512])
    raw2bmp.add_argument('--tile-width', dest='tile_w', help='tile width', type=int, required=False, default=None)
    raw2bmp.add_argument('--tile-height', dest='tile_h', help='tile height', type=int, required=False, default=None)
    raw2bmp.add_argument('--resize-width', dest='resize_width', help='resize width', type=int, required=False, default=None)
    raw2bmp.add_argument('--negative', dest='negative', help='negative colors', action='store_true', required=False, default=False)

    bmp2raw = subparser.add_parser('bmp2raw', help='convert BMP to graphic RAW')
    bmp2raw.add_argument('-i', '--input', help='input .BMP file files', type=Path, required=True, nargs='*')
    bmp2raw.add_argument('-o', '--output', help='output .BIN (RAW)', type=str, required=False, default=None)
    bmp2raw.add_argument('--bpp', help='bits per pixel', type=int, required=True, choices=[4, 8])
    bmp2raw.add_argument('--tile-width', dest='tile_w', help='tile width', type=int, required=False, default=None)
    bmp2raw.add_argument('--tile-height', dest='tile_h', help='tile height', type=int, required=False, default=None)
    bmp2raw.add_argument('--resize-width', dest='resize_width', help='resize width', type=int, required=False, default=None)

    parser.add_argument('-v', '--version', action='version', version=f'{parser.prog} {version}')
    args = parser.parse_args(command_line)

    print(f'--- {parser.description} ---\n')

    try:
        if args.command == 'unpack':
            for path in args.input:
                unpack(input=path, output_dir=args.output_dir, dump_txt=args.dump_txt, dump_gfx=args.dump_gfx, extra_table=args.extra_table, verbose=args.verbose)
        elif args.command == 'pack':
            for path in args.input:
                pack(input=path, output_dir=args.output_dir, verbose=args.verbose)
        elif args.command == 'dump':
            for path in args.input:
                dump_text(input=path, output=args.output, extra_table=args.extra_table, verbose=args.verbose)
        elif args.command == 'translate':
            translate_texts(input=args.input, output=args.output, source_lang=args.source_lang, target_lang=args.target_lang, verbose=args.verbose)
        elif args.command == 'reinsert':
            for path in args.input:
                reinsert_text(input=path, output=args.output, extra_table=args.extra_table, verbose=args.verbose)
        elif args.command == 'index':
            index_texts(inputs=args.input, output_strings=args.output_strings, output_pointers=args.output_pointers, verbose=args.verbose)
        elif args.command == 'expand':
            expand_texts(input_strings=args.input_strings, input_pointers=args.input_pointers, output_dir=args.output_dir, verbose=args.verbose)
        elif args.command == 'raw2tim':
            for path in args.input:
                raw_to_tim(input=path, output=args.output, bpp=args.bpp, raw_width=args.width,
                    tile_w=args.tile_w, tile_h=args.tile_h, resize_width=args.resize_width)
        elif args.command == 'tim2raw':
            for path in args.input:
                tim_to_raw(input=path, output=args.output, tile_w=args.tile_w, tile_h=args.tile_h, resize_width=args.resize_width)
        elif args.command == 'raw2bmp':
            for path in args.input:
                raw_to_bmp(input=path, output=args.output, bpp=args.bpp, raw_width=args.width,
                    tile_w=args.tile_w, tile_h=args.tile_h, resize_width=args.resize_width, negative=args.negative)
        elif args.command == 'bmp2raw':
            for path in args.input:
                bmp_to_raw(input=path, output=args.output, bpp=args.bpp, tile_w=args.tile_w, tile_h=args.tile_h, resize_width=args.resize_width)
    except Exception as err:
        print(f'Error: {err}')

if __name__ == '__main__':
    main()