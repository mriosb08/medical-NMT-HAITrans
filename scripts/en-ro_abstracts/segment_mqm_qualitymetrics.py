# -*- coding: utf-8 -*-
from csv import reader
import sys
import codecs
from collections import defaultdict
import json
from sacremoses import MosesTokenizer

#def qm_extract(doc_id, row):
#    segment_id = row[6]
#    qm_name = row[9]
#    qm_content = row[13]
#    qm_comment = row[14]

#    return(qm)

def main(args):
    #(csv_file, output_file) = args
    json_file, total, tok, trg_l = args
    total = int(total)
    sev_score = {'Minor': 1, 'Major': 5, 'Critical':10}
    if tok == 'moses':
        mt = MosesTokenizer(lang=trg_l)

    with codecs.open(json_file, 'r', 'utf-8') as json_lines:
        qm = json.load(json_lines) 
        
        err_sev = defaultdict(lambda: defaultdict(int))
        for doc in qm.keys():
            #print('MT-', doc)
            if doc == 'ref':
                continue
            for s in range(1, total+1):
                err_type = defaultdict(lambda: defaultdict(int))
                segment = str(s)
                if segment in qm[doc]:
                    errors = qm[doc][segment]
                    words = 0
                
                    for error in errors:
                        #print(error)
                        (qm_name, qm_sev, qm_w, qm_content, qm_comment, src, ref, trg, num_word) = error
                        if tok == 'mqm':
                            words = num_word
                        elif tok == 'moses':
                            #print(mt.tokenize(src, return_str=))
                            words = len(mt.tokenize(trg))
                        #print(doc, segment, qm_w, words)
                        if qm_sev != 'Bonus' or qm_name != 'Kudos':
                            err_sev[doc][segment] += qm_w 
                            err_type[qm_name][qm_sev] += 1
            
                    
                    err_sev[doc][segment] = 100.0 * (1.0 - (float(err_sev[doc][segment] / words)))

                    #print(err_type)
                    for name in err_type.keys():
                        #print(name)
                        for sev in err_type[name].keys():
                            print('{}\t'.format(doc), 'E-{}\t'.format(segment), name, sev, sev_score[sev], err_type[name][sev], words)
                    print('{}\t'.format(doc), 'S-{}\t'.format(segment), '{}\t'.format(src), '{}\t'.format(ref), '{}\t'.format(trg), '{:0.3f}'.format(err_sev[doc][segment]))
                else:
                    err_sev[doc][segment] = 100.0
                    print('{}\t'.format(doc), 'S-{}\t'.format(segment), '{}\t'.format('|||'), '{}\t'.format('|||'), '{}\t'.format('|||'), '{:0.3f}'.format(err_sev[doc][segment]))
        
        mqm_score = 0



if __name__ == '__main__':
    if len(sys.argv) != 5:
        print('python extract_qualitymetric.py <json-file> <totalnum-seg> <tokenizer> <trg>')
    else:
        main(sys.argv[1:])

#python segment_mqm_qualitymetrics.py qualitativity/2022-05-12_export.extractinfo.json 12 | grep 'S-'
#python segment_mqm_qualitymetrics.py qualitativity/2022-07-26_export_qainfo.json 75 moses ro | grep 'S-' | cut -f 1,6
