# Impact of Domain-Adapted Multilingual Neural Machine Translation in the Medical Domain

Scripts for the reproducing the results of the papers: 

Quality Analysis of Multilingual Neural Machine Translation Systems and Reference Test Translations for the English-Romanian language pair in the Medical Domain

Accepted at:

[EAMT 2023](https://events.tuni.fi/eamt23/)


Impact of Domain-Adapted Multilingual Neural Machine Translation in the Medical Domain

To be presented at:

[AsLing‘s 44th Translating and the Computer conference — TC44](https://asling.org/tc44/)

# Requirements

- Python 3.8
- pip install requirements.txt

Fairseq

- git clone https://github.com/pytorch/fairseq
- cd fairseq
- pip install --editable ./

Moses scripts

[Moses](https://github.com/moses-smt/mosesdecoder)

MBart 

- [mbart.cc25.ft.enro](https://dl.fbaipublicfiles.com/fairseq/models/mbart/mbart.cc25.ft.enro.tar.gz)

# Results

Scripts in directory **scripts**
Qualitivity export in directory **annotation**

1. Prepare data (note: change paths of files)

EMEA [EN-RO](https://elrc-share.eu/repository/browse/bilingual-corpus-made-out-of-pdf-documents-from-the-european-medicines-agency-emea-httpswwwemaeuropaeu-february-2020-en-ro/3e38f500862b11ea913100155d026706378f2850bc3a47cd908640d762ef1de7/) tmx to moses format:

```
python xml2txt en ro  en-ro.tmx data/en-ro.emea
```

2. Split train and validation data

```
bash en-ro_EMEA/split_traindev.sh 
```

3. Preprocess train and validation (note: change paths of files)

```
bash en-ro_EMEA/preprare_emea_mbart_traindev.sh
```

4.  Fine-tune MBart

```
bash en-ro_EMEA/finetune_emea_mbart_wmt.sh
```

5. Evaluate Medline

Generate translations with MBart:

```
bash en-ro_abstracts/generate_trans_mbart.sh
```

Generate translations with fine-tune MBart:

```
bash en-ro_abstracts/generate_trans_mbartft.sh
```

6. Compute BLEU, chrF, and COMET scores

Change paths for MBart and fine-tune MBart outputs
 
```
sacrebleu en-ro.abstracts.ro -l en-ro -i en-ro.test.mbart.sys.hyp -m bleu chrf
[
{
 "name": "BLEU",
 "score": 22.0,
 "signature": "nrefs:1|case:mixed|eff:no|tok:13a|smooth:exp|version:2.2.1",
 "verbose_score": "50.9/27.0/16.4/10.3 (BP = 1.000 ratio = 1.018 hyp_len = 8407 ref_len = 8255)",
 "nrefs": "1",
 "case": "mixed",
 "eff": "no",
 "tok": "13a",
 "smooth": "exp",
 "version": "2.2.1"
},
{
 "name": "chrF2",
 "score": 51.5,
 "signature": "nrefs:1|case:mixed|eff:yes|nc:6|nw:0|space:no|version:2.2.1",
 "nrefs": "1",
 "case": "mixed",
 "eff": "yes",
 "nc": "6",
 "nw": "0",
 "space": "no",
 "version": "2.2.1"
}
]

```

You can also use the notebook to compute automatic metrics in: en-ro_abstracts/mt_metrics_asling2022.ipynb


```
comet-score -s en-ro.abstracts.en -t en-ro.test.mbart.sys.hyp -r en-ro.abstracts.ro
en-ro.test.mbart.sys.hyp	score: 0.5560
```


6. Metric Correlation

- Extract annotaiton from qualitivity export file:

```
python extract_qualitymetrics_info.py annotation/2022-07-26_export.csv annotation/2022-07-26_export.extract.json
```

- Compute MQM scores :

```
python segment_mqm_qualitymetrics.py annotation/022-07-26_export.extractinfo.json 75 
``` 

# Citation

TBA 
