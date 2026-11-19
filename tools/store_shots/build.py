"""Builds store screenshots by rendering HTML with headless Chrome.
Usage: python tools/store_shots/build.py
"""
import os, subprocess, tempfile, pathlib
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[2]
IMG = (ROOT / 'assets/images').as_posix()
REACT = 'C:/Users/ahmed/StudioProjects/dhabayih_lmamlaka_react_cartoon/public/images'
FONTS = (ROOT / 'assets/fonts').as_posix()
LOGO = (ROOT / 'store_assets/01_iOS_Assets/AppIcon_1024x1024.png').as_posix()
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
OUT_IOS = ROOT / 'store_assets/01_iOS_Assets/Screenshots_1290x2796'
OUT_AND = ROOT / 'store_assets/02_Android_Assets/Screenshots_1080x1920'

CSS = f"""
@font-face{{font-family:P;font-weight:400;src:url('file:///{FONTS}/Plex-Regular.ttf')}}
@font-face{{font-family:P;font-weight:500;src:url('file:///{FONTS}/Plex-Medium.ttf')}}
@font-face{{font-family:P;font-weight:600;src:url('file:///{FONTS}/Plex-SemiBold.ttf')}}
@font-face{{font-family:P;font-weight:700;src:url('file:///{FONTS}/Plex-Bold.ttf')}}
*{{box-sizing:border-box;margin:0;padding:0}}
html,body{{width:var(--W);height:var(--H);overflow:hidden;font-family:P,'Segoe UI Emoji',sans-serif;direction:rtl}}
body{{background:radial-gradient(1200px 900px at 85% 0%,#b3262f 0%,transparent 60%),radial-gradient(1000px 800px at 0% 100%,#c59a3f55 0%,transparent 55%),linear-gradient(160deg,#8b1d24 0%,#4a0b10 60%,#2a0508 100%);position:relative;color:#fff}}
.pattern{{position:absolute;inset:0;background-image:radial-gradient(#ffffff14 2px,transparent 2px);background-size:46px 46px}}
.head{{position:absolute;top:calc(var(--H)*.045);width:100%;text-align:center;padding:0 5%}}
.badge{{display:inline-block;background:#00000040;border:2px solid #c59a3f;color:#f1d99a;border-radius:99px;padding:calc(var(--W)*.011) calc(var(--W)*.035);font-size:calc(var(--W)*.024);font-weight:600}}
.title{{font-size:calc(var(--W)*.072);font-weight:700;line-height:1.25;margin-top:calc(var(--W)*.03);text-shadow:0 6px 30px #0006}}
.title b{{color:#f1d99a}}
.sub{{font-size:calc(var(--W)*.033);color:#f3e2c0;margin-top:calc(var(--W)*.018);font-weight:500}}
.stage{{position:absolute;left:0;right:0;top:var(--PT);bottom:0;overflow:hidden}}
.phone{{position:absolute;left:50%;top:0;width:392px;height:880px;transform-origin:top center;transform:translateX(-50%) scale(var(--S));background:#111;border-radius:58px;padding:11px;box-shadow:0 0 0 3px #5b5d66,0 40px 120px #000a,0 0 0 14px #1d1e22}}
.scr{{width:100%;height:100%;border-radius:48px;overflow:hidden;background:#f6f7f9;color:#1a1d26;position:relative;direction:rtl}}
.island{{position:absolute;top:10px;left:50%;transform:translateX(-50%);width:104px;height:30px;background:#000;border-radius:20px;z-index:20}}
.sb{{height:50px;display:flex;justify-content:space-between;align-items:flex-end;padding:0 28px 6px;font-size:13px;font-weight:700}}
.float{{position:absolute;background:#fff;color:#1a1d26;border-radius:22px;padding:calc(var(--W)*.017) calc(var(--W)*.028);font-weight:700;font-size:calc(var(--W)*.027);box-shadow:0 20px 50px #0008;display:flex;gap:calc(var(--W)*.015);align-items:center;z-index:30;border:2px solid #c59a3f}}
.float small{{display:block;font-weight:500;color:#7a7e89;font-size:calc(var(--W)*.02)}}
/* UI atoms */
.pad{{padding:0 16px}}
.row{{display:flex;align-items:center}}
.between{{justify-content:space-between}}
.card{{background:#fff;border:1px solid #e8ebf0;border-radius:18px;overflow:hidden}}
.red{{color:#e53935}} .dark{{color:#8b1d24}} .gold{{color:#c59a3f}} .mut{{color:#7a7e89}}
.btn{{background:linear-gradient(135deg,#a3232b,#8b1d24);color:#fff;border-radius:16px;text-align:center;font-weight:700;padding:13px;font-size:14px;box-shadow:0 8px 18px #8b1d2455}}
.img{{background-size:cover;background-position:center}}
.chip{{border:1.5px solid #e2e8f0;border-radius:14px;padding:9px 12px;font-size:12px;font-weight:600;background:#fff}}
.chip.on{{border-color:#e53935;background:#fdf0f0;color:#c62828}}
.h2{{font-size:16px;font-weight:700}}
.tabbar{{position:absolute;bottom:0;left:0;right:0;height:78px;background:#fff;border-top:1px solid #e8ebf0;display:flex;justify-content:space-around;padding-top:10px;font-size:10px;font-weight:600;color:#7a7e89;text-align:center}}
.tabbar div span{{display:block;font-size:20px}}
.tabbar .a{{color:#e53935}}
"""

