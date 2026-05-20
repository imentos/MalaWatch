#!/usr/bin/env python3
"""
MalaWatch app icon generator — proper Lambert + Phong sphere shading.
Pure Pillow, no numpy required.
"""
import math, os
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "icon_output")

def normalize(v):
    l = math.sqrt(sum(x*x for x in v))
    return tuple(x/l for x in v)

def dot(a, b):
    return sum(x*y for x, y in zip(a, b))

def lerp3(c0, c1, t):
    t = max(0.0, min(1.0, t))
    return tuple(c0[i] + (c1[i] - c0[i]) * t for i in range(3))

def stops_color(stops, t):
    t = max(0.0, min(1.0, t))
    for i in range(len(stops)-1):
        t0, c0 = stops[i]; t1, c1 = stops[i+1]
        if t <= t1:
            frac = (t - t0) / (t1 - t0) if t1 > t0 else 0.0
            return lerp3(c0, c1, frac)
    return stops[-1][1]

def circle_mask(size, cx, cy, r):
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse([cx-r, cy-r, cx+r, cy+r], fill=255)
    return mask

def generate_icon(size=256):
    """Render at given size; call with 1024 for final."""
    cx, cy = size * 0.50, size * 0.50
    br = size * 0.370  # bead radius

    # sandalwood colours
    BG_CTR   = (70,  42,  22)
    BG_EDGE  = (18,  10,   5)
    # bead surface colour ramp (low diffuse → high diffuse)
    BEAD_DARK = (55,  18,   5)
    BEAD_MID  = (160,  62,  16)
    BEAD_AMB  = (200, 100,  30)
    BEAD_LIT  = (240, 160,  55)
    BEAD_HI   = (255, 218, 110)

    # light setup
    L = normalize((-0.52, -0.64, 0.78))   # key light direction (towards viewer-upper-left)
    V = (0.0, 0.0, 1.0)                    # view direction (straight at screen)

    SHINE    = 38.0   # specular exponent (higher = tighter hotspot)
    SPEC_STR = 0.90   # specular intensity
    DIFF_STR = 0.82   # diffuse intensity
    AMB_STR  = 0.24   # ambient

    # ── render bead pixels (work at size/4 for speed, upscale) ────────────
    small = size // 4
    scx, scy, sbr = cx/4, cy/4, br/4
    bead_small = Image.new("RGBA", (small, small), (0,0,0,0))
    pix = bead_small.load()

    for y in range(small):
        for x in range(small):
            dx = x - scx; dy = y - scy
            r2 = dx*dx + dy*dy
            if r2 > sbr*sbr:
                continue
            # surface normal (sphere)
            nz = math.sqrt(max(0, sbr*sbr - r2)) / sbr
            N = normalize((dx/sbr, dy/sbr, nz))
            # Lambert diffuse
            diff = max(0.0, dot(N, L))
            # Phong specular
            R = tuple(2*dot(N,L)*N[i] - L[i] for i in range(3))
            spec = max(0.0, dot(R, V)) ** SHINE * SPEC_STR
            # surface colour by diffuse level (tone map through ramp)
            t = diff * 0.88 + AMB_STR * 0.5
            surf = stops_color([
                (0.00, BEAD_DARK),
                (0.22, BEAD_MID),
                (0.48, BEAD_AMB),
                (0.72, BEAD_LIT),
                (1.00, BEAD_HI),
            ], t)
            # combine diffuse + ambient
            col = tuple(
                surf[i] * (diff * DIFF_STR + AMB_STR)
                for i in range(3)
            )
            # add specular (white-warm)
            spec_col = (255, 240, 195)
            col = tuple(col[i] + spec_col[i] * spec for i in range(3))
            # limb darkening — darken edges slightly for roundness
            limb = nz ** 0.45
            col = tuple(c * (0.55 + 0.45 * limb) for c in col)
            col = tuple(int(max(0, min(255, c))) for c in col)
            pix[x, y] = (*col, 255)

    bead_img = bead_small.resize((size, size), Image.BILINEAR)

    # ── compose full image ─────────────────────────────────────────────────
    img = Image.new("RGBA", (size, size), (0,0,0,0))

    # background radial warmth
    for iy in range(size):
        for ix in range(size):
            d = math.sqrt((ix-cx)**2 + (iy-cy)**2) / (size*0.72)
            bg = lerp3(BG_CTR, BG_EDGE, min(d, 1.0))
            img.putpixel((ix, iy), (int(bg[0]), int(bg[1]), int(bg[2]), 255))

    # drop shadow
    shadow = Image.new("RGBA", (size, size), (0,0,0,0))
    sx, sy, sr = cx + br*0.07, cy + br*0.20, br*1.08
    ImageDraw.Draw(shadow).ellipse([sx-sr, sy-sr, sx+sr, sy+sr], fill=(6,2,0,165))
    shadow = shadow.filter(ImageFilter.GaussianBlur(int(size*0.04)))
    img = Image.alpha_composite(img, shadow)

    # bead
    bead_mask = circle_mask(size, cx, cy, br)
    bead_layer = Image.new("RGBA", (size, size), (0,0,0,0))
    bead_layer.paste(bead_img, (0,0), mask=bead_mask)
    img = Image.alpha_composite(img, bead_layer)

    # ambient golden glow
    glow = Image.new("RGBA", (size, size), (0,0,0,0))
    gr = br * 1.18
    ImageDraw.Draw(glow).ellipse([cx-gr, cy-gr, cx+gr, cy+gr], fill=(180, 95, 22, 45))
    glow = glow.filter(ImageFilter.GaussianBlur(int(size*0.055)))
    img = Image.alpha_composite(img, glow)

    final = Image.new("RGB", (size, size), BG_EDGE)
    final.paste(img.convert("RGB"))
    return final


def export_all():
    os.makedirs(OUT_DIR, exist_ok=True)

    print("Rendering 1024×1024 master icon (this takes ~30s)…")
    master = generate_icon(1024)
    master_path = os.path.join(OUT_DIR, "icon_1024.png")
    master.save(master_path, "PNG")
    print(f"  ✓ {master_path}")

    ios_sizes   = [1024, 180, 120, 87, 80, 60, 58, 40]
    watch_sizes = [108, 100, 87, 80, 58, 55, 48, 44]

    ios_dir   = os.path.join(OUT_DIR, "ios")
    watch_dir = os.path.join(OUT_DIR, "watchos")
    os.makedirs(ios_dir, exist_ok=True)
    os.makedirs(watch_dir, exist_ok=True)

    print("Exporting iOS sizes…")
    for px in ios_sizes:
        master.resize((px, px), Image.LANCZOS).save(
            os.path.join(ios_dir, f"icon_{px}.png"), "PNG")
        print(f"  ✓ {px}×{px}")

    print("Exporting watchOS sizes…")
    for px in watch_sizes:
        master.resize((px, px), Image.LANCZOS).save(
            os.path.join(watch_dir, f"icon_{px}.png"), "PNG")
        print(f"  ✓ {px}×{px}")

    print(f"\nAll icons saved to: {OUT_DIR}/")


if __name__ == "__main__":
    export_all()
