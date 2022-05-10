#!/bin/bash

#SPM=spm_encode
#MODEL=/home/mrios/workspace/MBART_finetuned_enro/sentence.bpe.model
DATA=data
OUTPUT=models/mbart_finetuned_bleu_emea2

PRETRAIN=/home/mrios/workspace/mbart.cc25.v2/model.pt # fix if you moved the downloaded checkpoint
langs=ar_AR,cs_CZ,de_DE,en_XX,es_XX,et_EE,fi_FI,fr_XX,gu_IN,hi_IN,it_IT,ja_XX,kk_KZ,ko_KR,lt_LT,lv_LV,my_MM,ne_NP,nl_XX,ro_RO,ru_RU,si_LK,tr_TR,vi_VN,zh_CN

fairseq-train $DATA/emea.mbart.spm.en-ro \
  --encoder-normalize-before --decoder-normalize-before \
  --arch mbart_large --layernorm-embedding \
  --task translation_from_pretrained_bart \
  --source-lang en_XX --target-lang ro_RO \
  --criterion label_smoothed_cross_entropy --label-smoothing 0.2 \
  --optimizer adam --adam-eps 1e-06 --adam-betas '(0.9, 0.98)' \
  --lr-scheduler inverse_sqrt --lr 3e-05 --warmup-updates 2500 --total-num-update 40000 --max-update 40000 \
  --dropout 0.3 --attention-dropout 0.1 --weight-decay 0.0 \
  --max-tokens 256 --update-freq 8 \
  --save-interval 1 --save-interval-updates 5000 --keep-interval-updates 1 --no-epoch-checkpoints \
  --seed 222 --log-format simple --log-interval 8 \
  --restore-file $PRETRAIN \
  --reset-optimizer --reset-meters --reset-dataloader --reset-lr-scheduler \
  --langs $langs \
  --save-dir $OUTPUT \
  --ddp-backend legacy_ddp \
  --eval-bleu \
  --eval-bleu-detok moses \
  --eval-bleu-remove-bpe sentencepiece \
  --eval-bleu-print-samples \
  --best-checkpoint-metric bleu --maximize-best-checkpoint-metric \
  --memory-efficient-fp16
  