def card_product(name, sub, price, badge, img, rate):
    return f"""<div class="card"><div class="img" style="height:118px;background-image:url('file:///{img}');position:relative">
    <span style="position:absolute;top:8px;right:8px;background:#8b1d24;color:#fff;font-size:10px;font-weight:700;padding:4px 8px;border-radius:9px">{badge}</span>
    <span style="position:absolute;top:8px;left:8px;background:#fff;color:#c59a3f;font-size:10px;font-weight:700;padding:4px 7px;border-radius:9px">★ {rate}</span></div>
    <div style="padding:10px"><div style="font-weight:700;font-size:13px">{name}</div><div class="mut" style="font-size:10.5px;margin:2px 0 8px">{sub}</div>
    <div class="row between"><b class="red" style="font-size:15px">{price} <small style="font-size:10px">ر.س</small></b><span style="background:#8b1d24;color:#fff;width:28px;height:28px;border-radius:10px;text-align:center;line-height:28px;font-weight:700">+</span></div></div></div>"""

def tabbar(active=0):
    t = [('🏠','الرئيسية'),('🥩','الأقسام'),('🛒','السلة'),('📦','طلباتي'),('👤','حسابي')]
    return '<div class="tabbar">' + ''.join(f'<div class="{"a" if i==active else ""}"><span>{e}</span>{n}</div>' for i,(e,n) in enumerate(t)) + '</div>'

