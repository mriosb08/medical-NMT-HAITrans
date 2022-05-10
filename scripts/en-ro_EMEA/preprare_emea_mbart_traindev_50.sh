#!/bin/bash

SPM=spm_encode
MODEL=/home/mrios/workspace/mbart50/sentence.bpe.model
DATA=data
CLEAN=/home/mrios/workspace/mosesdecoder/scripts/training/clean-corpus-n.perl

echo 'apply sentence piece'

${SPM} --model=${MODEL} < $DATA/en-ro.emea.en.train > $DATA/en-ro.emea.train.spm.50.en_XX 
${SPM} --model=${MODEL} < $DATA/en-ro.emea.ro.train > $DATA/en-ro.emea.train.spm.50.ro_RO
${SPM} --model=${MODEL} < $DATA/en-ro.emea.en.valid > $DATA/en-ro.emea.valid.spm.50.en_XX 
${SPM} --model=${MODEL} < $DATA/en-ro.emea.ro.valid > $DATA/en-ro.emea.valid.spm.50.ro_RO

echo 'clean corpus'
perl $CLEAN -ratio 1.5 $DATA/en-ro.emea.train.spm.50 en_XX ro_RO $DATA/en-ro.emea.train.clean.mbart.spm.50 1 250
perl $CLEAN -ratio 1.5 $DATA/en-ro.emea.valid.spm.50 en_XX ro_RO $DATA/en-ro.emea.valid.clean.mbart.spm.50 1 250

DICT=/home/mrios/workspace/mbart50/dict_250k.txt

echo 'preprocess for fairseq'

fairseq-preprocess \
  --source-lang en_XX \
  --target-lang ro_RO \
  --trainpref $DATA/en-ro.emea.train.clean.mbart.spm.50 \
  --validpref $DATA/en-ro.emea.valid.clean.mbart.spm.50 \
  --destdir $DATA/emea.mbart50.spm.en-ro \
  --thresholdtgt 0 \
  --thresholdsrc 0 \
  --srcdict $DICT \
  --tgtdict $DICT \
  --workers 12
