import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import arabic_reshaper
from bidi.algorithm import get_display

# Set paths
IOS_DIR = 'store_assets/01_iOS_Assets'
IOS_SHOTS = f'{IOS_DIR}/Screenshots_1290x2796'
DROID_DIR = 'store_assets/02_Android_Assets'
DROID_SHOTS = f'{DROID_DIR}/Screenshots_1080x1920'
META_DIR = 'store_assets/03_Store_Metadata'

os.makedirs(IOS_SHOTS, exist_ok=True)
os.makedirs(DROID_SHOTS, exist_ok=True)
os.makedirs(META_DIR, exist_ok=True)

# Fonts
FONT_BOLD = 'assets/fonts/Plex-Bold.ttf'
FONT_SEMI = 'assets/fonts/Plex-SemiBold.ttf'
FONT_MED = 'assets/fonts/Plex-Medium.ttf'
FONT_REG = 'assets/fonts/Plex-Regular.ttf'

def get_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except:
        return ImageFont.load_default()

def ar(text):
    if not text:
        return ""
    reshaped = arabic_reshaper.reshape(text)
    return get_display(reshaped)

def draw_text_centered(draw, text, y, font, fill, canvas_width):
    t = ar(text)
    bbox = draw.textbbox((0, 0), t, font=font)
    tw = bbox[2] - bbox[0]
    x = (canvas_width - tw) // 2
    draw.text((x, y), t, font=font, fill=fill)
    return x, y, tw, bbox[3] - bbox[1]

def draw_text_right(draw, text, x_right, y, font, fill):
    t = ar(text)
    bbox = draw.textbbox((0, 0), t, font=font)
    tw = bbox[2] - bbox[0]
    draw.text((x_right - tw, y), t, font=font, fill=fill)
    return x_right - tw, y, tw, bbox[3] - bbox[1]

def draw_text_left(draw, text, x_left, y, font, fill):
    t = ar(text)
    bbox = draw.textbbox((0, 0), t, font=font)
    draw.text((x_left, y), t, font=font, fill=fill)
    return x_left, y, bbox[2] - bbox[0], bbox[3] - bbox[1]

