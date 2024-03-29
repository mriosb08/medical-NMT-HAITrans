#!/bin/bash

DATA=/mnt/disks/workspace1/en-ro_medcorpora/EMEA/data
OUTPUT=/mnt/disks/workspace1/en-ro_medcorpora/EMEA/models/mbartwmt_finetuned_bleu_emea
#pretrain checkpoint in https://dl.fbaipublicfiles.com/fairseq/models/mbart/mbart.cc25.ft.enro.tar.gz
PRETRAIN=/mnt/disks/workspace1/MBART_finetuned_enro/model.pt # fix if you moved the downloaded checkpoint
langs=ar_AR,cs_CZ,de_DE,en_XX,es_XX,et_EE,fi_FI,fr_XX,gu_IN,hi_IN,it_IT,ja_XX,kk_KZ,ko_KR,lt_LT,lv_LV,my_MM,ne_NP,nl_XX,ro_RO,ru_RU,si_LK,tr_TR,vi_VN,zh_CN

fairseq-train $DATA/emea.mbart.spm.en-ro \
  --encoder-normalize-before --decoder-normalize-before \
  --arch mbart_large --layernorm-embedding \
  --task translation_from_pretrained_bart \
  --source-lang en_XX --target-lang ro_RO \
  --criterion label_smoothed_cross_entropy --label-smoothing 0.2 \
  --optimizer adam --adam-eps 1e-06 --adam-betas '(0.9, 0.98)' \
  --lr-scheduler inverse_sqrt --lr 3e-05 --warmup-updates 2500 --max-update 40000 \
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
  