def screen_home():
    stories = [('العروض',f'{IMG}/home/sheep.jpg',1),('نعيمي',f'{IMG}/home/lamb.jpg',0),('حري',f'{IMG}/home/meat.jpg',0),('تيوس',f'{IMG}/home/cow.jpg',0),('حواشي',f'{IMG}/home/camel.jpg',0)]
    st = ''.join(f'<div style="text-align:center;font-size:10.5px;font-weight:600"><div style="width:58px;height:58px;border-radius:50%;padding:3px;border:2.5px solid {"#e53935" if a else "#c59a3f"}"><div class="img" style="width:100%;height:100%;border-radius:50%;background-image:url(\'file:///{i}\')"></div></div>{n}</div>' for n,i,a in stories)
    return f"""<div class="sb"><span>9:41</span><span>5G ▮▮▮</span></div>
    <div class="pad row between" style="margin-top:4px"><div class="row" style="gap:9px"><img src="file:///{LOGO}" style="width:40px;height:40px;border-radius:11px"><div><div style="font-weight:700;font-size:15px" class="dark">ذبائح المملكة</div><div class="mut" style="font-size:10px">📍 الرياض - حي النرجس</div></div></div><div style="width:38px;height:38px;border-radius:50%;background:#fff;border:1px solid #e8ebf0;text-align:center;line-height:38px;position:relative">🔔<i style="position:absolute;top:7px;right:9px;width:8px;height:8px;background:#e53935;border-radius:50%"></i></div></div>
    <div class="pad" style="margin-top:12px"><div class="card" style="padding:11px 14px;font-size:12px;color:#9aa0ab;border-radius:15px">🔍 ابحث عن ذبيحة أو تقطيع أو عرض...</div></div>
    <div class="pad row" style="gap:13px;margin-top:14px;overflow:hidden">{st}</div>
    <div class="pad" style="margin-top:14px"><div style="border-radius:22px;overflow:hidden;position:relative;height:150px;background:#8b1d24"><div class="img" style="position:absolute;inset:0;background-image:url('file:///{REACT}/onboarding/livestock.jpg');opacity:.55"></div><div style="position:absolute;inset:0;background:linear-gradient(270deg,#8b1d24f2 35%,#8b1d2400)"></div>
    <div style="position:absolute;right:16px;top:14px;color:#fff;width:200px"><span style="background:#c59a3f;font-size:10px;font-weight:700;padding:3px 9px;border-radius:99px">عرض التدشين</span><div style="font-size:21px;font-weight:700;margin-top:8px;line-height:1.25">خصم 15% على الذبائح البلدية</div><div style="background:#fff;color:#8b1d24;font-weight:700;font-size:11px;display:inline-block;padding:7px 14px;border-radius:12px;margin-top:10px">اطلب الآن ←</div></div></div></div>
    <div class="pad row between" style="margin-top:14px"><b class="h2">الأكثر طلباً 🔥</b><span class="gold" style="font-size:11px;font-weight:600">عرض الكل ←</span></div>
    <div class="pad" style="display:grid;grid-template-columns:1fr 1fr;gap:11px;margin-top:10px">
    {card_product('خروف نعيمي بلدي','جذع طازج • 12-14 كجم','1,450','الأكثر طلباً',f'{IMG}/home/sheep.jpg','4.9')}
    {card_product('خروف حري فاخر','تربية مزارعنا • 13-15 كجم','1,350','طازج اليوم',f'{IMG}/home/lamb.jpg','4.8')}
    {card_product('تيس بلدي عارضي','لحم لباني ناعم • 8-10 كجم','950','جودة فاخرة',f'{IMG}/home/meat.jpg','4.9')}
    {card_product('ربع ذبيحة مجهز','تقطيع ثلاجة • 4-5 كجم','390','ذبح اليوم',f'{IMG}/quarter_carcass.jpg','5.0')}
    </div>{tabbar(0)}"""

def screen_custom():
    def chips(items):
        return ''.join(f'<span class="chip {"on" if on else ""}">{"✓ " if on else ""}{t}</span>' for t,on in items)
    return f"""<div style="position:relative;height:300px" class="img" ><div class="img" style="position:absolute;inset:0;background-image:url('file:///{IMG}/half_carcass.jpg')"></div>
    <div style="position:absolute;inset:0;background:linear-gradient(180deg,#0006,#0000 40%,#0008)"></div>
    <div class="sb" style="position:relative;color:#fff"><span>9:41</span><span>5G ▮▮▮</span></div>
    <div class="pad row between" style="position:relative"><span style="width:36px;height:36px;border-radius:50%;background:#fff;text-align:center;line-height:36px;color:#1a1d26">→</span><span style="width:36px;height:36px;border-radius:50%;background:#fff;text-align:center;line-height:36px;color:#e53935">♥</span></div>
    <div style="position:absolute;bottom:14px;right:16px;left:16px" class="row between"><span style="background:#8b1d24;color:#fff;font-size:11px;font-weight:700;padding:6px 11px;border-radius:11px">ذبح إسلامي معتمد ✓</span><span style="background:#c59a3f;color:#fff;font-size:11px;font-weight:700;padding:6px 11px;border-radius:11px">🩺 كشف بيطري</span></div></div>
    <div style="margin-top:-16px;background:#f6f7f9;border-radius:24px 24px 0 0;position:relative;padding-top:14px">
    <div class="pad row between"><div><b style="font-size:19px">خروف نعيمي بلدي</b><div class="mut" style="font-size:11px;margin-top:2px">★★★★★ 4.9 (340 تقييم)</div></div><b class="red" style="font-size:22px">1,450 <small style="font-size:11px">ر.س</small></b></div>
    <div class="pad" style="margin-top:14px"><b class="h2">1 · اختر الحجم</b><div class="row" style="gap:8px;margin-top:8px">
    <div class="chip on" style="flex:1;text-align:center">جذع 12-14 كجم<br><b>1,450</b></div><div class="chip" style="flex:1;text-align:center">وسط 15-17 كجم<br><b>1,650</b></div><div class="chip" style="flex:1;text-align:center">كبير 18-20 كجم<br><b>1,850</b></div></div></div>
    <div class="pad" style="margin-top:14px"><b class="h2">2 · طريقة التقطيع</b><div class="row" style="gap:7px;margin-top:8px;flex-wrap:wrap">{chips([('تقطيع ثلاجة',1),('مفطح كامل',0),('أرباع',0),('حضرمي فاخر',0),('شواء وستيك',0)])}</div></div>
    <div class="pad" style="margin-top:14px"><b class="h2">3 · التجهيز والتغليف</b>
    <div class="card row between" style="padding:11px 14px;margin-top:8px;font-size:12px;font-weight:600"><span>🐑 شلوطة الرأس والكوارع</span><span style="background:#e53935;color:#fff;width:22px;height:22px;border-radius:7px;text-align:center">✓</span></div>
    <div class="card row between" style="padding:11px 14px;margin-top:8px;font-size:12px;font-weight:600;border-color:#e53935;background:#fdf0f0"><span>📦 تغليف فاكيوم (حفظ مضاعف)</span><span style="background:#e53935;color:#fff;width:22px;height:22px;border-radius:50%;text-align:center">✓</span></div></div></div>
    <div style="position:absolute;bottom:0;left:0;right:0;background:#fff;padding:12px 16px 20px;border-top:1px solid #e8ebf0" class="row"><div class="btn" style="flex:1">أضف إلى السلة • 1,450 ر.س</div></div>"""

