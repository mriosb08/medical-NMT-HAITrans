#!/bin/bash

SPM_MODEL=/home/mrios/workspace/en-ro_medcorpora/EMEA/data
model_dir=/home/miguel/workspace/mbart.cc25.ft.enro/MBART_finetuned_enro # fix if you moved the checkpoint
langs=ar_AR,cs_CZ,de_DE,en_XX,es_XX,et_EE,fi_FI,fr_XX,gu_IN,hi_IN,it_IT,ja_XX,kk_KZ,ko_KR,lt_LT,lv_LV,my_MM,ne_NP,nl_XX,ro_RO,ru_RU,si_LK,tr_TR,vi_VN,zh_CN
DATA=/home/mrios/workspace/en-ro_medcorpora/en-ro_abstracts_clean

spm_encode --model=$SPM_MODEL/en-ro.en.spm.model < $DATA/en-ro.abstracts.en > $DATA/en-ro.abstracts.spm.en

cat $DATA/en-ro.abstracts.spm.en \
    | CUDA_VISIBLE_DEVICES=0 fairseq-interactive  $model_dir \
  --path $model_dir/model.pt \
  --task translation_from_pretrained_bart --beam 5 \
  -t ro_RO -s en_XX \
  --remove-bpe=sentencepiece \
  --batch-size 32 --buffer-size 64 \
  --batch-size 16 --langs $langs > $DATA/en-ro.test.mbart.sys


grep ^H $DATA/en-ro.test.mbart.sys | cut -f3 > $DATA/en-ro.test.mbart.sys.hyp



