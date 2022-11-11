#!/bin/bash
#split train and dev

DATA=data

echo 'split train dev'

awk '{if (NR%100 == 0)  print $0; }' $DATA/en-ro.emea.en > $DATA/en-ro.emea.en.valid
awk '{if (NR%100 != 0)  print $0; }' $DATA/en-ro.emea.en > $DATA/en-ro.emea.en.train

awk '{if (NR%100 == 0)  print $0; }' $DATA/en-ro.emea.ro > $DATA/en-ro.emea.ro.valid
awk '{if (NR%100 != 0)  print $0; }' $DATA/en-ro.emea.ro > $DATA/en-ro.emea.ro.train

