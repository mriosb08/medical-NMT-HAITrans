#!/bin/bash

model_dir=/home/miguel/workspace/mbart.cc25.ft.enro/MBART_finetuned_enro # fix if you moved the checkpoint
ft=/mnt/disks/workspace1/en-ro_medcorpora/EMEA/models/mbartwmt_finetuned_bleu_emea3/checkpoint_best.pt
langs=ar_AR,cs_CZ,de_DE,en_XX,es_XX,et_EE,fi_FI,fr_XX,gu_IN,hi_IN,it_IT,ja_XX,kk_KZ,ko_KR,lt_LT,lv_LV,my_MM,ne_NP,nl_XX,ro_RO,ru_RU,si_LK,tr_TR,vi_VN,zh_CN
DATA=data

CUDA_VISIBLE_DEVICES=0 fairseq-generate  $DATA/emea.spm.en-ro\
  --path $ft \
  --task translation_from_pretrained_bart --beam 5 \
  --gen-subset valid \
  -t ro_RO -s en_XX \
  --bpe 'sentencepiece' --sentencepiece-model $model_dir/sentence.bpe.model \
  --batch-size 16 --langs $langs > $DATA/en-ro.valid.sys

echo 'sort sentences'
grep ^S $DATA/en-ro.valid.sys | LC_ALL=C sort -V | cut -f2- | sed 's/\[en_XX\]//g' > $DATA/en-ro.valid.sys.src
grep ^T $DATA/en-ro.valid.sys | LC_ALL=C sort -V | cut -f2- > $DATA/en-ro.valid.sys.ref
grep ^H $DATA/en-ro.valid.sys | LC_ALL=C sort -V | cut -f3- > $DATA/en-ro.valid.sys.piece.hyp

spm_decode --model=$model_dir/sentence.bpe.model --input_format=piece < $DATA/en-ro.valid.sys.piece.hyp > $DATA/en-ro.valid.sys.hyp
