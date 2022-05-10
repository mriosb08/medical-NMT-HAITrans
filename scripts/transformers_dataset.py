# -*- coding: utf-8 -*-
import sys
import json
import re
import codecs

def main(args):
    src_trg, src_file, trg_file, out_file = args
    src = codecs.open(src_file, 'r', encoding="utf-8")
    trg = codecs.open(trg_file, 'r', encoding="utf-8")
    out_json = codecs.open(out_file, 'w', encoding="utf-8")
    src_id, trg_id = src_trg.split('-')
    
    src_lines = []
    trg_lines = []
    for line_s, line_t in zip(src, trg):
        line_s = line_s.strip()
        line_t = line_t.strip()
        src_lines.append(line_s)
        trg_lines.append(line_t)
    recs = [src_lines, trg_lines]
    for src, tgt in zip(*recs):
        out = {"translation": { src_id: src, trg_id: tgt } }
        x = json.dumps(out, indent=0, ensure_ascii=False)
        x = re.sub(r'\n', ' ', x, 0, re.M)
        out_json.write(x + "\n")





if __name__ == '__main__':
    if len(sys.argv) != 5:
        print('usage: python trasnformer_dataset.py <src-trg> <source_file> <target_file> <json_dataset>')
    else:
        main(sys.argv[1:])
