#!/bin/bash
#steps to test a new document with moses
#input:

src=en
input=en-ro.vaccine.en
trumodel=/home/mrios/workspace/en-ro_medcorpora/EMEA/moses/truecaser/truecase-model.1.en
model=/home/mrios/workspace/en-ro_medcorpora/EMEA/moses/model/moses.ini

echo 'Preprocessing source' $src
/home/mrios/workspace/mosesdecoder/scripts/tokenizer/tokenizer.perl -l $src < $input > $input.tok
/home/mrios/workspace/mosesdecoder/scripts/recaser/truecase.perl --model $trumodel < $input.tok  > $input.tok.true

echo 'Decoding ' 
/home/mrios/workspace/mosesdecoder/bin/moses2 \
-f $model  \
< $input.tok.true              \
> $input.tok.true.tran

echo 'detokenize and recase'
/home/mrios/workspace/mosesdecoder/scripts/recaser/detruecase.perl < $input.tok.true.tran > $input.recased
/home/mrios/workspace/mosesdecoder/scripts/tokenizer/detokenizer.perl -l $src < $input.recased > $input.tran



