#!/bin/bash

model_dir=/home/mrios/workspace/en-ro_paracrawl/models/mbartwmt_finetuned_bleu_emeapara1 # fix if you moved the checkpoint
langs=ar_AR,cs_CZ,de_DE,en_XX,es_XX,et_EE,fi_FI,fr_XX,gu_IN,hi_IN,it_IT,ja_XX,kk_KZ,ko_KR,lt_LT,lv_LV,my_MM,ne_NP,nl_XX,ro_RO,ru_RU,si_LK,tr_TR,vi_VN,zh_CN
DATA=/home/mrios/workspace/en-ro_medcorpora/en-ro_abstracts_clean
DICT=/home/mrios/workspace/MBART_finetuned_enro

spm_encode --model=$DICT/sentence.bpe.model < $DATA/en-ro.abstracts.en > $DATA/en-ro.abstracts.mbartft.spm.en_XX
spm_encode --model=$DICT/sentence.bpe.model < $DATA/en-ro.abstracts.ro > $DATA/en-ro.abstracts.mbartft.spm.ro_RO

fairseq-preprocess \
  --source-lang en_XX \
  --target-lang ro_RO \
  --testpref $DATA/en-ro.abstracts.mbartft.spm \
  --destdir $DATA/abs.mbartft.spm.en-ro \
  --thresholdtgt 0 \
  --thresholdsrc 0 \
  --srcdict $DICT/dict.txt \
  --tgtdict $DICT/dict.txt \
  --workers 12


CUDA_VISIBLE_DEVICES=0 fairseq-generate  $DATA/abs.mbartft.spm.en-ro\
  --path $model_dir/checkpoint_best.pt \
  --task translation_from_pretrained_bart --beam 5 \
  --gen-subset test \
  -t ro_RO -s en_XX \
  --bpe 'sentencepiece' --sentencepiece-model $DICT/sentence.bpe.model \
  --batch-size 32 --langs $langs > $DATA/en-ro.test.mbartft.emeapara.sys

echo 'sort sentences'
grep ^S $DATA/en-ro.test.mbartft.emeapara.sys | LC_ALL=C sort -V | cut -f2- | sed 's/\[en_XX\]//g' > $DATA/en-ro.test.mbartft.emeapara.sys.src
grep ^T $DATA/en-ro.test.mbartft.emeapara.sys | LC_ALL=C sort -V | cut -f2- > $DATA/en-ro.test.mbartft.emeapara.sys.ref
grep ^H $DATA/en-ro.test.mbartft.emeapara.sys | LC_ALL=C sort -V | cut -f3- > $DATA/en-ro.test.mbartft.emeapara.sys.piece.hyp

spm_decode --model=$DICT/sentence.bpe.model --input_format=piece < $DATA/en-ro.test.mbartft.emeapara.sys.piece.hyp > $DATA/en-ro.test.mbartft.emeapara.sys.hyp