def draw_pill(draw, text, center_x, y, font, bg_fill, text_fill, border_fill=None, pad_x=26, pad_y=10, radius=22):
    t = ar(text)
    bbox = draw.textbbox((0, 0), t, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    w = tw + pad_x * 2
    h = th + pad_y * 2
    x0 = center_x - w // 2
    y0 = y
    x1 = x0 + w
    y1 = y0 + h
    draw.rounded_rectangle([(x0, y0), (x1, y1)], radius=radius, fill=bg_fill, outline=border_fill, width=2 if border_fill else 0)
    draw.text((x0 + pad_x, y0 + pad_y - 2), t, font=font, fill=text_fill)
    return w, h

def load_and_cover(path, target_w, target_h):
    if not os.path.exists(path):
        im = Image.new('RGB', (target_w, target_h), (230, 230, 235))
        return im
    try:
        im = Image.open(path).convert('RGB')
        src_w, src_h = im.size
        scale = max(target_w / src_w, target_h / src_h)
        new_w, new_h = int(src_w * scale), int(src_h * scale)
        im = im.resize((new_w, new_h), Image.LANCZOS)
        left = (new_w - target_w) // 2
        top = (new_h - target_h) // 2
        return im.crop((left, top, left + target_w, top + target_h))
    except:
        return Image.new('RGB', (target_w, target_h), (230, 230, 235))

def paste_rounded_image(dst_im, src_path, x, y, w, h, radius=24):
    img = load_and_cover(src_path, w, h)
    mask = Image.new('L', (w, h), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([(0, 0), (w, h)], radius=radius, fill=255)
    img_rgba = img.convert('RGBA')
    img_rgba.putalpha(mask)
    dst_im.paste(img_rgba, (x, y), img_rgba)

# -------------------------------------------------------------
# SCREEN RENDERING ENGINES (Native Master Resolution: 940 x 2040)
# -------------------------------------------------------------

def create_screen_1():
    # Screen 1: Home & Catalog
    w, h = 940, 2040
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 24)
    f_stat = get_font(FONT_BOLD, 20)
    draw.text((80, 50), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((810, 52), "5G  100%", font=f_stat, fill=(30, 30, 35))

    # App Bar (y=110 to 220)
    logo_path = 'store_assets/01_iOS_Assets/AppIcon_1024x1024.png'
    paste_rounded_image(screen, logo_path, 820, 115, 70, 70, radius=18)
    
    f_apptitle = get_font(FONT_BOLD, 34)
    draw_text_right(draw, "ذبائح المملكة", 805, 125, f_apptitle, (139, 29, 36))

    # Location & Notif on Left
    f_loc = get_font(FONT_MED, 22)
    draw.rounded_rectangle([(50, 120), (280, 180)], radius=30, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw_text_left(draw, "📍 الرياض - النرجس", 68, 134, f_loc, (74, 76, 86))
    
    # Notification bell
    draw.ellipse([(300, 120), (360, 180)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.text((320, 132), "🔔", font=f_loc, fill=(50, 50, 50))
    draw.ellipse([(342, 128), (354, 140)], fill=(229, 57, 53))

    # Search Bar (y=215 to 295)
    draw.rounded_rectangle([(50, 215), (890, 295)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    f_search = get_font(FONT_REG, 24)
    draw_text_right(draw, "🔍 ابحث عن ذبيحة، تفصيل، أو عروض خاصة...", 865, 238, f_search, (140, 145, 155))

    # Stories Strip (y=320 to 470)
    stories = [
        ("العروض", 'assets/images/home/sheep.jpg', True),
        ("نعيمي بلدي", 'assets/images/home/sheep.jpg', False),
        ("حري فاخر", 'assets/images/home/lamb.jpg', False),
        ("تيس عارضي", 'assets/images/home/meat.jpg', False),
        ("مسالخ معتمدة", 'c:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images/onboarding/butchery.jpg', False),
    ]
    f_story = get_font(FONT_MED, 20)
    sx = 810
    for name, img_path, is_promo in stories:
        ring_color = (229, 57, 53) if is_promo else (197, 154, 63)
        draw.ellipse([(sx - 4, 320 - 4), (sx + 88 + 4, 408 + 4)], outline=ring_color, width=3)
        paste_rounded_image(screen, img_path, sx, 320, 88, 88, radius=44)
        draw_text_centered(draw, name, 420, f_story, (40, 40, 45), sx + 44)
        sx -= 160

    # Hero Banner (y=475 to 740)
    draw.rounded_rectangle([(50, 475), (890, 740)], radius=32, fill=(139, 29, 36))
    paste_rounded_image(screen, 'c:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images/onboarding/livestock.jpg', 65, 490, 360, 235, radius=24)
    f_btitle = get_font(FONT_BOLD, 36)
    f_bsub = get_font(FONT_MED, 24)
    f_code = get_font(FONT_SEMI, 22)
    draw_text_right(draw, "خصم 15% بمناسبة التدشين", 860, 515, f_btitle, (255, 255, 255))
    draw_text_right(draw, "على جميع الذبائح البلديّة الطازجة", 860, 570, f_bsub, (223, 194, 120))
    draw.rounded_rectangle([(650, 620), (860, 675)], radius=16, fill=(80, 10, 15), outline=(197, 154, 63), width=1)
    draw_text_right(draw, "كود الخصم: MAMLAKA", 845, 632, f_code, (255, 255, 255))
    draw.rounded_rectangle([(650, 690), (860, 730)], radius=18, fill=(255, 255, 255))
    draw_text_centered(draw, "اطلب ذبيحتك الآن ←", 695, f_code, (139, 29, 36), 1510)

    # Section Title (y=765 to 815)
    f_sec = get_font(FONT_BOLD, 30)
    f_more = get_font(FONT_MED, 22)
    draw_text_right(draw, "تشكيلة الذبائح البلديّة الطازجة", 890, 765, f_sec, (26, 29, 38))
    draw_text_left(draw, "عرض الكل ←", 50, 772, f_more, (197, 154, 63))

    # Product Cards Grid (2x2) y=825 to 1840
    products = [
        {"name": "خروف نعيمي بلدي", "sub": "جذع طازج • وزن 12-14 كجم", "price": "1,450 ر.س", "badge": "الأكثر طلباً 🔥", "img": "assets/images/home/sheep.jpg", "rate": "★ 4.9"},
        {"name": "خروف حري فاخر", "sub": "تربية مزارعنا • وزن 13-15 كجم", "price": "1,350 ر.س", "badge": "طازج يومياً ✨", "img": "assets/images/home/lamb.jpg", "rate": "★ 4.8"},
        {"name": "تيس بلدي عارضي", "sub": "لحم لباني ناعم • وزن 8-10 كجم", "price": "950 ر.س", "badge": "جودة فاخرة 👑", "img": "assets/images/home/meat.jpg", "rate": "★ 4.9"},
        {"name": "لحم حاشي طازج", "sub": "بلدي لباني • طبق 5 كجم", "price": "390 ر.س", "badge": "ذبح اليوم 🥩", "img": "assets/images/home/camel.jpg", "rate": "★ 5.0"}
    ]

    card_w, card_h = 405, 490
    coords = [(485, 825), (50, 825), (485, 1335), (50, 1335)]
    f_pname = get_font(FONT_BOLD, 26)
    f_psub = get_font(FONT_REG, 20)
    f_pprice = get_font(FONT_BOLD, 28)
    f_pbadge = get_font(FONT_MED, 18)
    f_prate = get_font(FONT_BOLD, 20)

    for i, p in enumerate(products):
        cx, cy = coords[i]
        draw.rounded_rectangle([(cx, cy), (cx + card_w, cy + card_h)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
        paste_rounded_image(screen, p['img'], cx + 12, cy + 12, card_w - 24, 250, radius=18)
        draw.rounded_rectangle([(cx + card_w - 150, cy + 22), (cx + card_w - 22, cy + 62)], radius=12, fill=(139, 29, 36))
        draw_text_right(draw, p['badge'], cx + card_w - 30, cy + 28, f_pbadge, (255, 255, 255))
        draw.rounded_rectangle([(cx + 22, cy + 22), (cx + 105, cy + 62)], radius=12, fill=(255, 255, 255, 230))
        draw.text((cx + 32, cy + 28), p['rate'], font=f_prate, fill=(197, 154, 63))
        draw_text_right(draw, p['name'], cx + card_w - 20, cy + 280, f_pname, (26, 29, 38))
        draw_text_right(draw, p['sub'], cx + card_w - 20, cy + 320, f_psub, (122, 126, 137))
        draw_text_right(draw, p['price'], cx + card_w - 20, cy + 375, f_pprice, (229, 57, 53))
        draw.rounded_rectangle([(cx + 20, cy + 420), (cx + card_w - 20, cy + 475)], radius=16, fill=(139, 29, 36))
        draw_text_centered(draw, "اختر وتخصيص الذبيحة ←", cy + 432, f_pbadge, (255, 255, 255), cx * 2 + card_w)

    # Bottom Navigation Bar
    draw.rectangle([(0, 1870), (w, 2040)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    f_tab = get_font(FONT_SEMI, 22)
    tabs = [
        ("الرئيسية", "🏠", True),
        ("الأقسام", "🥩", False),
        ("السلة", "🛒", False),
        ("طلباتي", "📦", False),
        ("حسابي", "👤", False)
    ]
    tab_w = w // 5
    for i, (tname, ticon, is_act) in enumerate(tabs):
        tx = i * tab_w + tab_w // 2
        col = (229, 57, 53) if is_act else (122, 126, 137)
        draw_text_centered(draw, ticon, 1895, f_sec, col, tx * 2)
        draw_text_centered(draw, tname, 1945, f_tab, col, tx * 2)
        if is_act:
            draw.ellipse([(tx - 6, 1985), (tx + 6, 1997)], fill=(229, 57, 53))

    return screen

def create_screen_2():
    # Screen 2: Customization & Cuts
    w, h = 940, 2040
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 24)
    f_stat = get_font(FONT_BOLD, 20)
    draw.text((80, 50), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((810, 52), "5G  100%", font=f_stat, fill=(30, 30, 35))

    # App Bar
    f_apptitle = get_font(FONT_BOLD, 30)
    draw_text_centered(draw, "تخصيص الذبيحة والتقطيع", 130, f_apptitle, (26, 29, 38), w)
    draw.ellipse([(830, 120), (890, 180)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.text((850, 130), "←", font=f_apptitle, fill=(26, 29, 38))
    draw.ellipse([(50, 120), (110, 180)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.text((70, 130), "❤️", font=get_font(FONT_MED, 22), fill=(229, 57, 53))

    # Product Image
    paste_rounded_image(screen, 'assets/images/half_carcass.jpg', 50, 200, 840, 370, radius=28)
    draw.rounded_rectangle([(650, 220), (870, 270)], radius=16, fill=(139, 29, 36))
    f_tag = get_font(FONT_MED, 20)
    draw_text_right(draw, "ذبح إسلامي معتمد 100% ✓", 855, 232, f_tag, (255, 255, 255))
    draw.rounded_rectangle([(70, 220), (280, 270)], radius=16, fill=(197, 154, 63))
    draw_text_left(draw, "كشف بيطري معتمد 🩺", 85, 232, f_tag, (255, 255, 255))

    # Title & Price Card
    draw.rounded_rectangle([(50, 590), (890, 730)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    f_mtitle = get_font(FONT_BOLD, 32)
    f_price = get_font(FONT_BOLD, 34)
    f_sub = get_font(FONT_REG, 22)
    draw_text_right(draw, "خروف نعيمي بلدي طازج", 860, 610, f_mtitle, (26, 29, 38))
    draw_text_left(draw, "1,450 ر.س", 75, 610, f_price, (229, 57, 53))
    draw_text_right(draw, "شامل الذبح، التقطيع، التغليف الفاخر، والضريبة المضافة 15%", 860, 665, f_sub, (122, 126, 137))

    # Section 1: الحجم والوزن
    f_stitle = get_font(FONT_BOLD, 26)
    draw_text_right(draw, "1. اختر الحجم والوزن التقريبي", 890, 755, f_stitle, (26, 29, 38))
    sizes = [
        ("جذع صغير (12-14 كجم)", "1,450 ر.س", True),
        ("جذع وسط (15-17 كجم)", "1,650 ر.س", False),
        ("ثني كبير (18-20 كجم)", "1,850 ر.س", False),
    ]
    sw = 265
    f_sname = get_font(FONT_MED, 20)
    f_sp = get_font(FONT_BOLD, 22)
    for i, (sname, sprice, is_sel) in enumerate(sizes):
        sx = 890 - (i + 1) * sw - (i * 15)
        bg = (253, 240, 240) if is_sel else (255, 255, 255)
        border = (229, 57, 53) if is_sel else (226, 232, 240)
        draw.rounded_rectangle([(sx, 805), (sx + sw, 925)], radius=20, fill=bg, outline=border, width=2 if is_sel else 1)
        draw_text_centered(draw, sname, 825, f_sname, (26, 29, 38), sx * 2 + sw)
        draw_text_centered(draw, sprice, 868, f_sp, (229, 57, 53) if is_sel else (122, 126, 137), sx * 2 + sw)

    # Section 2: خيارات التقطيع
    draw_text_right(draw, "2. طريقة التقطيع والتفصيل", 890, 960, f_stitle, (26, 29, 38))
    cuts = [
        ("تقطيع ثلاجة (أكياس مفرقة)", True),
        ("مفطح كامل (ولائم ومناسبات)", False),
        ("أرباع متساوية (4 قِطع)", False),
        ("تفصيل حضرمي فاخر", False),
        ("قِطع شواء وستيك مخصوص", False),
    ]
    f_cut = get_font(FONT_MED, 22)
    cy = 1010
    cx = 890
    for name, is_sel in cuts:
        cb = draw.textbbox((0, 0), ar(name), font=f_cut)
        pw = (cb[2] - cb[0]) + 50
        if cx - pw < 50:
            cx = 890
            cy += 80
        draw.rounded_rectangle([(cx - pw, cy), (cx, cy + 65)], radius=18, fill=(253, 240, 240) if is_sel else (255, 255, 255), outline=(229, 57, 53) if is_sel else (226, 232, 240), width=2 if is_sel else 1)
        icon = "✓ " if is_sel else ""
        draw_text_right(draw, f"{icon}{name}", cx - 20, cy + 16, f_cut, (229, 57, 53) if is_sel else (74, 76, 86))
        cx -= (pw + 20)

    # Section 3: خيارات التجهيز والرأس
    draw_text_right(draw, "3. خيارات الرأس والتجهيز الخاص", 890, 1220, f_stitle, (26, 29, 38))
    addons = [
        ("شلوطة الرأس والكوارع وتنظيفها بالكامل", True),
        ("عزل الكبدة والكرش والقلب في أطباق مفرقة", True),
        ("فرم نصف كيلو كباب وشواء مخصوص", False),
    ]
    ay = 1275
    f_add = get_font(FONT_MED, 22)
    for aname, is_chk in addons:
        draw.rounded_rectangle([(50, ay), (890, ay + 65)], radius=18, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
        box_col = (229, 57, 53) if is_chk else (200, 200, 205)
        draw.rounded_rectangle([(830, ay + 14), (870, ay + 54)], radius=10, fill=box_col)
        if is_chk:
            draw.text((840, ay + 16), "✓", font=f_add, fill=(255, 255, 255))
        draw_text_right(draw, aname, 815, ay + 17, f_add, (26, 29, 38))
        ay += 80

    # Section 4: نوع التغليف
    draw_text_right(draw, "4. نوع التغليف المفضل لحفظ اللحم", 890, 1530, f_stitle, (26, 29, 38))
    packs = [
        ("تغليف حراري مفرغ من الهواء فكيوم (حفظ مضاعف) 🌟", True),
        ("أطباق فلين مبردة ومحكمة الإغلاق بشريط حماية", False)
    ]
    py = 1585
    for pname, is_sel in packs:
        bg = (253, 240, 240) if is_sel else (255, 255, 255)
        border = (229, 57, 53) if is_sel else (226, 232, 240)
        draw.rounded_rectangle([(50, py), (890, py + 75)], radius=20, fill=bg, outline=border, width=2 if is_sel else 1)
        draw.ellipse([(835, py + 22), (865, py + 52)], outline=border, width=2)
        if is_sel:
            draw.ellipse([(842, py + 29), (858, py + 45)], fill=(229, 57, 53))
        draw_text_right(draw, pname, 815, py + 22, f_add, (26, 29, 38))
        py += 95

    # Sticky Bottom Bar
    draw.rectangle([(0, 1840), (w, 2040)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.rounded_rectangle([(50, 1880), (220, 1960)], radius=20, fill=(242, 242, 245))
    f_cnt = get_font(FONT_BOLD, 28)
    draw.text((75, 1895), "-", font=f_cnt, fill=(122, 126, 137))
    draw.text((125, 1895), "1", font=f_cnt, fill=(26, 29, 38))
    draw.text((180, 1895), "+", font=f_cnt, fill=(229, 57, 53))

    draw.rounded_rectangle([(250, 1880), (890, 1960)], radius=22, fill=(139, 29, 36))
    f_btn = get_font(FONT_BOLD, 28)
    draw_text_centered(draw, "إضافة إلى السلة • 1,450 ر.س", 1900, f_btn, (255, 255, 255), 1140)

    return screen

def create_screen_3():
    # Screen 3: Cart & Apple Pay
    w, h = 940, 2040
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 24)
    f_stat = get_font(FONT_BOLD, 20)
    draw.text((80, 50), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((810, 52), "5G  100%", font=f_stat, fill=(30, 30, 35))

    # App Bar
    f_apptitle = get_font(FONT_BOLD, 30)
    draw_text_centered(draw, "سلة المشتريات (2 عناصر)", 130, f_apptitle, (26, 29, 38), w)

    # Free Delivery ProgressBar Banner
    draw.rounded_rectangle([(50, 210), (890, 300)], radius=22, fill=(236, 253, 245), outline=(167, 243, 208), width=1)
    f_free = get_font(FONT_BOLD, 22)
    draw_text_right(draw, "تهانينا! حصلت على توصيل مبرد مجاني لجميع طلباتك 🚚", 860, 225, f_free, (6, 95, 70))
    draw.rounded_rectangle([(80, 265), (860, 280)], radius=8, fill=(209, 250, 229))
    draw.rounded_rectangle([(80, 265), (860, 280)], radius=8, fill=(16, 185, 129))

    # Cart Items
    draw.rounded_rectangle([(50, 320), (890, 520)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    paste_rounded_image(screen, 'assets/images/home/sheep.jpg', 710, 340, 160, 145, radius=18)
    f_ititle = get_font(FONT_BOLD, 26)
    f_isub = get_font(FONT_REG, 20)
    f_iprice = get_font(FONT_BOLD, 28)
    draw_text_right(draw, "خروف نعيمي بلدي (جذع 13 كجم)", 690, 345, f_ititle, (26, 29, 38))
    draw_text_right(draw, "تقطيع: ثلاجة • تغليف: فكيوم • شلوطة كاملة", 690, 390, f_isub, (122, 126, 137))
    draw_text_right(draw, "1,450 ر.س", 690, 435, f_iprice, (229, 57, 53))
    draw.rounded_rectangle([(80, 420), (220, 480)], radius=16, fill=(242, 242, 245))
    draw.text((100, 432), "-", font=f_ititle, fill=(122, 126, 137))
    draw.text((145, 432), "1", font=f_ititle, fill=(26, 29, 38))
    draw.text((190, 432), "+", font=f_ititle, fill=(229, 57, 53))

    # Item 2
    draw.rounded_rectangle([(50, 540), (890, 720)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    paste_rounded_image(screen, 'assets/images/home/meat.jpg', 710, 555, 160, 135, radius=18)
    draw_text_right(draw, "طبق كبدة وكلاوي طازجة بلدية", 690, 565, f_ititle, (26, 29, 38))
    draw_text_right(draw, "طازج يومياً من مسلخ الأمانة", 690, 605, f_isub, (122, 126, 137))
    draw_text_right(draw, "65 ر.س", 690, 645, f_iprice, (229, 57, 53))
    draw.rounded_rectangle([(80, 630), (220, 690)], radius=16, fill=(242, 242, 245))
    draw.text((100, 642), "-", font=f_ititle, fill=(122, 126, 137))
    draw.text((145, 642), "1", font=f_ititle, fill=(26, 29, 38))
    draw.text((190, 642), "+", font=f_ititle, fill=(229, 57, 53))

    # Delivery Address Card
    draw.rounded_rectangle([(50, 745), (890, 940)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    f_cardh = get_font(FONT_BOLD, 24)
    draw_text_right(draw, "📍 تفاصيل التوصيل والاستلام", 860, 765, f_cardh, (26, 29, 38))
    draw_text_left(draw, "تغيير ←", 80, 765, f_free, (197, 154, 63))
    draw_text_right(draw, "المنزل: الرياض، حي الملقا - شارع أنس بن مالك", 860, 820, f_isub, (74, 76, 86))
    draw_text_right(draw, "🕒 موعد التوصيل: اليوم، الفترة المسائية (4:00 - 8:00 مساءً)", 860, 865, f_isub, (74, 76, 86))

    # Payment Methods
    draw_text_right(draw, "اختر طريقة الدفع الآمنة", 890, 965, f_ititle, (26, 29, 38))
    methods = [
        ("Apple Pay", "Pay دفع سريع وآمن بنقرة واحدة", True),
        ("مدى و البطاقات البنكية", "Mada, Visa, Mastercard مشفر بالكامل", False),
        ("تقسيط تابي / تمارا", "قسّط فاتورتك على 4 دفعات بدون فوائد", False)
    ]
    my = 1015
    for mtitle, msub, is_sel in methods:
        bg = (255, 255, 255) if not is_sel else (254, 242, 242)
        border = (229, 57, 53) if is_sel else (226, 232, 240)
        draw.rounded_rectangle([(50, my), (890, my + 72)], radius=20, fill=bg, outline=border, width=2 if is_sel else 1)
        draw.ellipse([(840, my + 21), (870, my + 51)], outline=border, width=2)
        if is_sel:
            draw.ellipse([(847, my + 28), (863, my + 44)], fill=(229, 57, 53))
        draw_text_right(draw, mtitle, 820, my + 14, f_ititle, (26, 29, 38))
        draw_text_right(draw, msub, 820, my + 42, get_font(FONT_REG, 18), (122, 126, 137))
        my += 86

    # Invoice Summary Card
    draw.rounded_rectangle([(50, 1295), (890, 1750)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw_text_right(draw, "ملخص الفاتورة والحساب", 860, 1320, f_ititle, (26, 29, 38))
    
    lines = [
        ("مجموع الذبائح والمنتجات", "1,515 ر.س"),
        ("التوصيل المبرد السريع", "مجاناً (0 ر.س)"),
        ("ضريبة القيمة المضافة 15%", "متضمنة بالكامل"),
        ("كوبون التدشين (MAMLAKA)", "-150 ر.س"),
    ]
    ly = 1380
    f_line = get_font(FONT_MED, 22)
    for lt, lv in lines:
        draw_text_right(draw, lt, 860, ly, f_line, (122, 126, 137))
        draw_text_left(draw, lv, 80, ly, f_line, (6, 95, 70) if "-" in lv or "مجان" in lv else (26, 29, 38))
        ly += 55
    
    draw.line([(80, 1620), (860, 1620)], fill=(226, 232, 240), width=1)
    f_tot_title = get_font(FONT_BOLD, 30)
    f_tot_price = get_font(FONT_BOLD, 34)
    draw_text_right(draw, "الإجمالي النهائي المستحق", 860, 1660, f_tot_title, (26, 29, 38))
    draw_text_left(draw, "1,365 ر.س", 80, 1655, f_tot_price, (229, 57, 53))

    # Sticky Bottom Button
    draw.rectangle([(0, 1840), (w, 2040)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.rounded_rectangle([(50, 1875), (890, 1965)], radius=24, fill=(0, 0, 0))
    f_ap = get_font(FONT_BOLD, 30)
    draw_text_centered(draw, "Pay إتمام الدفع بواسطة Apple Pay", 1898, f_ap, (255, 255, 255), w)

    return screen

def create_screen_4():
    # Screen 4: Live Order Tracking
    w, h = 940, 2040
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 24)
    f_stat = get_font(FONT_BOLD, 20)
    draw.text((80, 50), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((810, 52), "5G  100%", font=f_stat, fill=(30, 30, 35))

    # App Bar
    f_apptitle = get_font(FONT_BOLD, 30)
    draw_text_centered(draw, "متابعة الطلب #DM-98241", 130, f_apptitle, (26, 29, 38), w)

    # Live Delivery Van Graphic / Map Card
    paste_rounded_image(screen, 'c:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images/onboarding/delivery.jpg', 50, 200, 840, 450, radius=28)
    
    draw.rounded_rectangle([(70, 220), (870, 310)], radius=20, fill=(20, 20, 25, 220))
    f_over = get_font(FONT_BOLD, 26)
    f_temp = get_font(FONT_MED, 20)
    draw_text_right(draw, "❄️ درجة تبريد الشاحنة: 3.2°C مئوية (حفظ مثالي)", 850, 235, f_over, (255, 255, 255))
    draw_text_right(draw, "سيارة مبردة ومجهزة لنقل اللحوم الطازجة مباشرة لباب بيتك", 850, 275, f_temp, (223, 194, 120))

    draw.rounded_rectangle([(70, 560), (450, 625)], radius=18, fill=(229, 57, 53))
    draw_text_centered(draw, "الوصول خلال: 25 دقيقة ⏱️", 575, f_over, (255, 255, 255), 520)

    # Stepper Stages
    draw.rounded_rectangle([(50, 680), (890, 1270)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw_text_right(draw, "مراحل تجهيز وتوصيل الذبيحة", 860, 710, f_apptitle, (26, 29, 38))

    steps = [
        ("تم تأكيد الطلب واعتماده", "الساعة 9:15 ص • تم فحص المواصفات المطلوبة", True, False),
        ("الذبح بمسلخ الأمانة الرسمي", "الساعة 10:00 ص • إشراف بيطري كامل وختم رسمي", True, False),
        ("التقطيع والتغليف المفرغ من الهواء", "الساعة 10:45 ص • تقطيع ثلاجة وتغليف فكيوم محكم", True, False),
        ("في الطريق إليك بسيارة مبردة", "الساعة 11:15 ص • الكابتن فهد الشمري في حي الملقا", True, True),
    ]

    sy = 785
    f_stitle = get_font(FONT_BOLD, 24)
    f_ssub = get_font(FONT_REG, 19)
    for stitle, ssub, is_done, is_active in steps:
        col = (229, 57, 53) if is_active else ((16, 185, 129) if is_done else (200, 200, 205))
        draw.ellipse([(830, sy), (870, sy + 40)], fill=col)
        draw.text((842, sy + 6), "🚚" if is_active else "✓", font=get_font(FONT_BOLD, 18), fill=(255, 255, 255))
        
        draw_text_right(draw, stitle, 810, sy + 2, f_stitle, (229, 57, 53) if is_active else (26, 29, 38))
        draw_text_right(draw, ssub, 810, sy + 38, f_ssub, (122, 126, 137))
        
        if sy < 1100:
            draw.line([(850, sy + 45), (850, sy + 105)], fill=(16, 185, 129) if is_done else (226, 232, 240), width=3)
        sy += 115

    # Driver & Vehicle Card
    draw.rounded_rectangle([(50, 1295), (890, 1640)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.ellipse([(730, 1325), (860, 1455)], fill=(242, 242, 245), outline=(197, 154, 63), width=2)
    draw.text((765, 1355), "👨‍✈️", font=get_font(FONT_BOLD, 55))
    
    draw_text_right(draw, "الكابتن: فهد الشمري", 710, 1340, f_apptitle, (26, 29, 38))
    draw_text_right(draw, "سيارة تبريد مجهزة • لوحة: أ ب ج 4821", 710, 1390, f_ssub, (122, 126, 137))
    draw_text_right(draw, "★ 4.9 (340 تقييم معتمد)", 710, 1430, f_stitle, (197, 154, 63))

    draw.rounded_rectangle([(80, 1500), (460, 1590)], radius=20, fill=(37, 211, 102))
    draw_text_centered(draw, "💬 محادثة واتساب الكابتن", 1525, f_stitle, (255, 255, 255), 540)
    
    draw.rounded_rectangle([(480, 1500), (860, 1590)], radius=20, fill=(139, 29, 36))
    draw_text_centered(draw, "📞 اتصال هاتفي مباشر", 1525, f_stitle, (255, 255, 255), 1340)

    # Golden Guarantee Card
    draw.rounded_rectangle([(50, 1665), (890, 1830)], radius=24, fill=(254, 252, 232), outline=(254, 240, 138), width=1)
    draw_text_right(draw, "🛡️ الضمان الذهبي لذبائح المملكة", 860, 1690, f_stitle, (146, 64, 14))
    draw_text_right(draw, "نضمن لك استلام الذبيحة مبردة تماماً ومطابقة لطلبك 100% مع حق الاستبدال أو استرجاع كامل المبلغ.", 860, 1740, f_ssub, (180, 83, 9))

    # Bottom Help Bar
    draw.rectangle([(0, 1850), (w, 2040)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.rounded_rectangle([(50, 1880), (890, 1965)], radius=22, fill=(242, 242, 245))
    draw_text_centered(draw, "هل تحتاج مساعدة في طلبك؟ تواصل مع الدعم الفني 24/7", 1905, f_stitle, (74, 76, 86), w)

    return screen

def create_screen_5():
    # Screen 5: Special Banquets & Offers
    w, h = 940, 2040
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 24)
    f_stat = get_font(FONT_BOLD, 20)
    draw.text((80, 50), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((810, 52), "5G  100%", font=f_stat, fill=(30, 30, 35))

    # App Bar
    f_apptitle = get_font(FONT_BOLD, 30)
    draw_text_centered(draw, "العروض الحصرية وباقات الولائم", 130, f_apptitle, (26, 29, 38), w)

    # Big Banquet Hero Banner
    draw.rounded_rectangle([(50, 200), (890, 570)], radius=32, fill=(139, 29, 36))
    paste_rounded_image(screen, 'c:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images/onboarding/butchery.jpg', 70, 225, 340, 315, radius=24)
    f_btitle = get_font(FONT_BOLD, 34)
    f_bsub = get_font(FONT_MED, 22)
    f_bdesc = get_font(FONT_REG, 20)
    draw_text_right(draw, "باقة الولائم والمناسبات الكبرى 👑", 860, 235, f_btitle, (255, 255, 255))
    draw_text_right(draw, "خصم 20% عند طلب ذبيحتين فأكثر", 860, 290, f_bsub, (223, 194, 120))
    draw_text_right(draw, "تجهيز كامل للولائم، ذبح وتقطيع فاخر، صواني خاصة، وتوصيل مبرد معتمد مباشرة لموقع المناسبة.", 860, 340, f_bdesc, (240, 240, 245))
    draw.rounded_rectangle([(560, 470), (860, 530)], radius=20, fill=(255, 255, 255))
    draw_text_centered(draw, "احجز باقة المناسبات ←", 485, f_bsub, (139, 29, 36), 1420)

    # Offers Section Title
    f_sec = get_font(FONT_BOLD, 28)
    draw_text_right(draw, "أقوى عروض وباقات التوفير", 890, 595, f_sec, (26, 29, 38))

    offers = [
        {
            "title": "باقة العقيقة والصدقات المعتمدة",
            "desc": "ذبح وتوزيع موثق بالفيديو والصور لجمعيات البر الخيرية المعتمدة مع شهادة إلكترونية رسمية.",
            "price": "1,199 ر.س",
            "save": "وفر 250 ر.س",
            "img": "assets/images/home/sheep.jpg"
        },
        {
            "title": "باقة التوفير العائلية (نعيمي + تيس)",
            "desc": "ذبيحتين بلديتين طازجتين مجهزة بالكامل ومقطعة ثلاجة بأكياس فكيوم تكفي احتياج الشهر.",
            "price": "2,399 ر.س",
            "save": "وفر 350 ر.س",
            "img": "assets/images/home/lamb.jpg"
        },
        {
            "title": "عرض نهاية الأسبوع مع Apple Pay",
            "desc": "كاش باك 10% فوري يضاف مباشرة إلى محفظتك في التطبيق على جميع الطلبات.",
            "price": "كاش باك 10%",
            "save": "عرض حصري",
            "img": "assets/images/home/meat.jpg"
        }
    ]

    oy = 660
    f_otitle = get_font(FONT_BOLD, 26)
    f_odesc = get_font(FONT_REG, 19)
    f_oprice = get_font(FONT_BOLD, 28)
    f_osave = get_font(FONT_BOLD, 20)

    for o in offers:
        draw.rounded_rectangle([(50, oy), (890, oy + 230)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
        paste_rounded_image(screen, o['img'], 710, oy + 20, 160, 190, radius=18)
        
        draw_text_right(draw, o['title'], 690, oy + 22, f_otitle, (26, 29, 38))
        draw_text_right(draw, o['desc'], 690, oy + 68, f_odesc, (122, 126, 137))
        
        draw_text_right(draw, o['price'], 690, oy + 165, f_oprice, (229, 57, 53))
        draw.rounded_rectangle([(80, oy + 155), (240, oy + 205)], radius=14, fill=(254, 242, 242), outline=(229, 57, 53), width=1)
        draw_text_centered(draw, o['save'], oy + 168, f_osave, (229, 57, 53), 320)
        
        oy += 250

    # Loyalty Club Strip
    draw.rounded_rectangle([(50, 1440), (890, 1660)], radius=24, fill=(254, 243, 199), outline=(251, 191, 36), width=1)
    draw_text_right(draw, "نادي ذبائح المملكة للولاء والمكافآت 🌟", 860, 1465, f_sec, (120, 53, 15))
    draw_text_right(draw, "اجمع نقاط مع كل طلب ذبيحة واستبدلها بخصومات نقدية فورية عند الدفع.", 860, 1515, f_odesc, (146, 64, 14))
    draw_text_right(draw, "رصيد نقاطك الحالي: 350 نقطة (تساوي 35 ر.س خصم فوري)", 860, 1565, f_otitle, (180, 83, 9))
    draw.rounded_rectangle([(80, 1590), (320, 1640)], radius=14, fill=(180, 83, 9))
    draw_text_centered(draw, "استبدال النقاط الآن ←", 1605, f_osave, (255, 255, 255), 400)

    # Bottom Order CTA
    draw.rectangle([(0, 1850), (w, 2040)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.rounded_rectangle([(50, 1880), (890, 1965)], radius=24, fill=(139, 29, 36))
    f_btn = get_font(FONT_BOLD, 28)
    draw_text_centered(draw, "استفد من العروض واطلب ذبيحتك الآن ←", 1902, f_btn, (255, 255, 255), w)

    return screen

# -------------------------------------------------------------
# SCREENSHOT COMPOSITORS (iOS 1290x2796 & Android 1080x1920)
# -------------------------------------------------------------

def compose_ios_screenshot(screen_img, badge_text, title_text, subtitle_text, out_path, bg_color1=(125, 20, 24), bg_color2=(25, 5, 8)):
    W, H = 1290, 2796
    canvas = Image.new('RGB', (W, H), bg_color1)
    draw = ImageDraw.Draw(canvas)

    # Gradient Background
    for y in range(H):
        ratio = y / H
        r = int(bg_color1[0] - (bg_color1[0] - bg_color2[0]) * ratio)
        g = int(bg_color1[1] - (bg_color1[1] - bg_color2[1]) * ratio)
        b = int(bg_color1[2] - (bg_color1[2] - bg_color2[2]) * ratio)
        draw.line([(0, y), (W, y)], fill=(r, g, b))

    # Top Header Texts
    f_badge = get_font(FONT_SEMI, 28)
    draw_pill(draw, badge_text, W // 2, 130, f_badge, bg_fill=(60, 8, 12), text_fill=(223, 194, 120), border_fill=(197, 154, 63), pad_x=34, pad_y=14, radius=26)

    f_title = get_font(FONT_BOLD, 74)
    draw_text_centered(draw, title_text, 235, f_title, (255, 255, 255), W)

    f_sub = get_font(FONT_MED, 38)
    draw_text_centered(draw, subtitle_text, 360, f_sub, (238, 216, 174), W)

    # Device Mockup (iPhone Frame)
    # Target frame dimensions
    dev_w, dev_h = 1010, 2150
    dev_x = (W - dev_w) // 2
    dev_y = 520

    # Draw Outer Titanium Shadow
    shadow = Image.new('RGBA', (dev_w + 80, dev_h + 80), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rounded_rectangle([(40, 40), (dev_w + 40, dev_h + 40)], radius=75, fill=(0, 0, 0, 160))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=25))
    canvas.paste(shadow, (dev_x - 40, dev_y - 30), shadow)

    # Titanium Outer Frame
    draw.rounded_rectangle([(dev_x, dev_y), (dev_x + dev_w, dev_y + dev_h)], radius=74, fill=(42, 43, 48), outline=(85, 87, 96), width=3)

    # Inner Screen paste
    scr_w, scr_h = 940, 2040
    scr_x = dev_x + (dev_w - scr_w) // 2
    scr_y = dev_y + 35

    # Screen mask with rounded corners
    scr_mask = Image.new('L', (scr_w, scr_h), 0)
    smd = ImageDraw.Draw(scr_mask)
    smd.rounded_rectangle([(0, 0), (scr_w, scr_h)], radius=64, fill=255)

    screen_rgba = screen_img.convert('RGBA')
    screen_rgba.putalpha(scr_mask)
    canvas.paste(screen_rgba, (scr_x, scr_y), screen_rgba)

    # Dynamic Island Pill
    di_w, di_h = 240, 56
    di_x = dev_x + (dev_w - di_w) // 2
    di_y = scr_y + 24
    draw.rounded_rectangle([(di_x, di_y), (di_x + di_w, di_y + di_h)], radius=28, fill=(0, 0, 0))
    # Lens reflection dot
    draw.ellipse([(di_x + 190, di_y + 20), (di_x + 206, di_y + 36)], fill=(20, 25, 45))

    # Home Indicator Bar at bottom of screen
    hi_w, hi_h = 320, 10
    hi_x = dev_x + (dev_w - hi_w) // 2
    hi_y = scr_y + scr_h - 26
    draw.rounded_rectangle([(hi_x, hi_y), (hi_x + hi_w, hi_y + hi_h)], radius=5, fill=(40, 40, 45))

    canvas.save(out_path, 'PNG')
    print(f"Saved iOS Screenshot: {out_path} ({W}x{H})")

def compose_android_screenshot(screen_img, badge_text, title_text, subtitle_text, out_path, bg_color1=(125, 20, 24), bg_color2=(25, 5, 8)):
    W, H = 1080, 1920
    canvas = Image.new('RGB', (W, H), bg_color1)
    draw = ImageDraw.Draw(canvas)

    # Gradient Background
    for y in range(H):
        ratio = y / H
        r = int(bg_color1[0] - (bg_color1[0] - bg_color2[0]) * ratio)
        g = int(bg_color1[1] - (bg_color1[1] - bg_color2[1]) * ratio)
        b = int(bg_color1[2] - (bg_color1[2] - bg_color2[2]) * ratio)
        draw.line([(0, y)], fill=(r, g, b))
        draw.line([(0, y), (W, y)], fill=(r, g, b))

    # Header Texts
    f_badge = get_font(FONT_SEMI, 22)
    draw_pill(draw, badge_text, W // 2, 70, f_badge, bg_fill=(60, 8, 12), text_fill=(223, 194, 120), border_fill=(197, 154, 63), pad_x=26, pad_y=10, radius=20)

    f_title = get_font(FONT_BOLD, 54)
    draw_text_centered(draw, title_text, 145, f_title, (255, 255, 255), W)

    f_sub = get_font(FONT_MED, 28)
    draw_text_centered(draw, subtitle_text, 235, f_sub, (238, 216, 174), W)

    # Android Phone Mockup
    dev_w, dev_h = 840, 1560
    dev_x = (W - dev_w) // 2
    dev_y = 330

    # Shadow
    shadow = Image.new('RGBA', (dev_w + 60, dev_h + 60), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rounded_rectangle([(30, 30), (dev_w + 30, dev_h + 30)], radius=60, fill=(0, 0, 0, 150))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=18))
    canvas.paste(shadow, (dev_x - 30, dev_y - 20), shadow)

    # Outer Frame
    draw.rounded_rectangle([(dev_x, dev_y), (dev_x + dev_w, dev_y + dev_h)], radius=56, fill=(35, 36, 40), outline=(75, 76, 85), width=3)

    # Inner Screen
    scr_w, scr_h = 790, 1500
    scr_x = dev_x + (dev_w - scr_w) // 2
    scr_y = dev_y + 25

    scaled_scr = screen_img.resize((scr_w, scr_h), Image.LANCZOS)
    scr_mask = Image.new('L', (scr_w, scr_h), 0)
    smd = ImageDraw.Draw(scr_mask)
    smd.rounded_rectangle([(0, 0), (scr_w, scr_h)], radius=48, fill=255)

    scaled_rgba = scaled_scr.convert('RGBA')
    scaled_rgba.putalpha(scr_mask)
    canvas.paste(scaled_rgba, (scr_x, scr_y), scaled_rgba)

    # Android Camera Punchhole
    draw.ellipse([(W // 2 - 12, scr_y + 20), (W // 2 + 12, scr_y + 44)], fill=(0, 0, 0))

    # Home Navigation Bar Pill
    draw.rounded_rectangle([(W // 2 - 100, scr_y + scr_h - 18), (W // 2 + 100, scr_y + scr_h - 10)], radius=4, fill=(50, 50, 55))

    canvas.save(out_path, 'PNG')
    print(f"Saved Android Screenshot: {out_path} ({W}x{H})")

# -------------------------------------------------------------
# MAIN BUILD PIPELINE
# -------------------------------------------------------------

def build_all_assets():
    print("=" * 60)
    print("Starting Store Asset Generation for ذبائح المملكة...")
    print("=" * 60)

    # 1. App Icons
    src_icon_path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png'
    if os.path.exists(src_icon_path):
        im_src = Image.open(src_icon_path).convert('RGB')
        im_1024 = im_src.resize((1024, 1024), Image.LANCZOS)
        im_1024.save(f'{IOS_DIR}/AppIcon_1024x1024.png', 'PNG')
        print(f"Created iOS App Icon: {IOS_DIR}/AppIcon_1024x1024.png (1024x1024 RGB)")

        im_512 = im_1024.resize((512, 512), Image.LANCZOS)
        im_512.save(f'{DROID_DIR}/AppIcon_512x512.png', 'PNG')
        print(f"Created Android App Icon: {DROID_DIR}/AppIcon_512x512.png (512x512 RGB)")

    # 2. Render Masters for 5 Screens
    print("Rendering Master Screen UIs...")
    s1 = create_screen_1()
    s2 = create_screen_2()
    s3 = create_screen_3()
    s4 = create_screen_4()
    s5 = create_screen_5()

    screens_data = [
        (s1, "★ ذبائح بلدية طازجة ومضمونة 100% ★", "أجود الذبائح واللحوم البلديّة", "نعيمي، حري، نجدي، سواكني، وتيوس عارضية طازجة", "01_Home_Catalog"),
        (s2, "★ تفصيل وتقطيع وتغليف حسب رغبتك ★", "خيارات تقطيع وتغليف متكاملة", "ثلاجة، مفطح، أرباع، وتغليف سحب هواء فكيوم", "02_Customization_Cuts"),
        (s3, "★ شحن مبرد مجاني وخيارات دفع آمنة ★", "دفع سريع وآمن مع Apple Pay", "ادفع بـ Apple Pay، مدى، فيزا، أو قسّط مع تابي", "03_Cart_ApplePay"),
        (s4, "★ أسطول سيارات مبردة بدرجة 1-4° مئوية ★", "تتبع مبرد لحظي لباب بيتك", "متابعة حية من المسلخ المعتمد حتى الاستلام", "04_Chilled_Tracking"),
        (s5, "★ باقات المناسبات الكبرى والعقيقة والصدقات ★", "عروض حصرية وباقات الولائم", "أفضل الأسعار وباقات توفير عائلية مع نقاط مكافآت", "05_Special_Offers"),
    ]

    # Generate iOS and Android sets
    for scr_img, badge, title, subtitle, prefix in screens_data:
        ios_out = f"{IOS_SHOTS}/{prefix}_1290x2796.png"
        compose_ios_screenshot(scr_img, badge, title, subtitle, ios_out)

        droid_out = f"{DROID_SHOTS}/{prefix}_1080x1920.png"
        compose_android_screenshot(scr_img, badge, title, subtitle, droid_out)

    # 3. Generate iPad Assets
    try:
        from generate_ipad_store_assets import build_ipad_assets
        build_ipad_assets()
    except Exception as e:
        print(f"iPad generation skipped/error: {e}")

    print("All Screenshots and App Icons generated successfully!")

if __name__ == '__main__':
    build_all_assets()
