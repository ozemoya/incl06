"""Temporarily move the hat below the face; restore after the emulator capture."""
from pathlib import Path
import shutil, sys

root = Path(__file__).resolve().parents[1]
source = root / 'lib/main.dart'
backup = root / 'evidence/main_before_paint_probe.dart'
mode = sys.argv[1]
if mode == 'restore':
    shutil.copyfile(backup, source)
    print('Restored original painter')
elif mode == 'move':
    shutil.copyfile(source, backup)
    code = source.read_text(encoding='utf8')
    start = code.index('    if (config.hat) {', code.index('class SmileyPainter'))
    brace = code.index('{', start)
    depth = 0
    end = None
    for i in range(brace, len(code)):
        if code[i] == '{': depth += 1
        elif code[i] == '}':
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    assert end is not None
    block = code[start:end]
    code = code[:start] + code[end:]
    face = code.index('    canvas.drawCircle(center, radius, Paint()..color = config.faceColor);')
    code = code[:face] + block + '\n' + code[face:]
    source.write_text(code, encoding='utf8')
    print('Moved hat draw calls before face fill for temporary device probe')
else:
    raise SystemExit('Use move or restore')
