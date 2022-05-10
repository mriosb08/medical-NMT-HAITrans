#!/bin/bash

SPM_MODEL=/home/mrios/workspace/en-ro_paracrawl/data
MODEL=/home/mrios/workspace/en-ro_paracrawl/models/transformer_spm_base

DATA=/home/mrios/workspace/en-ro_medcorpora/en-ro_abstracts_clean
TRAIN=/home/mrios/workspace/en-ro_paracrawl/data

echo 'prepare src test'

spm_encode --model=$SPM_MODEL/en-ro.spm.model < $DATA/en-ro.abstracts.en > $DATA/en-ro.abstracts.spm.en

echo 'translate src test'

cat $DATA/en-ro.abstracts.spm.en \
    | CUDA_VISIBLE_DEVICES=0 fairseq-interactive $TRAIN/para.spm.en-ro \
      --task translation \
      --source-lang en --target-lang ro \
      --path $MODEL/checkpoint_best.pt \
      --batch-size 32 --buffer-size 64\
      --beam 5 --remove-bpe=sentencepiece \
    > $DATA/en-ro.test.para.sys


echo 'sort sentences'

grep ^H $DATA/en-ro.test.para.sys | cut -f3 > $DATA/en-ro.test.para.sys.hyp
