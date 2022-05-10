# -*- coding: utf-8 -*-
import sys
import codecs
import numpy
import csv
import random
import xlsxwriter

def main(args):
    src_file,trg_file, mt_file, comet_out, csv_out = args
    trg = codecs.open(trg_file, 'r', 'utf-8')
    src = codecs.open(src_file, 'r', 'utf-8')
    mt = codecs.open(mt_file, 'r', 'utf-8')
    comet = codecs.open(comet_out, 'r', 'utf-8')
    
    csv_txt = codecs.open(csv_out + '.txt.csv', 'w', 'utf-8')
    writer_txt = csv.writer(csv_txt) 
    csv_score = codecs.open(csv_out + '.score.csv', 'w', 'utf-8')
    writer_score = csv.writer(csv_score)
    workbook = xlsxwriter.Workbook(csv_out + '.xlsx')
    worksheet = workbook.add_worksheet()

    
    id_line = []
    comet_scores = []
    out_dict = dict()

    for score_line in comet:
        score_line =  score_line.strip()
        cols = score_line.split('\t')
        if len(cols) >= 3:
            _, x = cols[1].split(' ')
            id_line.append(int(x))
            _, comet_score = cols[2].split(' ') 
            comet_scores.append(float(comet_score))
    
    #sort_index = numpy.argsort(comet_scores)

    merge_lines = dict()

    for line_scr, line_trg, line_mt, score, idx in zip(src, trg, mt, comet_scores, id_line):
        line_scr = line_scr.strip()
        line_trg = line_trg.strip()
        line_mt = line_mt.strip()
        merge_lines[idx] = [line_scr, line_trg, line_mt, score]

    output_lines = []
    #writer_txt.writerow(['segment', 'src', 'trg', 'mt'])
    #writer_score.writerow(['segment', 'score'])
    row = 0
    #column = 0
    for key in merge_lines.keys():
        (line_scr, line_trg, line_mt, score) = merge_lines[key]
        writer_txt.writerow([key, line_scr, line_trg, line_mt])
        writer_score.writerow([key, score])
        worksheet.write(row, 0, line_scr)
        worksheet.write(row, 1, line_trg)
        worksheet.write(row, 2, line_mt)
        row += 1


    csv_txt.close()
    csv_score.close()
    workbook.close()
    
    return

if __name__ == '__main__':
    if len(sys.argv) != 6:
        print('usage: python output_doc_segment.py <src> <trg> <mt> <comet> <csv-output>')
    else:
        main(sys.argv[1:])

#example
#python output_seg.py ../en-ro_abstracts_clean/en-ro.abstracts.en ../en-ro_abstracts_clean/en-ro.abstracts.ro ../en-ro_abstracts_clean/en-ro.test.sys.hyp ../en-ro_abstracts_clean/abstracts_comet.log 10 transformerbase_comet_eval