def screen_cart():
    def item(img, t, s, p):
        return f"""<div class="card row" style="padding:10px;gap:11px;margin-top:10px"><div class="img" style="width:70px;height:70px;border-radius:14px;background-image:url('file:///{img}')"></div><div style="flex:1"><b style="font-size:13px">{t}</b><div class="mut" style="font-size:10.5px;margin:2px 0 6px">{s}</div><div class="row between"><b class="red">{p} ر.س</b><span style="background:#f2f2f5;border-radius:10px;padding:3px 10px;font-weight:700;font-size:13px">− 1 <span class="red">+</span></span></div></div></div>"""
    def pay(t,s,on,ic):
        return f"""<div class="card row" style="padding:11px 13px;gap:11px;margin-top:8px;{'border-color:#e53935;background:#fdf0f0' if on else ''}"><span style="width:20px;height:20px;border-radius:50%;border:2px solid {'#e53935' if on else '#cbd0d8'};display:inline-block;{'background:radial-gradient(#e53935 45%,transparent 50%)' if on else ''}"></span><div style="flex:1"><b style="font-size:13px">{t}</b><div class="mut" style="font-size:10px">{s}</div></div><span style="font-size:20px">{ic}</span></div>"""
    return f"""<div class="sb"><span>9:41</span><span>5G ▮▮▮</span></div>
    <div class="pad row between"><b style="font-size:18px">السلة</b><span class="mut" style="font-size:12px">2 منتجات</span></div>
    <div class="pad"><div style="background:#ecfdf5;border:1px solid #a7f3d0;color:#065f46;border-radius:14px;padding:10px 12px;margin-top:10px;font-size:11.5px;font-weight:700">🚚 مبروك! توصيل مبرد مجاني على طلبك<div style="height:6px;background:#10b981;border-radius:9px;margin-top:7px"></div></div>
    {item(IMG+'/home/sheep.jpg','خروف نعيمي بلدي','تقطيع ثلاجة • فاكيوم • شلوطة','1,450')}
    {item(IMG+'/home/meat.jpg','كبدة وكلاوي طازجة','طازج من مسلخ الأمانة','65')}
        <b class="h2" style="display:block;margin-top:14px">طريقة الدفع</b>
    {pay('Apple Pay','دفع آمن بنقرة واحدة',1,'')}
    {pay('مدى / فيزا / ماستركارد','مشفّر بالكامل',0,'💳')}
    {pay('تابي / تمارا','قسّمها على 4 دفعات',0,'🗓️')}
    <div class="card" style="padding:12px 14px;margin-top:12px;font-size:12px"><div class="row between"><span class="mut">المجموع</span><b>1,515 ر.س</b></div><div class="row between" style="margin-top:5px"><span class="mut">التوصيل المبرد</span><b style="color:#059669">مجاناً</b></div><div class="row between" style="margin-top:5px"><span class="mut">كوبون MAMLAKA</span><b style="color:#059669">-150 ر.س</b></div><hr style="border:0;border-top:1px dashed #d9dde3;margin:9px 0"><div class="row between"><b style="font-size:14px">الإجمالي</b><b class="red" style="font-size:19px">1,365 ر.س</b></div></div></div>
    <div style="position:absolute;bottom:0;left:0;right:0;background:#fff;padding:12px 16px 20px;border-top:1px solid #e8ebf0"><div style="background:#000;color:#fff;border-radius:16px;text-align:center;padding:14px;font-weight:700;font-size:15px">  Pay  إتمام الدفع</div></div>"""

