#!/bin/bash

path_2_data=<path to your binarized data with fairseq dictionaries>
model=<path_to_extracted_folder>/model.pt
lang_list=<path_to_extracted_folder>/ML50_langs.txt
source_lang=<source language>
target_lang=<target language>

fairseq-generate $path_2_data \
  --path $model \
  --task translation_multi_simple_epoch \
  --gen-subset test \
  --source-lang $source_lang \
  --target-lang $target_lang
  --sacrebleu --remove-bpe 'sentencepiece'\
  --batch-size 32 \
  --encoder-langtok "src" \
  --decoder-langtok \
  --lang-dict "$lang_list"


  #TODO tokenize etc...
