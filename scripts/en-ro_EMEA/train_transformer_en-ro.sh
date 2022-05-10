#!/bin/bash
#train trasnformer base fairseq
DATA=data
OUTPUT=models/transformer_base

CUDA_VISIBLE_DEVICES=0 fairseq-train \
    $DATA/emea.tokenized.en-ro \
    --arch transformer --share-decoder-input-output-embed \
    --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
    --lr 5e-4 --lr-scheduler inverse_sqrt --warmup-updates 4000 \
    --dropout 0.1 --weight-decay 0.0001 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --max-tokens 4096 \
    --eval-bleu \
    --eval-bleu-detok moses \
    --eval-bleu-remove-bpe \
    --eval-bleu-print-samples \
    --patience 5 \
    --no-epoch-checkpoints \
    --save-dir $OUTPUT \
    --best-checkpoint-metric bleu --maximize-best-checkpoint-metric
