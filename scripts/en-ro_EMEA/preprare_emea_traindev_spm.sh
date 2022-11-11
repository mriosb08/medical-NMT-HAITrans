#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh

#mosesdecoder=/path/to/mosesdecoder

DATA=data
CLEAN=/home/mrios/workspace/mosesdecoder/scripts/training/clean-corpus-n.perl




#train BPE with sentence piece
echo 'train sentence piece'
spm_train \
    --input=$DATA/en-ro.emea.en.train \
    --model_prefix=$DATA/en-ro.en.spm \
    --vocab_size=16000 \
    --character_coverage=1.0 \
    --model_type=unigram

spm_train \
    --input=$DATA/en-ro.emea.ro.train \
    --model_prefix=$DATA/en-ro.ro.spm \
    --vocab_size=16000 \
    --character_coverage=1.0 \
    --model_type=unigram


#apply sentence piece BPE
echo 'apply sentence piece'
#train
spm_encode \
        --model $DATA/en-ro.en.spm.model \
        --output_format=piece \
        < $DATA/en-ro.emea.en.train \
        > $DATA/en-ro.emea.train.spm.en \

spm_encode \
        --model $DATA/en-ro.ro.spm.model \
        --output_format=piece \
        < $DATA/en-ro.emea.ro.train \
        > $DATA/en-ro.emea.train.spm.ro \

#dev
spm_encode \
        --model $DATA/en-ro.en.spm.model \
        --output_format=piece \
        <  $DATA/en-ro.emea.en.valid \
        > $DATA/en-ro.emea.valid.spm.en \

spm_encode \
        --model $DATA/en-ro.ro.spm.model \
        --output_format=piece \
        <  $DATA/en-ro.emea.ro.valid \
        > $DATA/en-ro.emea.valid.spm.ro \



#clean corpus
#TODO
#perl $CLEAN -ratio 1.5 $tmp/bpe.train en ro $prep/train 1 250
echo 'preprocess fairseq'
perl $CLEAN -ratio 1.5 $DATA/en-ro.emea.train.spm en ro $DATA/en-ro.emea.clean.train.spm 1 250
perl $CLEAN -ratio 1.5 $DATA/en-ro.emea.valid.spm en ro $DATA/en-ro.emea.clean.valid.spm 1 250

#prepare input for fairseq
fairseq-preprocess --source-lang en --target-lang ro \
    --trainpref $DATA/en-ro.emea.clean.train.spm --validpref $DATA/en-ro.emea.clean.valid.spm \
    --destdir $DATA/emea.spm.en-ro \
    --thresholdtgt 0 \
    --thresholdsrc 0 \
    --workers 12 \
    --bpe sentencepiece