def screen_track():
    steps = [('تم تأكيد الطلب','9:15 ص',1,0),('الذبح بمسلخ الأمانة','10:00 ص • إشراف بيطري',1,0),('التقطيع والتغليف فاكيوم','10:45 ص',1,0),('في الطريق إليك','11:15 ص • سيارة مبردة',1,1),('تم التسليم','قريباً',0,0)]
    s = ''
    for i,(t,sub,done,act) in enumerate(steps):
        col = '#e53935' if act else ('#10b981' if done else '#d0d4db')
        line = '' if i==len(steps)-1 else f'<i style="position:absolute;right:13px;top:28px;width:3px;height:34px;background:{"#10b981" if done and not act else "#e5e7eb"}"></i>'
        s += f'<div style="position:relative;display:flex;gap:12px;margin-bottom:14px;align-items:flex-start"><span style="width:28px;height:28px;border-radius:50%;background:{col};color:#fff;text-align:center;line-height:28px;font-size:13px;flex:none;{"box-shadow:0 0 0 6px #e5393533" if act else ""}">{"🚚" if act else ("✓" if done else "")}</span>{line}<div><b style="font-size:13px;{"color:#e53935" if act else ""}">{t}</b><div class="mut" style="font-size:10.5px">{sub}</div></div></div>'
    return f"""<div style="position:relative;height:290px"><div class="img" style="position:absolute;inset:0;background-image:url('file:///{REACT}/onboarding/delivery.jpg')"></div><div style="position:absolute;inset:0;background:linear-gradient(180deg,#000a,#0000 45%,#000c)"></div>
    <div class="sb" style="position:relative;color:#fff"><span>9:41</span><span>5G ▮▮▮</span></div>
    <div class="pad" style="position:relative;color:#fff"><b style="font-size:17px">تتبع الطلب #DM-98241</b></div>
    <div style="position:absolute;bottom:34px;right:16px;left:16px;background:#fffffff2;border-radius:16px;padding:10px 13px" class="row between"><div><b style="font-size:13px">❄️ حرارة الشاحنة 3.2°م</b><div class="mut" style="font-size:10.5px">سلسلة تبريد مستمرة حتى بابك</div></div><span style="background:#e53935;color:#fff;font-weight:700;font-size:12px;padding:7px 11px;border-radius:12px">25 د</span></div></div>
    <div style="margin-top:-18px;background:#f6f7f9;border-radius:24px 24px 0 0;position:relative;padding:18px 16px 0">
    <div class="card" style="padding:16px 14px 4px">{s}</div>
    <div class="card row" style="padding:12px;gap:12px;margin-top:12px"><div style="width:52px;height:52px;border-radius:50%;background:#f2f2f5;border:2px solid #c59a3f;text-align:center;line-height:48px;font-size:26px">👨‍✈️</div><div style="flex:1"><b style="font-size:13px">الكابتن فهد الشمري</b><div class="gold" style="font-size:11px;font-weight:700">★ 4.9 • 340 تقييم</div></div><span style="width:38px;height:38px;border-radius:12px;background:#25d366;text-align:center;line-height:38px">💬</span><span style="width:38px;height:38px;border-radius:12px;background:#8b1d24;text-align:center;line-height:38px">📞</span></div>
    <div style="background:#fefce8;border:1px solid #fde68a;border-radius:16px;padding:11px 13px;margin-top:12px;font-size:11px;color:#92400e"><b>🛡️ الضمان الذهبي</b><br>استبدال فوري أو استرجاع كامل المبلغ إذا لم يطابق طلبك.</div></div>"""

