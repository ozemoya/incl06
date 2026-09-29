"""Read and exercise the real Android emulator UI for Activity 06."""
from pathlib import Path
import os, re, subprocess, time, xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
ADB = Path(os.environ['LOCALAPPDATA']) / 'Android/Sdk/platform-tools/adb.exe'
IMG = ROOT / 'docs' / 'images'
IMG.mkdir(parents=True, exist_ok=True)

def adb(*args):
    return subprocess.check_output([str(ADB), *map(str, args)], text=True,
                                   encoding='utf8', errors='replace').strip()

def tree():
    for _ in range(4):
        if 'dumped' in adb('shell', 'uiautomator', 'dump', '/sdcard/window.xml'):
            return ET.fromstring(adb('shell', 'cat', '/sdcard/window.xml'))
        time.sleep(1)
    raise RuntimeError('No Android accessibility tree')

def nodes():
    return list(tree().iter('node'))

def bounds(node):
    return list(map(int, re.findall(r'\d+', node.attrib['bounds'])))

def find(label):
    found = [n for n in nodes() if n.get('content-desc', '') == label or
             n.get('text', '') == label]
    if not found:
        raise AssertionError(f'Missing {label}. Visible: '
                             + str([n.get('content-desc') for n in nodes()]))
    return found[0]

def tap(label):
    x1, y1, x2, y2 = bounds(find(label))
    adb('shell', 'input', 'tap', (x1+x2)//2, (y1+y2)//2)
    time.sleep(.35)

def longpress(label):
    x1, y1, x2, y2 = bounds(find(label))
    x, y = (x1+x2)//2, (y1+y2)//2
    adb('shell', 'input', 'swipe', x, y, x, y, 1100)
    time.sleep(.4)

def scroll_down():
    adb('shell', 'input', 'swipe', 700, 2550, 700, 900, 400)
    time.sleep(.4)

def shot(name):
    adb('shell', 'screencap', '-p', '/sdcard/smiley-capture.png')
    adb('pull', '/sdcard/smiley-capture.png', IMG / f'{name}.png')

def descs():
    return [n.get('content-desc', '') for n in nodes()]

def face():
    return next(s for s in descs() if ' face, ' in s and 'Tap to change face' in s)

def slide_mood(fraction):
    root = tree()
    parents = {child: parent for parent in root.iter() for child in parent}
    items = [n for n in root.iter('node') if n.get('class') == 'android.widget.SeekBar']
    if not items:
        scroll_down()
        root = tree()
        parents = {child: parent for parent in root.iter() for child in parent}
        items = [n for n in root.iter('node') if n.get('class') == 'android.widget.SeekBar']
    assert items, 'Mood slider is not visible'
    mood = next((s for s in [n.get('content-desc', '') for n in root.iter('node')]
                 if 'Mood • ' in s), '')
    match = re.search(r'Mood • \w+ \((\d+\.\d+)\)', mood)
    percent = round(float(match[1]) * 100) if match else 82
    slider = min(items, key=lambda n: abs(int(re.search(r'\d+', n.get('content-desc', '0'))[0]) - percent))
    x1, y1, x2, y2 = bounds(slider)
    px1, _, px2, _ = bounds(parents[slider])
    y = (y1+y2)//2
    left = px1 + (px2-px1)*.13
    right = px2 - (px2-px1)*.13
    adb('shell', 'input', 'swipe', (x1+x2)//2, y,
        int(left+(right-left)*fraction), y, 700)
    time.sleep(.5)

def rotate(value):
    adb('shell', 'settings', 'put', 'system', 'accelerometer_rotation', '0')
    adb('shell', 'settings', 'put', 'system', 'user_rotation', value)
    time.sleep(2)
