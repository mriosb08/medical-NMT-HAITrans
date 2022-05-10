#!/bin/bash

#SPM=spm_encode
#MODEL=/home/mrios/workspace/MBART_finetuned_enro/sentence.bpe.model
DATA=data
OUTPUT=models/mbart50pretrained_finetuned_emea1
PRETRAIN=/home/mrios/workspace/mbart50.pretrained # fix if you moved the downloaded checkpoint

#TODO try 512 * 4

fairseq-train $DATA/emea.mbart50.spm.en-ro --save-dir $OUTPUT \
  --finetune-from-model $PRETRAIN/model.pt \
  --encoder-normalize-before --decoder-normalize-before \
  --arch mbart_large --layernorm-embedding \
  --task translation_multi_simple_epoch \
  --sampling-method "temperature" \
  --sampling-temperature 1.5 \
  --encoder-langtok "src" \
  --decoder-langtok \
  --lang-dict $PRETRAIN/ML50_langs.txt \
  --lang-pairs en_XX-ro_RO \
  --criterion label_smoothed_cross_entropy --label-smoothing 0.2 \
  --optimizer adam --adam-eps 1e-06 --adam-betas '(0.9, 0.98)' \
  --lr-scheduler inverse_sqrt --lr 3e-05 --warmup-updates 2500 --max-update 40000 \
  --dropout 0.3 --attention-dropout 0.1 --weight-decay 0.0 \
  --max-tokens 256 --update-freq 8 \
  --save-interval 1 --save-interval-updates 5000 --keep-interval-updates 1 --no-epoch-checkpoints \
  --seed 222 --log-format simple --log-interval 8 \
  --memory-efficient-fp16
