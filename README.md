# bayesTME nextflow pipeline

A nextflow script to execute the **Bleeding Correction** Step of the [docs example](https://bayestme.readthedocs.io/en/latest/example_workflow.html) of [bayesTME](https://github.com/tansey-lab/bayestme).


## Installation and Usage

1. Install nextflow:

    ```bash
    wget -qO- get.nextflow.io | bash
    chmod +x ./nextflow
    mv ./nextflow /usr/local/bin/
    ```
    **Requirements:** To run nextflow you need either java version 11 up to 20, or docker (`nextflow -dockerize`).

2. Download [Test data](https://www.dropbox.com/sh/1nbaa3dxcgco6oh/AACUD6KJT7KFGD7y7XQ1ndz-a?dl=0) and save it in your current working directory (i.e. `$PWD/indir`). This data comes from the [10X Genomics Spaceranger pipeline](https://support.10xgenomics.com/spatial-gene-expression/software/pipelines/latest/installation).

2. Run Pipeline:

    ```bash
    nextflow -dockerize run main.nf -profile cloud \
        --sample IID_TEST \
        --input_dir $PWD/indir \
        --outdir $PWD/outdir
    ```

