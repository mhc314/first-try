"""Generate the editable, deterministic 512×288 prototype pixel scenes.

Requires Pillow. Run from the project root after changing the artwork.
The game ships with the generated PNGs and does not require Python.
"""
from pathlib import Path
from random import Random
from PIL import Image, ImageDraw

SIZE = (512, 288)
OUT = Path(__file__).resolve().parent.parent / "assets" / "scenes"
OUT.mkdir(parents=True, exist_ok=True)


def gradient(draw, box, top, bottom):
    x0, y0, x1, y1 = box
    for y in range(y0, y1):
        t = (y - y0) / max(1, y1 - y0 - 1)
        color = tuple(round(a + (b - a) * t) for a, b in zip(top, bottom))
        draw.line((x0, y, x1 - 1, y), fill=color)


def studio():
    """A furnished studio, with objects drawn in proportion to the room."""
    im = Image.new("RGB", SIZE)
    d = ImageDraw.Draw(im)
    rng = Random(24)

    # Walls, baseboard and a floor with boards converging towards the back wall.
    gradient(d, (0, 0, 512, 176), (75, 94, 91), (113, 129, 116))
    d.rectangle((0, 0, 511, 12), fill="#344d4b")
    d.rectangle((0, 13, 511, 17), fill="#a1aa98")
    d.line((0, 18, 511, 18), fill="#4c6660")
    for x in (4, 129, 255, 381, 507):
        d.line((x, 18, x, 170), fill="#71877c")
        d.line((x + 1, 19, x + 1, 170), fill="#8e9e8d")
    for _ in range(240):
        x, y = rng.randrange(512), rng.randrange(22, 169)
        d.point((x, y), fill=rng.choice(("#8da08e", "#839888", "#788e83")))
    d.rectangle((0, 170, 511, 176), fill="#d1c6a5")
    d.line((0, 177, 511, 177), fill="#4d5650", width=2)
    gradient(d, (0, 179, 512, 288), (133, 108, 86), (91, 72, 62))
    for y in (185, 195, 208, 224, 245, 273):
        d.line((0, y, 511, y), fill="#715949")
        d.line((0, y + 1, 511, y + 1), fill="#a98265")
    for x in range(-320, 900, 70):
        d.line((256 + (x - 256) * 0.24, 179, x, 287), fill="#795e4e")
    for _ in range(80):
        x, y = rng.randrange(512), rng.randrange(183, 286)
        d.line((x, y, min(511, x + rng.randrange(3, 12)), y), fill="#a17d63")

    # Window and storage furniture establish the size of the room.
    d.rectangle((22, 34, 133, 139), fill="#405954")
    d.rectangle((26, 38, 129, 135), fill="#d9d6bb")
    gradient(d, (30, 42, 126, 132), (156, 198, 187), (218, 220, 189))
    d.polygon(((30, 113), (51, 94), (70, 112), (91, 91), (125, 113), (125, 131), (30, 131)), fill="#8eac91")
    d.rectangle((75, 41, 80, 132), fill="#718d80")
    d.rectangle((29, 84, 126, 88), fill="#718d80")
    d.line((32, 43, 73, 43), fill="#f1edda", width=2)
    d.rectangle((19, 136, 136, 141), fill="#d8cbae")
    d.rectangle((33, 151, 133, 203), fill="#58695d")
    d.rectangle((36, 154, 130, 162), fill="#b59c7b")
    d.rectangle((38, 165, 81, 200), fill="#78897a")
    d.rectangle((84, 165, 127, 200), fill="#78897a")
    d.line((40, 166, 79, 166), fill="#b0b6a1")
    d.line((86, 166, 125, 166), fill="#b0b6a1")
    d.rectangle((75, 180, 78, 182), fill="#e0c89f")
    d.rectangle((87, 180, 90, 182), fill="#e0c89f")
    # Small camera and books, sized as everyday objects on the cabinet.
    d.rectangle((48, 144, 66, 153), fill="#344b47")
    d.rectangle((51, 141, 61, 144), fill="#485e55")
    d.ellipse((53, 145, 61, 152), fill="#172f31")
    d.ellipse((55, 147, 59, 150), fill="#9cb6a5")
    d.rectangle((77, 149, 106, 152), fill="#a75e4b")
    d.rectangle((80, 146, 109, 148), fill="#d3be92")

    # Rolled paper backdrop and shooting table; the backdrop stops behind the tabletop.
    d.rectangle((158, 40, 349, 46), fill="#40534d")
    d.rectangle((163, 45, 344, 163), fill="#b9b8a3")
    d.rectangle((168, 49, 339, 158), fill="#d3cdb6")
    for x in (170, 173, 335, 337):
        d.line((x, 52, x, 155), fill="#c5c2ae")
    d.polygon(((168, 154), (339, 154), (354, 174), (154, 174)), fill="#c6bfa8")
    d.line((164, 45, 343, 45), fill="#e2d7bd")
    # A small reference card hangs at the back, above and to the side of the setup.
    d.rectangle((335, 75, 364, 112), fill="#4d5e52")
    d.rectangle((338, 78, 361, 109), fill="#e7d9b7")
    d.rectangle((342, 82, 357, 105), fill="#647165")
    d.rectangle((346, 85, 353, 91), fill="#e7d9b7")
    d.rectangle((346, 96, 353, 102), fill="#e7d9b7")
    d.polygon(((181, 171), (319, 171), (333, 181), (172, 181)), fill="#b79b79")
    d.polygon(((172, 181), (333, 181), (333, 187), (172, 187)), fill="#6a5549")
    d.line((178, 181, 327, 181), fill="#e1c9a3")
    for x in (184, 315):
        d.rectangle((x, 187, x + 4, 232), fill="#514d43")
        d.line((x + 1, 188, x + 1, 228), fill="#9e9178")
    d.line((188, 218, 316, 218), fill="#62594b", width=2)
    # Ceramic vase is small enough to sit naturally on the table.
    d.ellipse((237, 168, 268, 174), fill="#a69b84")
    d.polygon(((245, 143), (260, 143), (260, 148), (263, 152), (265, 160), (263, 169), (260, 172), (245, 172), (242, 169), (240, 160), (242, 152), (245, 148)), fill="#81564a")
    d.polygon(((247, 148), (258, 148), (258, 151), (261, 155), (262, 161), (260, 168), (258, 170), (246, 170), (243, 166), (243, 157), (245, 152)), fill="#c38d70")
    d.rectangle((245, 142, 260, 146), fill="#e1bb99")
    d.line((247, 144, 258, 144), fill="#88604f")
    d.line((246, 153, 245, 164), fill="#e8b99a")
    d.line((249, 163, 258, 163), fill="#d9a68a")

    # A compact softbox on a tripod, with ordinary equipment stored behind it.
    d.line((381, 97, 381, 192), fill="#354b49", width=2)
    d.line((381, 178, 366, 207), fill="#354b49", width=2)
    d.line((381, 178, 395, 207), fill="#354b49", width=2)
    d.line((381, 181, 381, 210), fill="#354b49", width=2)
    d.polygon(((363, 57), (369, 53), (393, 53), (400, 58), (397, 94), (365, 94)), fill="#354b49")
    d.polygon(((368, 60), (372, 57), (390, 57), (395, 61), (393, 89), (370, 89)), fill="#eadfc3")
    d.line((372, 60, 390, 60), fill="#fff3d3")
    d.rectangle((409, 150, 480, 206), fill="#4c6056")
    d.rectangle((413, 154, 476, 201), fill="#829181")
    d.line((415, 155, 474, 155), fill="#c4c4aa")
    d.rectangle((419, 159, 448, 178), fill="#6d8072")
    d.rectangle((453, 159, 472, 178), fill="#718575")
    d.line((443, 168, 446, 168), fill="#e4cfaa", width=2)
    d.rectangle((419, 184, 470, 197), fill="#718475")
    d.line((422, 185, 467, 185), fill="#a6af9a")
    # Foreground card on a modest stand, rather than an oversized floor sign.
    d.line((129, 220, 129, 242), fill="#46544c", width=2)
    d.line((129, 235, 121, 244), fill="#46544c", width=2)
    d.line((129, 235, 137, 244), fill="#46544c", width=2)
    d.rectangle((115, 184, 143, 221), fill="#776a53")
    d.rectangle((118, 187, 140, 218), fill="#e9dcba")
    d.line((119, 188, 139, 188), fill="#fff0ce")
    d.polygon(((123, 193), (135, 193), (135, 199), (127, 199), (127, 203), (135, 203), (135, 209), (123, 209), (123, 205), (131, 205), (131, 201), (123, 201)), fill="#4f6255")
    # Case and cable are deliberately smaller than the furniture.
    d.rectangle((437, 226, 475, 244), fill="#394e49")
    d.rectangle((440, 228, 472, 241), fill="#768879")
    d.line((442, 229, 470, 229), fill="#b3bba5")
    d.rectangle((451, 223, 461, 226), fill="#40544d")
    d.ellipse((396, 226, 424, 235), outline="#554c40")
    d.arc((400, 228, 420, 233), 0, 320, fill="#b39876")
    # The small rotating fan is drawn dynamically by the game on the cabinet.
    im.save(OUT / "studio.png", optimize=True)


