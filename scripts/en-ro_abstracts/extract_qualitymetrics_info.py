# -*- coding: utf-8 -*-
from csv import reader
import sys
import codecs
from collections import defaultdict
import json


def main(args):
    (csv_file, csv_info_file, output_file, n_seg) = args
    doc_ids = {'abstracts_mbart_finetuned_comet_eval_sdl.xlsx.sdlxliff':'mbartft',
            'abstracts_source-reference.xlsx.sdlxliff':'ref',
            'abstracts_mbart_comet_eval_sdl.xlsx.sdlxliff':'mbart'}

    csv_info = codecs.open(csv_info_file, 'r', 'utf-8')
    csv_info_reader = reader(csv_info, delimiter = "\t") 
    csv_info_header = next(csv_info_reader)
    n = int(n_seg)
    
    info_dict = defaultdict(dict) #defaultdict(lambda: defaultdict(tup))

    for row in csv_info_reader:
        doc_id = row[3]
        segment = row[5]
        src = row[16]
        trg = row[17]
        num_word = int(row[23])
        if doc_id in doc_ids:
            idx = doc_ids[doc_id]
            info_dict[idx][segment] = (src, trg, num_word)

    #print(info_dict)
    csv_lines = codecs.open(csv_file, 'r', 'utf-8')
    csv_reader = reader(csv_lines, delimiter = "\t")
    csv_header = next(csv_reader)
        
    #qm = {'mbartft': defaultdict(list),
    #        'ref': defaultdict(list),
    #        'mbart': defaultdict(list)}
    qm = defaultdict(lambda: defaultdict(list)) 
    for row in csv_reader:
        
        doc_id = row[3]
        if doc_id in doc_ids:
            idx = doc_ids[doc_id]
            segment_id = row[6]
            qm_name = row[9]
            qm_sev = row[11]
            qm_w = int(row[12])
            qm_content = row[13]
            qm_comment = row[14]
            # name, severity, weigth, content, comment
            if idx in info_dict or segment_id in info_dict:
                (src, trg, num_word) = info_dict[idx][segment_id]
            else:
                src = trg =  num_word = ''

            if segment_id in info_dict['ref']:
                (_, ref, _) = info_dict['ref'][segment_id]
            else:
                ref = ''
            #print(idx, segment_id)
            qm[idx][segment_id].append((qm_name, qm_sev, qm_w, qm_content, qm_comment, src, ref, trg, num_word))
        #print(qm)

    with codecs.open(output_file, "w", 'utf_8') as outfile:
        json.dump(qm, outfile)

    with codecs.open('src_mqm.txt', "w", 'utf_8') as txtfile:
        for i in range(1, n+1):
            seg = str(i)
            if seg in info_dict['ref']:
                info = info_dict['ref'][seg]
                src_out = info[0]
            elif seg in info_dict['mbart']:
                info = info_dict['mbart'][seg]
                src_out = info[0]
            elif seg in info_dict['mbartft']:
                info = info_dict['mbartft'][seg]
                src_out = info[0]
            else:
                src_out = seg
            print(src_out, file=txtfile)

if __name__ == '__main__':
    if len(sys.argv) != 5:
        print('python extract_qualitymetric.py <csv-file> <csv-info> <output-file> <num-seg>')
    else:
        main(sys.argv[1:])

#python extract_qualitymetrics.py qualitativity/2022-05-12_export.csv qualitativity/2022-05-12_export.extract.json
