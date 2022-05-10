#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh

#mosesdecoder=/path/to/mosesdecoder

#sacremoeses preprocessing
# normalize, tokenize, and trucase
# todo normalize RO 
DATA=data

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
echo 'train sentence piece'
spm_train \
    --input=$DATA/en-ro.emea.en.norm.tok.true.train \
    --model_prefix=$DATA/en-ro.en.bpe \
    --vocab_size=16000 \
    --character_coverage=1.0 \
    --model_type=bpe

spm_train \
    --input=$DATA/en-ro.emea.ro.norm.tok.true.train \
    --model_prefix=$DATA/en-ro.ro.bpe \
    --vocab_size=16000 \
    --character_coverage=1.0 \
    --model_type=bpe


#apply sentence piece BPE
echo 'apply sentence piece'
#train
spm_encode \
        --model $DATA/en-ro.en.bpe.model \
        --output_format=piece \
        < $DATA/en-ro.emea.en.norm.tok.true.train \
        > $DATA/en-ro.emea.norm.tok.true.train.spm.en \

spm_encode \
        --model $DATA/en-ro.ro.bpe.model \
        --output_format=piece \
        < $DATA/en-ro.emea.ro.norm.tok.true.train \
        > $DATA/en-ro.emea.norm.tok.true.train.spm.ro \

#dev
spm_encode \
        --model $DATA/en-ro.en.bpe.model \
        --output_format=piece \
        <  $DATA/en-ro.emea.en.norm.tok.true.valid \
        > $DATA/en-ro.emea.norm.tok.true.valid.spm.en \

spm_encode \
        --model $DATA/en-ro.ro.bpe.model \
        --output_format=piece \
        <  $DATA/en-ro.emea.ro.norm.tok.true.valid \
        > $DATA/en-ro.emea.norm.tok.true.valid.spm.ro \



#clean corpus
#TODO
#perl $CLEAN -ratio 1.5 $tmp/bpe.train en ro $prep/train 1 250
echo 'preprocess fairseq'

#prepare input for fairseq
fairseq-preprocess --source-lang en --target-lang ro \
    --trainpref $DATA/en-ro.emea.norm.tok.true.train.spm --validpref $DATA/en-ro.emea.norm.tok.true.valid.spm \
    --destdir $DATA/emea.tokenized.spm.en-ro \
    --thresholdtgt 0 \
    --thresholdsrc 0 \
    --workers 12 \
    --bpe sentencepiece