def garden():
    im = Image.new("RGB", SIZE)
    d = ImageDraw.Draw(im)
    rng = Random(57)
    gradient(d, (0, 0, 512, 177), (82, 112, 101), (157, 170, 138))
    for y in (18, 170, 174):
        d.line((0, y, 511, y), fill="#526c62", width=2)
    # A broad, recessed window, with an illustrated landscape beyond it.
    d.rectangle((39, 26, 472, 169), fill="#3c5c53")
    d.rectangle((45, 32, 466, 163), fill="#e1d6ae")
    d.rectangle((50, 38, 461, 156), fill="#b4d5c6")
    gradient(d, (51, 39, 461, 156), (151, 203, 193), (221, 220, 172))
    d.ellipse((314, 47, 344, 77), fill="#f6e7b8")
    d.polygon(((51, 120), (95, 90), (140, 117), (191, 86), (241, 118), (300, 90), (354, 116), (404, 89), (461, 115), (461, 156), (51, 156)), fill="#91b39b")
    d.polygon(((51, 139), (100, 109), (150, 138), (203, 103), (260, 141), (309, 111), (373, 140), (416, 108), (461, 132), (461, 156), (51, 156)), fill="#779b7e")
    # Layered trees and dappled foliage provide depth behind the window.
    for tx, ty in ((79, 112), (151, 112), (218, 103), (294, 111), (348, 114), (430, 106)):
        d.rectangle((tx-2, ty+16, tx+2, 154), fill="#68896c")
        for ox, oy, rx, ry, col in ((0, 0, 12, 13, "#719a79"), (-9, 8, 10, 9, "#5f8a6d"), (9, 8, 10, 9, "#80a481"), (0, 12, 12, 9, "#729779")):
            d.ellipse((tx+ox-rx, ty+oy-ry, tx+ox+rx, ty+oy+ry), fill=col)
        d.rectangle((tx-8, ty-7, tx-3, ty-5), fill="#a3bea0")
        d.rectangle((tx+3, ty+1, tx+8, ty+2), fill="#a3bea0")
    for x in range(55, 460, 8):
        y = rng.randrange(129, 152)
        d.rectangle((x, y, x + rng.randrange(3, 7), 155), fill=rng.choice(("#527c64", "#638d6d", "#789c72")))
        d.rectangle((x + 1, y - 2, x + 3, y + 2), fill="#85a77b")
    for x in (49, 249, 456):
        d.rectangle((x, 36, x + 7, 158), fill="#58786c")
        d.line((x + 1, 38, x + 1, 155), fill="#d1d9b9")
    d.rectangle((51, 89, 459, 96), fill="#58786c")
    d.line((54, 90, 456, 90), fill="#d1d9b9")
    d.rectangle((35, 159, 476, 168), fill="#cabd98")
    d.line((38, 160, 473, 160), fill="#f3e3bb", width=2)
    # Window latches and glass glints.
    for x in (58, 264):
        d.line((x, 45, x, 69), fill="#d9e7d2", width=2)
        d.line((x + 4, 45, x + 14, 45), fill="#e5edda")
    d.rectangle((239, 102, 248, 106), fill="#d9cda5")
    d.rectangle((243, 99, 246, 110), fill="#e7ddba")
    gradient(d, (0, 177, 512, 288), (154, 123, 86), (82, 70, 55))
    for y in (180, 204, 230, 258, 285):
        d.line((0, y, 511, y), fill="#6a5849", width=2)
        d.line((0, y + 2, 511, y + 2), fill="#b08d68")
    for _ in range(160):
        x, y = rng.randrange(512), rng.randrange(182, 286)
        d.line((x, y, min(511, x + rng.randrange(2, 15)), y), fill=rng.choice(("#9b7d5c", "#8b6d52")))
    # A few quiet still-life details away from the flower.
    d.ellipse((62, 235, 152, 247), fill="#665a48")
    d.rectangle((72, 201, 141, 238), fill="#526b58")
    d.rectangle((77, 205, 136, 233), fill="#819678")
    d.rectangle((80, 197, 133, 204), fill="#bcc29a")
    d.line((82, 207, 82, 231), fill="#c5cba4", width=2)
    # Two books and a small ceramic cup on the table.
    d.ellipse((163, 239, 285, 248), fill="#6a5948")
    d.polygon(((167, 225), (230, 225), (240, 230), (178, 230)), fill="#52655a")
    d.rectangle((178, 230, 240, 237), fill="#e2d5b2")
    d.line((180, 234, 237, 234), fill="#b5a88d")
    d.polygon(((165, 222), (227, 222), (238, 227), (176, 227)), fill="#b98163")
    d.line((169, 223, 225, 223), fill="#e7ba92")
    d.ellipse((251, 222, 277, 238), fill="#605549")
    d.ellipse((270, 211, 281, 225), outline="#d8cfb2", width=3)
    d.polygon(((248, 210), (275, 210), (272, 232), (252, 232)), fill="#d8cfb2")
    d.rectangle((249, 209, 274, 212), fill="#f1e4c4")
    d.line((254, 214, 255, 227), fill="#fff0d0", width=2)
    d.ellipse((322, 224, 459, 239), fill="#655847")
    # Pot and flower stay entirely within the original scoring rectangle.
    d.polygon(((362, 194), (416, 194), (410, 228), (368, 228)), fill="#925c48")
    d.polygon(((366, 196), (412, 196), (406, 225), (371, 225)), fill="#c48662")
    d.rectangle((365, 190, 414, 198), fill="#e0ae80")
    d.line((369, 192, 411, 192), fill="#f3c99b")
    d.line((373, 201, 375, 220), fill="#edb38b", width=2)
    d.line((404, 200, 402, 222), fill="#a66e54", width=2)
    d.line((389, 188, 389, 132), fill="#496f51", width=4)
    d.line((390, 185, 390, 135), fill="#9ab879")
    d.polygon(((388, 164), (374, 152), (364, 150), (368, 158), (381, 165)), fill="#648b5d")
    d.line((367, 153, 384, 162), fill="#b6c787")
    d.polygon(((391, 177), (405, 162), (416, 159), (411, 169), (398, 177)), fill="#709668")
    d.line((394, 175, 413, 162), fill="#bbca8b")
    for cx, cy, rx, ry, col in ((389, 111, 9, 13, "#f7c7af"), (377, 115, 10, 10, "#eab2a1"), (401, 115, 10, 10, "#e8ac9c"), (374, 126, 10, 8, "#f5c9b4"), (404, 126, 10, 8, "#eebba7"), (381, 132, 10, 8, "#e5a697"), (397, 132, 10, 8, "#f6cbb3")):
        d.ellipse((cx-rx, cy-ry, cx+rx, cy+ry), fill=col)
        d.line((cx-rx+4, cy-ry+4, cx+2, cy-ry+4), fill="#ffe0c5")
    d.ellipse((381, 116, 397, 131), fill="#d09c50")
    d.ellipse((384, 117, 394, 127), fill="#f3cd77")
    for x, y in ((386, 120), (391, 122), (388, 125), (393, 118)):
        d.point((x, y), fill="#9b7649")
    im.save(OUT / "garden.png", optimize=True)


studio()
garden()
