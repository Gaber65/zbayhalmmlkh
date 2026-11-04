import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import arabic_reshaper
from bidi.algorithm import get_display

# Set paths
IPAD_DIR = 'store_assets/01_iOS_Assets/Screenshots_iPad_2048x2732'
os.makedirs(IPAD_DIR, exist_ok=True)

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

def draw_pill(draw, text, center_x, y, font, bg_fill, text_fill, border_fill=None, pad_x=32, pad_y=14, radius=24):
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
        return Image.new('RGB', (target_w, target_h), (230, 230, 235))
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
# IPAD MASTER SCREEN RENDERERS (1580 x 2060)
# -------------------------------------------------------------

def create_ipad_screen_1():
    w, h = 1580, 2060
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 26)
    f_stat = get_font(FONT_BOLD, 22)
    draw.text((60, 35), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((1420, 37), "Wi-Fi   100%", font=f_stat, fill=(30, 30, 35))

    # iPad Top App Bar
    logo_path = 'store_assets/01_iOS_Assets/AppIcon_1024x1024.png'
    paste_rounded_image(screen, logo_path, 1440, 90, 80, 80, radius=20)

    f_apptitle = get_font(FONT_BOLD, 36)
    f_appsub = get_font(FONT_REG, 20)
    draw_text_right(draw, "ذبائح المملكة", 1420, 95, f_apptitle, (139, 29, 36))
    draw_text_right(draw, "اللحوم البلدية الطازجة المعتمدة", 1420, 140, f_appsub, (120, 125, 135))

    # Center Search Bar
    draw.rounded_rectangle([(460, 95), (1080, 165)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    f_search = get_font(FONT_REG, 22)
    draw_text_right(draw, "🔍 ابحث عن ذبيحة، طريقة تقطيع، أو عروض خاصة...", 1055, 115, f_search, (140, 145, 155))

    # Left controls: Location & Notifications
    f_loc = get_font(FONT_MED, 20)
    draw.rounded_rectangle([(140, 95), (420, 165)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw_text_left(draw, "📍 الرياض - حي الملقا", 160, 118, f_loc, (74, 76, 86))

    draw.ellipse([(60, 95), (120, 155)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.text((78, 110), "🔔", font=f_loc, fill=(50, 50, 50))
    draw.ellipse([(102, 105), (116, 119)], fill=(229, 57, 53))

    # Stories Bar
    stories = [
        ("العروض الحصرية", 'assets/images/home/sheep.jpg', True),
        ("نعيمي بلدي", 'assets/images/home/sheep.jpg', False),
        ("حري فاخر", 'assets/images/home/lamb.jpg', False),
        ("تيس عارضي", 'assets/images/home/meat.jpg', False),
        ("لحم حاشي", 'assets/images/home/camel.jpg', False),
        ("عجل بلدي", 'assets/images/home/cow.jpg', False),
        ("مسالخ الأمانة", 'c:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images/onboarding/butchery.jpg', False),
        ("أسطول التبريد", 'c:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images/onboarding/delivery.jpg', False),
    ]
    f_story = get_font(FONT_MED, 18)
    sx = 1430
    for name, img_path, is_promo in stories:
        ring_color = (229, 57, 53) if is_promo else (197, 154, 63)
        draw.ellipse([(sx - 4, 200 - 4), (sx + 80 + 4, 280 + 4)], outline=ring_color, width=3)
        paste_rounded_image(screen, img_path, sx, 200, 80, 80, radius=40)
        draw_text_centered(draw, name, 292, f_story, (40, 40, 45), sx + 40)
        sx -= 195

    # iPad Hero Banner
    draw.rounded_rectangle([(60, 340), (1520, 590)], radius=30, fill=(139, 29, 36))
    paste_rounded_image(screen, 'c:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images/onboarding/livestock.jpg', 80, 355, 460, 218, radius=22)

    f_btitle = get_font(FONT_BOLD, 40)
    f_bsub = get_font(FONT_MED, 26)
    f_code = get_font(FONT_SEMI, 22)
    draw_text_right(draw, "خصم 15% بمناسبة التدشين على جميع الذبائح البلديّة", 1480, 380, f_btitle, (255, 255, 255))
    draw_text_right(draw, "مذبوحة بمسالخ الأمانة الرسمية مع كشف بيطري معتمد وتوصيل مبرد لباب بيتك", 1480, 440, f_bsub, (223, 194, 120))
    draw.rounded_rectangle([(1160, 500), (1480, 560)], radius=18, fill=(80, 10, 15), outline=(197, 154, 63), width=1)
    draw_text_right(draw, "كود الخصم الفوري: MAMLAKA", 1460, 516, f_code, (255, 255, 255))
    draw.rounded_rectangle([(840, 500), (1130, 560)], radius=18, fill=(255, 255, 255))
    draw_text_centered(draw, "اطلب ذبيحتك الآن ←", 516, f_code, (139, 29, 36), 1970)

    # Section Title
    f_sec = get_font(FONT_BOLD, 32)
    f_more = get_font(FONT_MED, 22)
    draw_text_right(draw, "تشكيلة الذبائح البلديّة الطازجة (ذبح اليوم)", 1520, 620, f_sec, (26, 29, 38))
    draw_text_left(draw, "عرض جميع الأقسام (12 قسم) ←", 60, 628, f_more, (197, 154, 63))

    # iPad 3x2 Products Grid
    products = [
        {"name": "خروف نعيمي بلدي", "sub": "جذع طازج • وزن 12-14 كجم", "price": "1,450 ر.س", "badge": "الأكثر طلباً 🔥", "img": "assets/images/home/sheep.jpg", "rate": "★ 4.9"},
        {"name": "خروف حري فاخر", "sub": "تربية مزارعنا • وزن 13-15 كجم", "price": "1,350 ر.س", "badge": "طازج يومياً ✨", "img": "assets/images/home/lamb.jpg", "rate": "★ 4.8"},
        {"name": "تيس بلدي عارضي", "sub": "لحم لباني ناعم • وزن 8-10 كجم", "price": "950 ر.س", "badge": "جودة فاخرة 👑", "img": "assets/images/home/meat.jpg", "rate": "★ 4.9"},
        {"name": "خروف نجدي أصيل", "sub": "بلدي فاخر • وزن 14-16 كجم", "price": "1,550 ر.س", "badge": "عراقة بلديّة 🌟", "img": "assets/images/home/sheep.jpg", "rate": "★ 5.0"},
        {"name": "لحم حاشي طازج", "sub": "بلدي لباني • طبق 5 كجم", "price": "390 ر.س", "badge": "ذبح اليوم 🥩", "img": "assets/images/home/camel.jpg", "rate": "★ 4.9"},
        {"name": "عجل بلدي طازج", "sub": "لحم بتلو ممتاز • طبق 5 كجم", "price": "420 ر.س", "badge": "جودة ممتازة 🥩", "img": "assets/images/home/cow.jpg", "rate": "★ 4.8"}
    ]

    card_w = 466
    card_h = 560
    f_pname = get_font(FONT_BOLD, 26)
    f_psub = get_font(FONT_REG, 20)
    f_pprice = get_font(FONT_BOLD, 28)
    f_pbadge = get_font(FONT_MED, 18)
    f_prate = get_font(FONT_BOLD, 20)

    for i, p in enumerate(products):
        row = i // 3
        col = i % 3
        # RTL: col 0 is rightmost
        cx = 1520 - (col + 1) * card_w - (col * 30)
        cy = 680 + row * (card_h + 30)

        draw.rounded_rectangle([(cx, cy), (cx + card_w, cy + card_h)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
        paste_rounded_image(screen, p['img'], cx + 14, cy + 14, card_w - 28, 300, radius=18)

        draw.rounded_rectangle([(cx + card_w - 160, cy + 24), (cx + card_w - 24, cy + 68)], radius=12, fill=(139, 29, 36))
        draw_text_right(draw, p['badge'], cx + card_w - 32, cy + 32, f_pbadge, (255, 255, 255))

        draw.rounded_rectangle([(cx + 24, cy + 24), (cx + 110, cy + 68)], radius=12, fill=(255, 255, 255, 235))
        draw.text((cx + 34, cy + 32), p['rate'], font=f_prate, fill=(197, 154, 63))

        draw_text_right(draw, p['name'], cx + card_w - 20, cy + 330, f_pname, (26, 29, 38))
        draw_text_right(draw, p['sub'], cx + card_w - 20, cy + 375, f_psub, (122, 126, 137))
        draw_text_right(draw, p['price'], cx + card_w - 20, cy + 430, f_pprice, (229, 57, 53))

        draw.rounded_rectangle([(cx + 20, cy + 485), (cx + card_w - 20, cy + 545)], radius=16, fill=(139, 29, 36))
        draw_text_centered(draw, "اختر وتخصيص الذبيحة ←", cy + 500, f_pbadge, (255, 255, 255), cx * 2 + card_w)

    # iPad Bottom Bar
    draw.rectangle([(0, 1920), (w, 2060)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
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
        draw_text_centered(draw, ticon, 1940, f_sec, col, tx * 2)
        draw_text_centered(draw, tname, 1990, f_tab, col, tx * 2)
        if is_act:
            draw.ellipse([(tx - 6, 2030), (tx + 6, 2042)], fill=(229, 57, 53))

    return screen

def create_ipad_screen_2():
    # Screen 2: Customization & Cuts (iPad 2-Column Split View)
    w, h = 1580, 2060
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 26)
    f_stat = get_font(FONT_BOLD, 22)
    draw.text((60, 35), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((1420, 37), "Wi-Fi   100%", font=f_stat, fill=(30, 30, 35))

    # App Bar
    f_apptitle = get_font(FONT_BOLD, 36)
    draw_text_centered(draw, "تخصيص الذبيحة والتقطيع الفاخر", 90, f_apptitle, (26, 29, 38), w)
    draw.ellipse([(1460, 85), (1520, 145)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.text((1480, 95), "←", font=f_apptitle, fill=(26, 29, 38))
    draw.ellipse([(60, 85), (120, 145)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.text((80, 95), "❤️", font=get_font(FONT_MED, 24), fill=(229, 57, 53))

    # TWO COLUMNS LAYOUT
    # Right Column: Product Image & Details (x: 820 to 1520, width 700)
    rx0, rx1 = 820, 1520
    paste_rounded_image(screen, 'assets/images/half_carcass.jpg', rx0, 180, 700, 480, radius=28)
    draw.rounded_rectangle([(rx1 - 260, 200), (rx1 - 20, 255)], radius=16, fill=(139, 29, 36))
    f_tag = get_font(FONT_MED, 20)
    draw_text_right(draw, "ذبح إسلامي معتمد 100% ✓", rx1 - 35, 214, f_tag, (255, 255, 255))
    draw.rounded_rectangle([(rx0 + 20, 200), (rx0 + 240, 255)], radius=16, fill=(197, 154, 63))
    draw_text_left(draw, "كشف بيطري معتمد 🩺", rx0 + 35, 214, f_tag, (255, 255, 255))

    # Right Column: Price & Guarantee Card
    draw.rounded_rectangle([(rx0, 680), (rx1, 860)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    f_mtitle = get_font(FONT_BOLD, 36)
    f_price = get_font(FONT_BOLD, 38)
    f_sub = get_font(FONT_REG, 22)
    draw_text_right(draw, "خروف نعيمي بلدي طازج", rx1 - 30, 705, f_mtitle, (26, 29, 38))
    draw_text_left(draw, "1,450 ر.س", rx0 + 30, 705, f_price, (229, 57, 53))
    draw_text_right(draw, "شامل الذبح بمسلخ الأمانة، التقطيع، التغليف الفاخر، والضريبة 15%", rx1 - 30, 765, f_sub, (122, 126, 137))
    draw_text_right(draw, "🚚 توصيل مبرد مجاني خلال 2-4 ساعات في جميع أحياء الرياض", rx1 - 30, 810, get_font(FONT_SEMI, 20), (6, 95, 70))

    # Right Column: Section 1 (الحجم والوزن)
    f_stitle = get_font(FONT_BOLD, 26)
    draw_text_right(draw, "1. اختر الحجم والوزن التقريبي", rx1, 890, f_stitle, (26, 29, 38))
    sizes = [
        ("جذع صغير (12-14 كجم)", "1,450 ر.س", True),
        ("جذع وسط (15-17 كجم)", "1,650 ر.س", False),
        ("ثني كبير (18-20 كجم)", "1,850 ر.س", False),
    ]
    sy = 940
    f_sname = get_font(FONT_MED, 22)
    f_sp = get_font(FONT_BOLD, 24)
    for sname, sprice, is_sel in sizes:
        bg = (253, 240, 240) if is_sel else (255, 255, 255)
        border = (229, 57, 53) if is_sel else (226, 232, 240)
        draw.rounded_rectangle([(rx0, sy), (rx1, sy + 76)], radius=20, fill=bg, outline=border, width=2 if is_sel else 1)
        draw.ellipse([(rx1 - 50, sy + 23), (rx1 - 20, sy + 53)], outline=border, width=2)
        if is_sel:
            draw.ellipse([(rx1 - 43, sy + 30), (rx1 - 27, sy + 46)], fill=(229, 57, 53))
        draw_text_right(draw, sname, rx1 - 70, sy + 22, f_sname, (26, 29, 38))
        draw_text_left(draw, sprice, rx0 + 30, sy + 22, f_sp, (229, 57, 53) if is_sel else (122, 126, 137))
        sy += 92

    # Right Column: Section 4 (التغليف)
    draw_text_right(draw, "4. نوع التغليف وحفظ اللحم", rx1, 1240, f_stitle, (26, 29, 38))
    packs = [
        ("تغليف حراري مفرغ من الهواء فكيوم (حفظ مضاعف) 🌟", True),
        ("أطباق فلين مبردة ومحكمة الإغلاق بشريط حماية", False)
    ]
    py = 1290
    for pname, is_sel in packs:
        bg = (253, 240, 240) if is_sel else (255, 255, 255)
        border = (229, 57, 53) if is_sel else (226, 232, 240)
        draw.rounded_rectangle([(rx0, py), (rx1, py + 76)], radius=20, fill=bg, outline=border, width=2 if is_sel else 1)
        draw.ellipse([(rx1 - 50, py + 23), (rx1 - 20, py + 53)], outline=border, width=2)
        if is_sel:
            draw.ellipse([(rx1 - 43, py + 30), (rx1 - 27, py + 46)], fill=(229, 57, 53))
        draw_text_right(draw, pname, rx1 - 70, py + 22, f_sname, (26, 29, 38))
        py += 92

    # Left Column: Customization & Cuts & Addons (x: 60 to 760, width 700)
    lx0, lx1 = 60, 760

    # Left Column: Section 2 (طريقة التقطيع)
    draw_text_right(draw, "2. طريقة التقطيع والتفصيل", lx1, 180, f_stitle, (26, 29, 38))
    cuts = [
        ("تقطيع ثلاجة (أكياس مفرقة جاهزة للطبخ)", True),
        ("مفطح كامل (مناسب للولائم والمناسبات)", False),
        ("أرباع متساوية (4 قِطع كبيرة)", False),
        ("تفصيل حضرمي فاخر للمندي والمظبي", False),
        ("قِطع شواء وستيك وريش مخصوصة", False),
    ]
    cy = 230
    for cname, is_sel in cuts:
        bg = (253, 240, 240) if is_sel else (255, 255, 255)
        border = (229, 57, 53) if is_sel else (226, 232, 240)
        draw.rounded_rectangle([(lx0, cy), (lx1, cy + 76)], radius=20, fill=bg, outline=border, width=2 if is_sel else 1)
        draw.ellipse([(lx1 - 50, cy + 23), (lx1 - 20, cy + 53)], outline=border, width=2)
        if is_sel:
            draw.ellipse([(lx1 - 43, cy + 30), (lx1 - 27, cy + 46)], fill=(229, 57, 53))
        draw_text_right(draw, ("✓ " if is_sel else "") + cname, lx1 - 70, cy + 22, f_sname, (229, 57, 53) if is_sel else (26, 29, 38))
        cy += 92

    # Left Column: Section 3 (خيارات الرأس والتجهيز)
    draw_text_right(draw, "3. خيارات الرأس والتجهيز الخاص", lx1, 720, f_stitle, (26, 29, 38))
    addons = [
        ("شلوطة الرأس والكوارع وتنظيفها بالكامل", True),
        ("عزل الكبدة والكرش والقلب في أطباق مفرقة", True),
        ("فرم نصف كيلو كباب وشواء مخصوص", False),
        ("تقطيع الكبدة شرائح جاهزة للشوي", False),
    ]
    ay = 770
    for aname, is_chk in addons:
        draw.rounded_rectangle([(lx0, ay), (lx1, ay + 76)], radius=20, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
        box_col = (229, 57, 53) if is_chk else (200, 200, 205)
        draw.rounded_rectangle([(lx1 - 55, ay + 20), (lx1 - 20, ay + 55)], radius=10, fill=box_col)
        if is_chk:
            draw.text((lx1 - 48, ay + 22), "✓", font=f_sname, fill=(255, 255, 255))
        draw_text_right(draw, aname, lx1 - 75, ay + 22, f_sname, (26, 29, 38))
        ay += 92

    # Left Column: Delivery & Quality Guarantee Card
    draw.rounded_rectangle([(lx0, 1180), (lx1, 1470)], radius=24, fill=(254, 252, 232), outline=(254, 240, 138), width=1)
    draw_text_right(draw, "🛡️ الضمان الذهبي للذبح والتجهيز", lx1 - 30, 1210, f_stitle, (146, 64, 14))
    draw_text_right(draw, "• إشراف أطباء بيطريين معتمدين قبل وبعد الذبح مباشرة.", lx1 - 30, 1260, f_sub, (180, 83, 9))
    draw_text_right(draw, "• سيارات تبريد مجهزة بدرجة 1-4 مئوية تحفظ جودة اللحم.", lx1 - 30, 1310, f_sub, (180, 83, 9))
    draw_text_right(draw, "• حق الاستبدال أو استرجاع كامل المبلغ إذا لم تطابق طلبك.", lx1 - 30, 1360, f_sub, (180, 83, 9))
    draw_text_right(draw, "• شهادة ذبح إلكترونية معتمدة من مسلخ الأمانة.", lx1 - 30, 1410, f_sub, (180, 83, 9))

    # Sticky Bottom Bar
    draw.rectangle([(0, 1860), (w, 2060)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.rounded_rectangle([(60, 1900), (300, 1990)], radius=22, fill=(242, 242, 245))
    f_cnt = get_font(FONT_BOLD, 32)
    draw.text((100, 1920), "-", font=f_cnt, fill=(122, 126, 137))
    draw.text((170, 1920), "1", font=f_cnt, fill=(26, 29, 38))
    draw.text((245, 1920), "+", font=f_cnt, fill=(229, 57, 53))

    draw.rounded_rectangle([(340, 1900), (1520, 1990)], radius=24, fill=(139, 29, 36))
    f_btn = get_font(FONT_BOLD, 32)
    draw_text_centered(draw, "إضافة إلى السلة • 1,450 ر.س (توصيل مبرد مجاني)", 1925, f_btn, (255, 255, 255), 1860)

    return screen

def create_ipad_screen_3():
    # Screen 3: Cart & Apple Pay (iPad 2-Column Split View)
    w, h = 1580, 2060
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 26)
    f_stat = get_font(FONT_BOLD, 22)
    draw.text((60, 35), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((1420, 37), "Wi-Fi   100%", font=f_stat, fill=(30, 30, 35))

    # App Bar
    f_apptitle = get_font(FONT_BOLD, 36)
    draw_text_centered(draw, "سلة المشتريات والدفع الإلكتروني (3 عناصر)", 90, f_apptitle, (26, 29, 38), w)

    # Progress Banner (Free Delivery)
    draw.rounded_rectangle([(60, 170), (1520, 250)], radius=22, fill=(236, 253, 245), outline=(167, 243, 208), width=1)
    f_free = get_font(FONT_BOLD, 24)
    draw_text_right(draw, "تهانينا! حصلت على توصيل مبرد مجاني لجميع طلباتك في الرياض 🚚", 1480, 190, f_free, (6, 95, 70))
    draw.rounded_rectangle([(100, 225), (1480, 238)], radius=6, fill=(16, 185, 129))

    # 2-Column Layout
    # Right Column: Cart Items & Address (x: 780 to 1520, width 740)
    rx0, rx1 = 780, 1520

    # Cart Item 1
    draw.rounded_rectangle([(rx0, 280), (rx1, 490)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    paste_rounded_image(screen, 'assets/images/home/sheep.jpg', rx1 - 180, 300, 160, 160, radius=20)
    f_ititle = get_font(FONT_BOLD, 26)
    f_isub = get_font(FONT_REG, 20)
    f_iprice = get_font(FONT_BOLD, 30)
    draw_text_right(draw, "خروف نعيمي بلدي (جذع 13 كجم)", rx1 - 200, 310, f_ititle, (26, 29, 38))
    draw_text_right(draw, "تقطيع ثلاجة • تغليف حراري فكيوم • شلوطة كاملة", rx1 - 200, 355, f_isub, (122, 126, 137))
    draw_text_right(draw, "1,450 ر.س", rx1 - 200, 415, f_iprice, (229, 57, 53))
    draw.rounded_rectangle([(rx0 + 25, 400), (rx0 + 175, 465)], radius=16, fill=(242, 242, 245))
    draw.text((rx0 + 45, 415), "-", font=f_ititle, fill=(122, 126, 137))
    draw.text((rx0 + 95, 415), "1", font=f_ititle, fill=(26, 29, 38))
    draw.text((rx0 + 145, 415), "+", font=f_ititle, fill=(229, 57, 53))

    # Cart Item 2
    draw.rounded_rectangle([(rx0, 520), (rx1, 720)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    paste_rounded_image(screen, 'assets/images/home/meat.jpg', rx1 - 180, 540, 160, 150, radius=20)
    draw_text_right(draw, "طبق كبدة وكلاوي طازجة بلدية", rx1 - 200, 545, f_ititle, (26, 29, 38))
    draw_text_right(draw, "طازج يومياً من مسلخ الأمانة الرسمي", rx1 - 200, 590, f_isub, (122, 126, 137))
    draw_text_right(draw, "65 ر.س", rx1 - 200, 645, f_iprice, (229, 57, 53))
    draw.rounded_rectangle([(rx0 + 25, 630), (rx0 + 175, 695)], radius=16, fill=(242, 242, 245))
    draw.text((rx0 + 45, 645), "-", font=f_ititle, fill=(122, 126, 137))
    draw.text((rx0 + 95, 645), "1", font=f_ititle, fill=(26, 29, 38))
    draw.text((rx0 + 145, 645), "+", font=f_ititle, fill=(229, 57, 53))

    # Cart Item 3 (Bonus Gift)
    draw.rounded_rectangle([(rx0, 750), (rx1, 930)], radius=24, fill=(254, 242, 242), outline=(254, 202, 202), width=1)
    paste_rounded_image(screen, 'assets/images/home/lamb.jpg', rx1 - 160, 770, 140, 135, radius=18)
    draw_text_right(draw, "بهارات لحم مشكلة فاخرة (هدية مجانية) 🎁", rx1 - 180, 780, f_ititle, (139, 29, 36))
    draw_text_right(draw, "خلطة خاصة بالذبائح السعودية الفاخرة", rx1 - 180, 825, f_isub, (122, 126, 137))
    draw_text_right(draw, "مجاناً (0 ر.س)", rx1 - 180, 875, f_iprice, (6, 95, 70))

    # Delivery Address Card
    draw.rounded_rectangle([(rx0, 960), (rx1, 1180)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    f_cardh = get_font(FONT_BOLD, 24)
    draw_text_right(draw, "📍 تفاصيل التوصيل والاستلام", rx1 - 30, 985, f_cardh, (26, 29, 38))
    draw_text_left(draw, "تغيير العنوان ←", rx0 + 30, 985, f_free, (197, 154, 63))
    draw_text_right(draw, "المنزل: الرياض، حي الملقا - شارع أنس بن مالك", rx1 - 30, 1045, f_isub, (74, 76, 86))
    draw_text_right(draw, "🕒 موعد التوصيل: اليوم، الفترة المسائية (4:00 - 8:00 مساءً)", rx1 - 30, 1095, f_isub, (74, 76, 86))

    # Left Column: Payment & Invoice Summary (x: 60 to 740, width 680)
    lx0, lx1 = 60, 740

    # Payment Methods
    draw_text_right(draw, "اختر طريقة الدفع الآمنة", lx1, 280, f_ititle, (26, 29, 38))
    methods = [
        ("Apple Pay", "Pay دفع سريع وآمن بنقرة واحدة", True),
        ("مدى و البطاقات البنكية", "Mada, Visa, Mastercard مشفر بالكامل", False),
        ("تقسيط تابي / تمارا", "قسّط فاتورتك على 4 دفعات بدون فوائد", False)
    ]
    my = 330
    for mtitle, msub, is_sel in methods:
        bg = (254, 242, 242) if is_sel else (255, 255, 255)
        border = (229, 57, 53) if is_sel else (226, 232, 240)
        draw.rounded_rectangle([(lx0, my), (lx1, my + 85)], radius=20, fill=bg, outline=border, width=2 if is_sel else 1)
        draw.ellipse([(lx1 - 50, my + 27), (lx1 - 20, my + 57)], outline=border, width=2)
        if is_sel:
            draw.ellipse([(lx1 - 43, my + 34), (lx1 - 27, my + 50)], fill=(229, 57, 53))
        draw_text_right(draw, mtitle, lx1 - 70, my + 18, f_ititle, (26, 29, 38))
        draw_text_right(draw, msub, lx1 - 70, my + 50, get_font(FONT_REG, 18), (122, 126, 137))
        my += 105

    # Invoice Summary Card
    draw.rounded_rectangle([(lx0, 680), (lx1, 1180)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw_text_right(draw, "ملخص الفاتورة والحساب", lx1 - 30, 710, f_ititle, (26, 29, 38))

    lines = [
        ("مجموع الذبائح والمنتجات", "1,515 ر.س"),
        ("التوصيل المبرد السريع", "مجاناً (0 ر.س)"),
        ("ضريبة القيمة المضافة 15%", "متضمنة بالكامل"),
        ("كوبون التدشين (MAMLAKA)", "-150 ر.س"),
    ]
    ly = 780
    f_line = get_font(FONT_MED, 24)
    for lt, lv in lines:
        draw_text_right(draw, lt, lx1 - 30, ly, f_line, (122, 126, 137))
        draw_text_left(draw, lv, lx0 + 30, ly, f_line, (6, 95, 70) if "-" in lv or "مجان" in lv else (26, 29, 38))
        ly += 65

    draw.line([(lx0 + 30, 1050), (lx1 - 30, 1050)], fill=(226, 232, 240), width=2)
    f_tot_title = get_font(FONT_BOLD, 30)
    f_tot_price = get_font(FONT_BOLD, 36)
    draw_text_right(draw, "الإجمالي النهائي المستحق", lx1 - 30, 1090, f_tot_title, (26, 29, 38))
    draw_text_left(draw, "1,365 ر.س", lx0 + 30, 1085, f_tot_price, (229, 57, 53))

    # Big Apple Pay CTA Button
    draw.rounded_rectangle([(lx0, 1220), (1520, 1330)], radius=24, fill=(0, 0, 0))
    f_ap = get_font(FONT_BOLD, 36)
    draw_text_centered(draw, "Pay إتمام الدفع الفوري بواسطة Apple Pay • 1,365 ر.س", 1255, f_ap, (255, 255, 255), w)

    # Security Footnote
    f_sec_note = get_font(FONT_REG, 20)
    draw_text_centered(draw, "🔒 جميع المعاملات المالية مشفرة وآمنة 100% متوافقة مع معايير البنك المركزي السعودي (ساما)", 1360, f_sec_note, (122, 126, 137), w)

    return screen

def create_ipad_screen_4():
    # Screen 4: Live Order Tracking (iPad 2-Column Split View)
    w, h = 1580, 2060
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 26)
    f_stat = get_font(FONT_BOLD, 22)
    draw.text((60, 35), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((1420, 37), "Wi-Fi   100%", font=f_stat, fill=(30, 30, 35))

    # App Bar
    f_apptitle = get_font(FONT_BOLD, 36)
    draw_text_centered(draw, "متابعة الطلب والتوصيل المبرد #DM-98241", 90, f_apptitle, (26, 29, 38), w)

    # 2-Column Split Layout
    # Right Column: Visual Van + Driver Details (x: 800 to 1520, width 720)
    rx0, rx1 = 800, 1520

    # Live Delivery Van Graphic
    paste_rounded_image(screen, 'c:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images/onboarding/delivery.jpg', rx0, 180, 720, 480, radius=28)

    draw.rounded_rectangle([(rx0 + 20, 200), (rx1 - 20, 310)], radius=20, fill=(20, 20, 25, 230))
    f_over = get_font(FONT_BOLD, 26)
    f_temp = get_font(FONT_MED, 20)
    draw_text_right(draw, "❄️ درجة تبريد الشاحنة: 3.2°C مئوية (حفظ مثالي)", rx1 - 40, 218, f_over, (255, 255, 255))
    draw_text_right(draw, "سيارة مبردة ومجهزة لنقل اللحوم الطازجة مباشرة لباب بيتك", rx1 - 40, 265, f_temp, (223, 194, 120))

    draw.rounded_rectangle([(rx0 + 20, 570), (rx0 + 380, 640)], radius=18, fill=(229, 57, 53))
    draw_text_centered(draw, "الوصول خلال: 25 دقيقة ⏱️", 588, f_over, (255, 255, 255), rx0 * 2 + 400)

    # Driver & Vehicle Card
    draw.rounded_rectangle([(rx0, 690), (rx1, 1070)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.ellipse([(rx1 - 150, 720), (rx1 - 30, 840)], fill=(242, 242, 245), outline=(197, 154, 63), width=2)
    draw.text((rx1 - 120, 745), "👨‍✈️", font=get_font(FONT_BOLD, 55))

    f_dname = get_font(FONT_BOLD, 30)
    f_ssub = get_font(FONT_REG, 20)
    f_stitle = get_font(FONT_BOLD, 22)
    draw_text_right(draw, "الكابتن: فهد الشمري", rx1 - 170, 730, f_dname, (26, 29, 38))
    draw_text_right(draw, "سيارة تبريد مجهزة • لوحة: أ ب ج 4821", rx1 - 170, 780, f_ssub, (122, 126, 137))
    draw_text_right(draw, "★ 4.9 (340 تقييم معتمد من العملاء)", rx1 - 170, 825, f_stitle, (197, 154, 63))

    draw.rounded_rectangle([(rx0 + 30, 930), (rx0 + 340, 1030)], radius=20, fill=(37, 211, 102))
    draw_text_centered(draw, "💬 محادثة واتساب", 960, f_stitle, (255, 255, 255), rx0 * 2 + 370)

    draw.rounded_rectangle([(rx0 + 370), (rx1 - 30), (rx1 - 30), 1030], radius=20, fill=(139, 29, 36))
    draw.rounded_rectangle([(rx0 + 370, 930), (rx1 - 30, 1030)], radius=20, fill=(139, 29, 36))
    draw_text_centered(draw, "📞 اتصال هاتفي", 960, f_stitle, (255, 255, 255), (rx0 + 370 + rx1 - 30))

    # Golden Guarantee Card
    draw.rounded_rectangle([(rx0, 1110), (rx1, 1360)], radius=24, fill=(254, 252, 232), outline=(254, 240, 138), width=1)
    draw_text_right(draw, "🛡️ الضمان الذهبي لذبائح المملكة", rx1 - 30, 1140, f_stitle, (146, 64, 14))
    draw_text_right(draw, "نضمن لك استلام الذبيحة مبردة تماماً ومطابقة لطلبك 100% مع حق الاستبدال الفوري أو استرجاع كامل المبلغ دون أي تأخير.", rx1 - 30, 1195, f_ssub, (180, 83, 9))
    draw_text_right(draw, "شهادة الفحص البيطري رقم: #SA-782142 مرافقة للطلب.", rx1 - 30, 1285, get_font(FONT_SEMI, 20), (146, 64, 14))

    # Left Column: Stepper Timeline (x: 60 to 760, width 700)
    lx0, lx1 = 60, 760
    draw.rounded_rectangle([(lx0, 180), (lx1, 1360)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw_text_right(draw, "مراحل تجهيز وتوصيل الذبيحة", lx1 - 30, 215, f_apptitle, (26, 29, 38))

    steps = [
        ("تم تأكيد الطلب واعتماده", "الساعة 9:15 ص • تم فحص المواصفات المطلوبة", True, False),
        ("الذبح بمسلخ الأمانة الرسمي", "الساعة 10:00 ص • إشراف بيطري كامل وختم رسمي", True, False),
        ("التقطيع والتغليف المفرغ من الهواء", "الساعة 10:45 ص • تقطيع ثلاجة وتغليف فكيوم محكم", True, False),
        ("في الطريق إليك بسيارة مبردة", "الساعة 11:15 ص • الكابتن فهد الشمري في حي الملقا", True, True),
        ("الاستلام والتسليم لباب منزلك", "الموعد المتوقع: الساعة 11:40 ص", False, False),
    ]

    sy = 300
    f_step_t = get_font(FONT_BOLD, 26)
    f_step_s = get_font(FONT_REG, 20)
    for stitle, ssub, is_done, is_active in steps:
        col = (229, 57, 53) if is_active else ((16, 185, 129) if is_done else (200, 200, 205))
        draw.ellipse([(lx1 - 70, sy), (lx1 - 20, sy + 50)], fill=col)
        draw.text([(lx1 - 58), (sy + 10)], "🚚" if is_active else ("✓" if is_done else "○"), font=get_font(FONT_BOLD, 22), fill=(255, 255, 255))

        draw_text_right(draw, stitle, lx1 - 90, sy + 3, f_step_t, (229, 57, 53) if is_active else (26, 29, 38))
        draw_text_right(draw, ssub, lx1 - 90, sy + 48, f_step_s, (122, 126, 137))

        if sy < 1000:
            draw.line([(lx1 - 45, sy + 55), (lx1 - 45, sy + 155)], fill=(16, 185, 129) if is_done else (226, 232, 240), width=4)
        sy += 165

    # Bottom Help Card
    draw.rounded_rectangle([(60, 1400), (1520, 1500)], radius=24, fill=(242, 242, 245))
    draw_text_centered(draw, "هل تحتاج مساعدة في طلبك؟ فريق خدمة العملاء جاهز للرد على استفساراتكم 24/7", 1435, f_stitle, (74, 76, 86), w)

    return screen

def create_ipad_screen_5():
    # Screen 5: Special Banquets & Offers (iPad Full Layout)
    w, h = 1580, 2060
    screen = Image.new('RGB', (w, h), (248, 249, 251))
    draw = ImageDraw.Draw(screen)

    # Status Bar
    f_time = get_font(FONT_SEMI, 26)
    f_stat = get_font(FONT_BOLD, 22)
    draw.text((60, 35), "9:41", font=f_time, fill=(30, 30, 35))
    draw.text((1420, 37), "Wi-Fi   100%", font=f_stat, fill=(30, 30, 35))

    # App Bar
    f_apptitle = get_font(FONT_BOLD, 36)
    draw_text_centered(draw, "العروض الحصرية وباقات الولائم والمناسبات", 90, f_apptitle, (26, 29, 38), w)

    # Big Banquet Hero Banner
    draw.rounded_rectangle([(60, 170), (1520, 520)], radius=32, fill=(139, 29, 36))
    paste_rounded_image(screen, 'c:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images/onboarding/butchery.jpg', 80, 190, 480, 310, radius=24)
    f_btitle = get_font(FONT_BOLD, 40)
    f_bsub = get_font(FONT_MED, 26)
    f_bdesc = get_font(FONT_REG, 22)
    draw_text_right(draw, "باقة الولائم والمناسبات الكبرى 👑", 1480, 205, f_btitle, (255, 255, 255))
    draw_text_right(draw, "خصم 20% عند طلب ذبيحتين فأكثر مع التجهيز الكامل", 1480, 265, f_bsub, (223, 194, 120))
    draw_text_right(draw, "تجهيز كامل للولائم، ذبح وتقطيع فاخر، صواني خاصة، وتوصيل مبرد معتمد مباشرة لموقع المناسبة.", 1480, 320, f_bdesc, (240, 240, 245))
    draw.rounded_rectangle([(1100, 420), (1480, 490)], radius=20, fill=(255, 255, 255))
    draw_text_centered(draw, "احجز باقة المناسبات الآن ←", 438, f_bsub, (139, 29, 36), 2580)

    # Offers Section Title
    f_sec = get_font(FONT_BOLD, 32)
    draw_text_right(draw, "أقوى عروض وباقات التوفير الحصرية", 1520, 555, f_sec, (26, 29, 38))

    # 3-Column Offers Grid
    offers = [
        {
            "title": "باقة العقيقة والصدقات",
            "desc": "ذبح وتوزيع موثق بالفيديو والصور لجمعيات البر الخيرية المعتمدة مع شهادة إلكترونية رسمية.",
            "price": "1,199 ر.س",
            "save": "وفر 250 ر.س",
            "img": "assets/images/home/sheep.jpg"
        },
        {
            "title": "باقة التوفير العائلية",
            "desc": "ذبيحتين بلديتين (نعيمي + تيس) مجهزة بالكامل ومقطعة ثلاجة بأكياس فكيوم تكفي احتياج الشهر.",
            "price": "2,399 ر.س",
            "save": "وفر 350 ر.س",
            "img": "assets/images/home/lamb.jpg"
        },
        {
            "title": "عرض نهاية الأسبوع",
            "desc": "كاش باك 10% فوري يضاف مباشرة إلى محفظتك في التطبيق عند الدفع بواسطة Apple Pay.",
            "price": "كاش باك 10%",
            "save": "عرض حصري 🔥",
            "img": "assets/images/home/meat.jpg"
        }
    ]

    card_w = 466
    card_h = 560
    f_otitle = get_font(FONT_BOLD, 26)
    f_odesc = get_font(FONT_REG, 20)
    f_oprice = get_font(FONT_BOLD, 30)
    f_osave = get_font(FONT_BOLD, 20)

    for i, o in enumerate(offers):
        col = i
        cx = 1520 - (col + 1) * card_w - (col * 30)
        cy = 615

        draw.rounded_rectangle([(cx, cy), (cx + card_w, cy + card_h)], radius=24, fill=(255, 255, 255), outline=(226, 232, 240), width=1)
        paste_rounded_image(screen, o['img'], cx + 14, cy + 14, card_w - 28, 260, radius=18)

        draw_text_right(draw, o['title'], cx + card_w - 20, cy + 295, f_otitle, (26, 29, 38))
        draw_text_right(draw, o['desc'], cx + card_w - 20, cy + 345, f_odesc, (122, 126, 137))

        draw_text_right(draw, o['price'], cx + card_w - 20, cy + 440, f_oprice, (229, 57, 53))
        draw.rounded_rectangle([(cx + 20, cy + 430), (cx + 180, cy + 485)], radius=14, fill=(254, 242, 242), outline=(229, 57, 53), width=1)
        draw_text_centered(draw, o['save'], cy + 445, f_osave, (229, 57, 53), cx * 2 + 200)

        draw.rounded_rectangle([(cx + 20, cy + 498), (cx + card_w - 20, cy + 545)], radius=14, fill=(139, 29, 36))
        draw_text_centered(draw, "احجز هذا العرض ←", cy + 510, f_osave, (255, 255, 255), cx * 2 + card_w)

    # Loyalty Club Banner
    draw.rounded_rectangle([(60, 1210), (1520, 1440)], radius=26, fill=(254, 243, 199), outline=(251, 191, 36), width=1)
    draw_text_right(draw, "نادي ذبائح المملكة للولاء والمكافآت 🌟", 1480, 1235, f_sec, (120, 53, 15))
    draw_text_right(draw, "اجمع نقاطاً مع كل طلب ذبيحة واستبدلها بخصومات نقدية فورية عند الدفع.", 1480, 1290, f_odesc, (146, 64, 14))
    draw_text_right(draw, "رصيد نقاطك الحالي: 350 نقطة (تساوي 35 ر.س خصم نقدي فوري على طلبك القادم)", 1480, 1340, f_otitle, (180, 83, 9))
    draw.rounded_rectangle([(80, 1355), (340, 1415)], radius=16, fill=(180, 83, 9))
    draw_text_centered(draw, "استبدال النقاط الآن ←", 1372, f_osave, (255, 255, 255), 420)

    # Bottom Order CTA
    draw.rectangle([(0, 1860), (w, 2060)], fill=(255, 255, 255), outline=(226, 232, 240), width=1)
    draw.rounded_rectangle([(60, 1900), (1520, 1990)], radius=24, fill=(139, 29, 36))
    f_btn = get_font(FONT_BOLD, 32)
    draw_text_centered(draw, "استفد من العروض الحصرية واطلب ذبيحتك الآن ←", 1928, f_btn, (255, 255, 255), w)

    return screen

# -------------------------------------------------------------
# IPAD SCREENSHOT COMPOSITOR (2048 x 2732)
# -------------------------------------------------------------

def compose_ipad_screenshot(screen_img, badge_text, title_text, subtitle_text, out_path, bg_color1=(125, 20, 24), bg_color2=(25, 5, 8)):
    W, H = 2048, 2732
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
    f_badge = get_font(FONT_SEMI, 32)
    draw_pill(draw, badge_text, W // 2, 100, f_badge, bg_fill=(60, 8, 12), text_fill=(223, 194, 120), border_fill=(197, 154, 63), pad_x=40, pad_y=14, radius=28)

    f_title = get_font(FONT_BOLD, 92)
    draw_text_centered(draw, title_text, 205, f_title, (255, 255, 255), W)

    f_sub = get_font(FONT_MED, 44)
    draw_text_centered(draw, subtitle_text, 335, f_sub, (238, 216, 174), W)

    # Device Mockup (iPad Pro Frame)
    dev_w, dev_h = 1680, 2160
    dev_x = (W - dev_w) // 2
    dev_y = 470

    # Draw Outer Titanium Shadow
    shadow = Image.new('RGBA', (dev_w + 100, dev_h + 100), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rounded_rectangle([(50, 50), (dev_w + 50, dev_h + 50)], radius=65, fill=(0, 0, 0, 160))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=30))
    canvas.paste(shadow, (dev_x - 50, dev_y - 35), shadow)

    # Outer Frame
    draw.rounded_rectangle([(dev_x, dev_y), (dev_x + dev_w, dev_y + dev_h)], radius=52, fill=(38, 39, 44), outline=(80, 82, 92), width=4)

    # Front camera dot at top bezel center
    cam_x = dev_x + dev_w // 2
    cam_y = dev_y + 25
    draw.ellipse([(cam_x - 7, cam_y - 7), (cam_x + 7, cam_y + 7)], fill=(15, 18, 25), outline=(50, 52, 60), width=1)

    # Inner Screen paste (1580 x 2060)
    scr_w, scr_h = 1580, 2060
    scr_x = dev_x + (dev_w - scr_w) // 2
    scr_y = dev_y + 50

    scr_mask = Image.new('L', (scr_w, scr_h), 0)
    smd = ImageDraw.Draw(scr_mask)
    smd.rounded_rectangle([(0, 0), (scr_w, scr_h)], radius=36, fill=255)

    screen_rgba = screen_img.convert('RGBA')
    screen_rgba.putalpha(scr_mask)
    canvas.paste(screen_rgba, (scr_x, scr_y), screen_rgba)

    # Home Indicator Bar at bottom of screen
    hi_w, hi_h = 360, 8
    hi_x = dev_x + (dev_w - hi_w) // 2
    hi_y = scr_y + scr_h - 20
    draw.rounded_rectangle([(hi_x, hi_y), (hi_x + hi_w, hi_y + hi_h)], radius=4, fill=(40, 40, 45))

    canvas.save(out_path, 'PNG')
    print(f"Saved iPad Screenshot: {out_path} ({W}x{H})")

def build_ipad_assets():
    print("=" * 60)
    print("Rendering iPad Master Screens & Screenshots (2048x2732)...")
    print("=" * 60)

    s1 = create_ipad_screen_1()
    s2 = create_ipad_screen_2()
    s3 = create_ipad_screen_3()
    s4 = create_ipad_screen_4()
    s5 = create_ipad_screen_5()

    screens_data = [
        (s1, "★ ذبائح بلدية طازجة ومضمونة 100% ★", "أجود الذبائح واللحوم البلديّة", "نعيمي، حري، نجدي، سواكني، وتيوس عارضية طازجة", "01_Home_Catalog_iPad"),
        (s2, "★ تفصيل وتقطيع وتغليف حسب رغبتك ★", "خيارات تقطيع وتغليف متكاملة", "ثلاجة، مفطح، أرباع، وتغليف سحب هواء فكيوم", "02_Customization_Cuts_iPad"),
        (s3, "★ شحن مبرد مجاني وخيارات دفع آمنة ★", "دفع سريع وآمن مع Apple Pay", "ادفع بـ Apple Pay، مدى، فيزا، أو قسّط مع تابي", "03_Cart_ApplePay_iPad"),
        (s4, "★ أسطول سيارات مبردة بدرجة 1-4° مئوية ★", "تتبع مبرد لحظي لباب بيتك", "متابعة حية من المسلخ المعتمد حتى الاستلام", "04_Chilled_Tracking_iPad"),
        (s5, "★ باقات المناسبات الكبرى والعقيقة والصدقات ★", "عروض حصرية وباقات الولائم", "أفضل الأسعار وباقات توفير عائلية مع نقاط مكافآت", "05_Special_Offers_iPad"),
    ]

    for scr_img, badge, title, subtitle, prefix in screens_data:
        ipad_out = f"{IPAD_DIR}/{prefix}_2048x2732.png"
        compose_ipad_screenshot(scr_img, badge, title, subtitle, ipad_out)

    print("All iPad Screenshots generated successfully!")

if __name__ == '__main__':
    build_ipad_assets()

