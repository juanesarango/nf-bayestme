#!/bin/bash

./nextflow -dockerize run main.nf -profile cloud \
  --sample IID_TEST \
  --input_dir $PWD/A1_spaceranger_output \
  --outdir $PWD/out \
  -resume
