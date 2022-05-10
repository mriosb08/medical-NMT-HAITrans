#!/bin/bash

SPM=spm_encode
MODEL=/home/miguel/workspace/mbart.cc25.ft.enro/MBART_finetuned_enro/sentence.bpe.model
DATA=data
echo 'apply sentence piece'

${SPM} --model=${MODEL} < $DATA/en-ro.emea.norm.tok.true.en.train > $DATA/en-ro.emea.norm.tok.true.train.spm.en 
${SPM} --model=${MODEL} < $DATA/en-ro.emea.norm.tok.true.ro.train > $DATA/en-ro.emea.norm.tok.true.train.spm.ro
${SPM} --model=${MODEL} < $DATA/en-ro.emea.norm.tok.true.en.valid > $DATA/en-ro.emea.norm.tok.true.valid.spm.en 
${SPM} --model=${MODEL} < $DATA/en-ro.emea.norm.tok.true.ro.valid > $DATA/en-ro.emea.norm.tok.true.valid.spm.ro

DICT=/home/miguel/workspace/mbart.cc25.ft.enro/MBART_finetuned_enro/dict.txt

echo 'preprocess for fairseq'

fairseq-preprocess \
  --source-lang en \
  --target-lang ro \
  --trainpref $DATA/en-ro.emea.norm.tok.true.train.spm \
  --validpref $DATA/en-ro.emea.norm.tok.true.valid.spm \
  --destdir $DATA/emea.spm.en-ro \
  --thresholdtgt 0 \
  --thresholdsrc 0 \
  --srcdict ${DICT} \
  --tgtdict ${DICT} \
  --workers 12