def screen_offers():
    def off(img,t,d,price,save):
        return f"""<div class="card row" style="margin-top:10px;gap:0;align-items:stretch"><div class="img" style="width:105px;background-image:url('file:///{img}')"></div><div style="flex:1;padding:11px"><b style="font-size:13px">{t}</b><div class="mut" style="font-size:10.5px;margin:3px 0 8px;line-height:1.5">{d}</div><div class="row between"><b class="red" style="font-size:16px">{price}</b><span style="background:#fdf0f0;color:#e53935;border:1px solid #e53935;font-size:10px;font-weight:700;padding:3px 8px;border-radius:9px">{save}</span></div></div></div>"""
    return f"""<div class="sb"><span>9:41</span><span>5G ▮▮▮</span></div>
    <div class="pad"><b style="font-size:18px">العروض والباقات</b></div>
    <div class="pad" style="margin-top:12px"><div style="border-radius:22px;overflow:hidden;position:relative;height:180px;background:#8b1d24"><div class="img" style="position:absolute;inset:0;background-image:url('file:///{REACT}/onboarding/butchery.jpg');opacity:.5"></div><div style="position:absolute;inset:0;background:linear-gradient(270deg,#8b1d24f5 40%,#8b1d2400)"></div>
    <div style="position:absolute;right:16px;top:16px;width:210px;color:#fff"><span style="background:#c59a3f;font-size:10px;font-weight:700;padding:3px 9px;border-radius:99px">👑 للمناسبات</span><div style="font-size:22px;font-weight:700;margin-top:9px;line-height:1.25">باقة الولائم الكبرى</div><div style="font-size:11px;margin-top:4px;color:#f1d99a">خصم 20% عند طلب ذبيحتين فأكثر</div><div style="background:#fff;color:#8b1d24;font-weight:700;font-size:11px;display:inline-block;padding:7px 14px;border-radius:12px;margin-top:12px">احجز الآن ←</div></div></div></div>
    <div class="pad" style="margin-top:6px">
    {off(IMG+'/home/sheep.jpg','باقة العقيقة والصدقات','ذبح وتوزيع موثق بالصور وشهادة إلكترونية','1,199 ر.س','وفر 250')}
    {off(IMG+'/home/lamb.jpg','الباقة العائلية','ذبيحتان مقطعتان وفاكيوم تكفي الشهر','2,399 ر.س','وفر 350')}
    {off(IMG+'/home/cow.jpg','عرض نهاية الأسبوع','كاش باك 10% في محفظتك مع Apple Pay','10%','حصري')}
    <div style="margin-top:12px;background:linear-gradient(135deg,#fef3c7,#fde68a);border:1px solid #fbbf24;border-radius:18px;padding:13px 14px;color:#78350f"><b style="font-size:13px">🌟 نادي المملكة للمكافآت</b><div style="font-size:11px;margin:4px 0 9px">رصيدك 350 نقطة = 35 ر.س خصم فوري</div><div style="height:7px;background:#fff8;border-radius:9px"><div style="width:70%;height:100%;background:#b45309;border-radius:9px"></div></div></div></div>
    {tabbar(3)}"""

SCREENS = [
    ('01_Home_Catalog', screen_home, '★ لحوم بلدية طازجة ★', 'أجود الذبائح <b>حتى باب بيتك</b>', 'نعيمي • حري • نجدي • تيوس — مذبوحة وفق الشريعة',
     [('🐑','ذبح حلال معتمد','إشراف بيطري كامل','top:calc(var(--PT) + var(--FY));right:3%')]),
    ('02_Customization_Cuts', screen_custom, '★ خصّصها على ذوقك ★', 'قطّعها <b>زي ما تحب</b>', 'ثلاجة • مفطح • أرباع • تغليف فاكيوم',
     [('🔪','تقطيع حسب الطلب','+5 خيارات','top:calc(var(--PT) + var(--FY));left:3%')]),
    ('03_Cart_ApplePay', screen_cart, '★ دفع آمن وسريع ★', 'ادفع بنقرة <b>Apple Pay</b>', 'مدى • فيزا • تابي • تمارا — وتوصيل مبرد مجاني',
     [('✅','تم تطبيق الكوبون','وفرت 150 ر.س','top:calc(var(--PT) + var(--FY));right:3%')]),
    ('04_Chilled_Tracking', screen_track, '★ سلسلة تبريد متكاملة ★', 'تتبّع طلبك <b>لحظة بلحظة</b>', 'من المسلخ المعتمد حتى باب منزلك',
     [('❄️','3.2°م','درجة حرارة الشاحنة','top:calc(var(--PT) + var(--FY));left:3%')]),
    ('05_Special_Offers', screen_offers, '★ عروض حصرية ★', 'وفّر أكثر مع <b>الباقات</b>', 'ولائم • عقيقة • باقات عائلية • نقاط مكافآت',
     [('🎁','وفر حتى 350 ر.س','باقات التوفير','top:calc(var(--PT) + var(--FY));right:3%')]),
]

