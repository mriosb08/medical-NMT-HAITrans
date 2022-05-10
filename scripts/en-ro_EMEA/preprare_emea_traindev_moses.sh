#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh

#mosesdecoder=/path/to/mosesdecoder

#sacremoeses preprocessing
# normalize, tokenize, and trucase
# todo normalize RO 
DATA=data_moses
CLEAN=/home/mrios/workspace/mosesdecoder/scripts/training/clean-corpus-n.perl

echo 'sacremoses normalize, tokenize, truecase'
cat $DATA/en-ro.emea.en | sacremoses -l en -j 12 \
    normalize -c tokenize -a truecase -m $DATA/en-ro.emea.en.truemodel \
    > $DATA/en-ro.emea.en.norm.tok.true

cat $DATA/en-ro.emea.ro | sacremoses -l ro -j 12 \
    normalize -c tokenize -a truecase -m $DATA/en-ro.emea.ro.truemodel \
    > $DATA/en-ro.emea.ro.norm.tok.true

#split train and dev

echo 'split train dev'

awk '{if (NR%100 == 0)  print $0; }' $DATA/en-ro.emea.en.norm.tok.true > $DATA/en-ro.emea.norm.tok.true.valid.en
awk '{if (NR%100 != 0)  print $0; }' $DATA/en-ro.emea.en.norm.tok.true > $DATA/en-ro.emea.norm.tok.true.train.en

awk '{if (NR%100 == 0)  print $0; }' $DATA/en-ro.emea.ro.norm.tok.true > $DATA/en-ro.emea.norm.tok.true.valid.ro
awk '{if (NR%100 != 0)  print $0; }' $DATA/en-ro.emea.ro.norm.tok.true > $DATA/en-ro.emea.norm.tok.true.train.ro


#TODO
perl $CLEAN -ratio 1.5 $DATA/en-ro.emea.norm.tok.true.train en ro $DATA/en-ro.emea.norm.tok.true.clean.train 1 250
perl $CLEAN -ratio 1.5 $DATA/en-ro.emea.norm.tok.true.valid en ro $DATA/en-ro.emea.norm.tok.true.clean.valid 1 250





