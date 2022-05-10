#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh

#mosesdecoder=/path/to/mosesdecoder

#sacremoeses preprocessing
# normalize, tokenize, and trucase
# todo normalize RO 
DATA=data
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

awk '{if (NR%100 == 0)  print $0; }' $DATA/en-ro.emea.en.norm.tok.true > $DATA/en-ro.emea.en.norm.tok.true.valid
awk '{if (NR%100 != 0)  print $0; }' $DATA/en-ro.emea.en.norm.tok.true > $DATA/en-ro.emea.en.norm.tok.true.train

awk '{if (NR%100 == 0)  print $0; }' $DATA/en-ro.emea.ro.norm.tok.true > $DATA/en-ro.emea.ro.norm.tok.true.valid
awk '{if (NR%100 != 0)  print $0; }' $DATA/en-ro.emea.ro.norm.tok.true > $DATA/en-ro.emea.ro.norm.tok.true.train


#train BPE with sentence piece
echo 'train bpe'
#train
python /home/mrios/workspace/subword-nmt/learn_bpe.py -s 16000 < $DATA/en-ro.emea.en.norm.tok.true.train  > $DATA/en-ro.en.bpe
python /home/mrios/workspace/subword-nmt/learn_bpe.py -s 16000 < $DATA/en-ro.emea.ro.norm.tok.true.train  > $DATA/en-ro.ro.bpe

echo 'appply bpe'
 
python /home/mrios/workspace/subword-nmt/apply_bpe.py -c $DATA/en-ro.en.bpe < $DATA/en-ro.emea.en.norm.tok.true.train > $DATA/en-ro.emea.norm.tok.true.train.bpe.en
python /home/mrios/workspace/subword-nmt/apply_bpe.py -c $DATA/en-ro.ro.bpe < $DATA/en-ro.emea.ro.norm.tok.true.train > $DATA/en-ro.emea.norm.tok.true.train.bpe.ro

python /home/mrios/workspace/subword-nmt/apply_bpe.py -c $DATA/en-ro.en.bpe < $DATA/en-ro.emea.en.norm.tok.true.valid > $DATA/en-ro.emea.norm.tok.true.valid.bpe.en
python /home/mrios/workspace/subword-nmt/apply_bpe.py -c $DATA/en-ro.ro.bpe < $DATA/en-ro.emea.ro.norm.tok.true.valid > $DATA/en-ro.emea.norm.tok.true.valid.bpe.ro

#clean corpus
#TODO
perl $CLEAN -ratio 1.5 $DATA/en-ro.emea.norm.tok.true.train.bpe en ro $DATA/en-ro.emea.norm.tok.true.clean.train.bpe 1 250
perl $CLEAN -ratio 1.5 $DATA/en-ro.emea.norm.tok.true.valid.bpe en ro $DATA/en-ro.emea.norm.tok.true.clean.valid.bpe 1 250
echo 'preprocess fairseq'

#prepare input for fairseq
fairseq-preprocess --source-lang en --target-lang ro \
    --trainpref $DATA/en-ro.emea.norm.tok.true.clean.train.bpe --validpref $DATA/en-ro.emea.norm.tok.true.clean.valid.bpe \
    --destdir $DATA/emea.tokenized.en-ro \
    --workers 12


