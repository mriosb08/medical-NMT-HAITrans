# -*- coding: utf-8 -*-
import sys
import os
import codecs
# Import BeautifulSoup
from bs4 import BeautifulSoup as bs
content = []
# Read the XML file

def main(args):
    src, trg, xml_file, output = args
    src_out = codecs.open('%s.%s'%(output, src), "w", "utf-8")
    trg_out = codecs.open('%s.%s'%(output, trg), "w", "utf-8")
    with open(xml_file, "r") as f:
        content = f.readlines()
        content = "".join(content)
        bs_content = bs(content, "lxml")
        txt = bs_content.find_all('tuv')
        for tuv in txt:
            #print(tuv.attrs)
            l = tuv.attrs['xml:lang']
            if l == src:
                src_seg = tuv.seg.text
                print(src_seg, file=src_out)
            elif l == trg:
                trg_seg = tuv.seg.text
                print(trg_seg, file=trg_out)
    return


if __name__ == '__main__':
    if len(sys.argv) != 5:
        print('usage: python xml2txt <source> <target> <xml-file> <output-file>')
        sys.exit()
    else:
        main(sys.argv[1:])