CSS2 = """
body{background:
 radial-gradient(ellipse 22% 14% at 0% 40%,#fff3cfdd 0%,#f1d99a66 35%,transparent 70%),
 radial-gradient(ellipse 22% 14% at 100% 40%,#fff3cfdd 0%,#f1d99a66 35%,transparent 70%),
 radial-gradient(ellipse 70% 45% at 50% 62%,#6a1018 0%,#2a060b 60%,transparent 100%),
 radial-gradient(ellipse 120% 30% at 50% 100%,#c59a3f66 0%,transparent 70%),
 linear-gradient(180deg,#07090d 0%,#12060a 60%,#1c0709 100%)}
.pattern{background-image:radial-gradient(#f1d99a55 2px,transparent 2.5px),radial-gradient(#f1d99a33 3px,transparent 3.5px);background-size:130px 170px,230px 260px;background-position:20px 30px,90px 110px;opacity:.55}
.cone{position:absolute;top:30%;width:34%;height:34%;filter:blur(40px);opacity:.35;background:linear-gradient(var(--a),#fff3cf,transparent 75%)}
.head{top:calc(var(--H)*.03)}
.logo{height:calc(var(--W)*.15);border-radius:22%;border:3px solid #f1d99a;box-shadow:0 0 50px #c59a3fcc,0 8px 24px #000a}
.en{font-size:calc(var(--W)*.078);font-weight:700;letter-spacing:.02em;text-transform:uppercase;direction:ltr;margin-top:calc(var(--W)*.02);text-shadow:0 6px 30px #000a}
.ar{font-size:calc(var(--W)*.066);font-weight:700;margin-top:calc(var(--W)*.004);background:linear-gradient(180deg,#f7e3a6,#c59a3f);-webkit-background-clip:text;color:transparent}
.stage{bottom:var(--BR);overflow:visible;z-index:5}
.phone{perspective:none;transform:translateX(-50%) scale(var(--S)) rotate(3deg);background:#16171b;box-shadow:0 0 0 3px #8d8f99,0 0 0 11px #24252a,0 0 120px #c59a3f88,0 50px 120px #000c}
.ring{position:absolute;left:12%;right:12%;bottom:calc(var(--BR) - var(--H)*.03);height:calc(var(--H)*.06);border-radius:50%;border:4px solid #f1d99a;box-shadow:0 0 50px #f1d99a,inset 0 0 50px #c59a3f;background:radial-gradient(#c59a3f55,transparent 70%);z-index:1}
.float{background:#12141a;color:#fff;border:2px solid #c59a3f;box-shadow:0 0 40px #c59a3f55,0 20px 50px #000c;border-radius:26px;padding:calc(var(--W)*.02) calc(var(--W)*.03);font-size:calc(var(--W)*.03);z-index:40}
.float small{color:#c9ccd4;font-size:calc(var(--W)*.022)}
.cta{position:absolute;left:50%;transform:translateX(-50%);bottom:calc(var(--BR) + var(--H)*.02);z-index:45;background:linear-gradient(180deg,#f7e3a6,#c59a3f);color:#3a0a10;font-weight:700;font-size:calc(var(--W)*.036);padding:calc(var(--W)*.02) calc(var(--W)*.07);border-radius:calc(var(--W)*.03);box-shadow:0 0 0 4px #00000066,0 0 70px #f1d99aaa,0 18px 40px #000a;white-space:nowrap}
.chips{position:absolute;bottom:calc(var(--H)*.018);left:0;right:0;display:flex;justify-content:center;gap:calc(var(--W)*.025);z-index:45}
.chips span{background:#00000066;border:1.5px solid #c59a3f99;color:#f3e2c0;border-radius:99px;padding:calc(var(--W)*.011) calc(var(--W)*.028);font-size:calc(var(--W)*.024);font-weight:600}
"""

