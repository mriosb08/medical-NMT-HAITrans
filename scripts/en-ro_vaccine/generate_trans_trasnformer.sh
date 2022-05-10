#!/bin/bash

SPM_MODEL=/home/mrios/workspace/en-ro_medcorpora/EMEA/data
MODEL=/home/mrios/workspace/en-ro_medcorpora/EMEA/models/transformer_spm_base
DATA=/home/mrios/workspace/en-ro_medcorpora/en-ro_european_vaccination_portal
TRAIN=/home/mrios/workspace/en-ro_medcorpora/EMEA/data

echo 'prepare src test'

spm_encode --model=$SPM_MODEL/en-ro.en.spm.model < $DATA/en-ro.vaccine.en > $DATA/en-ro.vaccine.spm.en

echo 'translate src test'

cat $DATA/en-ro.vaccine.spm.en \
    | CUDA_VISIBLE_DEVICES=0 fairseq-interactive $TRAIN/emea.spm.en-ro \
      --task translation \
      --source-lang en --target-lang ro \
      --path $MODEL/checkpoint_best.pt \
      --batch-size 32 --buffer-size 64\
      --beam 5 --remove-bpe=sentencepiece \
    > $DATA/en-ro.test.sys


echo 'sort sentences'

grep ^H $DATA/en-ro.test.sys | cut -f3 > $DATA/en-ro.test.sys.hyp
