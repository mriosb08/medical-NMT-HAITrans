#!/bin/bash

SPM_MODEL=/home/mrios/workspace/en-ro_medcorpora/EMEA/data
MODEL=/home/mrios/workspace/en-ro_medcorpora/EMEA/models/transformer_spm_base
DATA=/home/mrios/workspace/en-ro_medcorpora/en-ro_abstracts_clean

echo 'prepare src test'

spm_encode --model=$SPM_MODEL/en-ro.en.spm.model < $DATA/en-ro.abstracts.en > $DATA/en-ro.abstracts.spm.en

echo 'translate src test'

cat $DATA/en-ro.abstracts.spm.en \
    | fairseq-interactive \
      --task translation \
      --source-lang en --target-lang ro \
      --path $MODEL/checkpoint_best.pt \
      --batch-size 32 \
      --beam 5 --remove-bpe=sentencepiece \
    > $DATA/en-ro.test.sys


echo 'sort sentences'
grep ^S $DATA/en-ro.test.sys | LC_ALL=C sort -V | cut -f2- | sed 's/\[en\]//g' > $DATA/en-ro.test.sys.src
grep ^T $DATA/en-ro.test.sys | LC_ALL=C sort -V | cut -f2- > $DATA/en-ro.test.sys.ref
grep ^H $DATA/en-ro.test.sys | LC_ALL=C sort -V | cut -f3- > $DATA/en-ro.test.sys.piece.hyp

spm_decode --model=$SPM_MODEL/en-ro.ro.spm.model --input_format=piece < $DATA/en-ro.test.sys.piece.hyp > $DATA/en-ro.test.sys.hyp