EN = {'01_Home_Catalog': 'Fresh Local Meat', '02_Customization_Cuts': 'Cut It Your Way', '03_Cart_ApplePay': 'Pay In One Tap',
      '04_Chilled_Tracking': 'Chilled Delivery', '05_Special_Offers': 'Exclusive Offers'}
AR = {'01_Home_Catalog': 'أجود الذبائح حتى باب بيتك', '02_Customization_Cuts': 'قطّعها زي ما تحب', '03_Cart_ApplePay': 'دفع آمن وسريع',
      '04_Chilled_Tracking': 'تتبّع طلبك لحظة بلحظة', '05_Special_Offers': 'وفّر أكثر مع الباقات'}
CTA = {'01_Home_Catalog': 'اطلب ذبيحتك الآن', '02_Customization_Cuts': 'خصّص طلبك الآن', '03_Cart_ApplePay': 'أتمم الدفع بأمان',
       '04_Chilled_Tracking': 'تابع طلبك الآن', '05_Special_Offers': 'استفد من العروض'}
FY = {'01_Home_Catalog': 560, '02_Customization_Cuts': 640, '03_Cart_ApplePay': 470, '04_Chilled_Tracking': 600, '05_Special_Offers': 520}

def page(W, H, scr_html, badge, title, sub, floats, name=''):
    pt = int(H * 0.27); br = int(H * 0.10)
    scale = min((W * 0.80) / 392, (H - pt - br - 30) / 880)
    fl = ''
    for e, t, s_, pos in floats:
        side = 'left' if 'left' in pos else 'right'
        y = f'calc(var(--PT) + var(--S)*{FY[name]}px)'
        off = f'calc(50% - var(--S)*196px - var(--W)*.06)'
        fl += f'<div class="float" style="top:{y};{side}:{off}"><span style="font-size:calc(var(--W)*.055)">{e}</span><div>{t}<small>{s_}</small></div></div>'
    return f"""<!doctype html><html><head><meta charset="utf-8"><style>:root{{--W:{W}px;--H:{H}px;--S:{scale};--PT:{pt}px;--BR:{br}px}}{CSS}{CSS2}</style></head><body>
    <div class="pattern"></div><div class="cone" style="left:0;--a:100deg"></div><div class="cone" style="right:0;--a:260deg"></div>
    <div class="head"><img class="logo" src="file:///{LOGO}"><div class="en">{EN[name]}</div><div class="ar">{AR[name]}</div></div>
    <div class="ring"></div>
    <div class="stage"><div class="phone"><div class="scr"><div class="island"></div>{scr_html}</div></div></div>{fl}
    <div class="cta">{CTA[name]}</div>
    <div class="chips"><span>✓ ذبح حلال معتمد</span><span>❄️ توصيل مبرد</span><span>🛡️ ضمان الجودة</span></div></body></html>"""

def render(html, W, H, out):
    tmp = pathlib.Path(tempfile.gettempdir())
    f = tmp / 'shot.html'; f.write_text(html, encoding='utf-8')
    raw = tmp / 'shot_raw.png'
    if raw.exists(): raw.unlink()
    subprocess.run([CHROME, '--headless=new', '--no-sandbox', '--disable-gpu', '--hide-scrollbars',
                    f'--user-data-dir={tmp/"chr_prof"}', '--allow-file-access-from-files',
                    f'--screenshot={raw}', f'--window-size={W},{H}', '--virtual-time-budget=4000',
                    f.as_uri()], check=True, timeout=90)
    im = Image.open(raw).convert('RGB')
    if im.size != (W, H):
        im = im.crop((0, 0, W, H))
    im.save(out, 'PNG')
    print('saved', out, im.size)

if __name__ == '__main__':
    for d in (OUT_IOS, OUT_AND):
        for p in d.glob('*.png'): p.unlink()
    for name, fn, badge, title, sub, floats in SCREENS:
        ui = fn()
        render(page(1290, 2796, ui, badge, title, sub, floats, name), 1290, 2796, OUT_IOS / f'{name}_1290x2796.png')
        render(page(1080, 1920, ui, badge, title, sub, floats, name), 1080, 1920, OUT_AND / f'{name}_1080x1920.png')

