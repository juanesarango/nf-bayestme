/*
 * pipeline input parameters
 */

params.ram_limit = 59055800320
params.cores = 4
params.n_top = 100

log.info """\
    b a y e s T M E    P I P E L I N E
    ===================================
    Params:
    -----------------------------------
    sample     : ${params.sample}
    input_dir  : ${params.input_dir}
    ===================================
    Project    : ${workflow.projectDir}
    Cmd line   : ${workflow.commandLine}
    """
    .stripIndent()



process SPACERANGER_TO_ANNDATA {
    tag "Visium/10x spaceranger input to anndata format: ${params.sample}"
    publishDir params.outdir, mode: 'copy'
    cpus params.cores
    memory '4 GB'

    output:
      path "${params.sample}.h5ad"

    script:
      """
      load_spaceranger \
          --input ${params.input_dir} \
          --output ${params.sample}.h5ad \
          --verbose
      """
      .stripIndent()
}

process FILTER_GENES {
    tag "Filter Genes: ${params.sample}"
    publishDir params.outdir, mode: 'copy'
    cpus params.cores
    memory '4 GB'

    input:
      path ann_dataset

    output:
      path "${params.sample}_filtered.h5ad", emit: ann_filtered_dataset

    script:
      """
      filter_genes \
          --adata ${ann_dataset} \
          --output ${params.sample}_filtered.h5ad \
          --filter-ribosomal-genes \
          --n-top-by-standard-deviation ${params.n_top} \
          --verbose
      """
      .stripIndent()
}

process BLEED_CORRECTION {
    tag "Bleed Correction: ${params.sample}"
    publishDir params.outdir, mode: 'copy'
    cpus params.cores
    memory '10 GB'

    input:
      path ann_filtered_dataset

    output:
      path "${params.sample}_filtered_corrected.h5ad", emit: ann_filtered_corrected_dataset
      path "bleed_correction_results.h5", emit: bleed_correction_results

    script:
      """
      bleeding_correction \
          --adata ${ann_filtered_dataset} \
          --adata-output "${params.sample}_filtered_corrected.h5ad" \
          --bleed-out bleed_correction_results.h5 \
          --verbose
      """
      .stripIndent()
}


process PLOT_BLEEDING_CORRECTION {
    tag "Plot Bleeding Correction: ${params.sample}"
    publishDir params.outdir, mode: 'copy'
    cpus params.cores
    memory '4 GB'

    input:
      path ann_filtered_dataset
      path ann_filtered_corrected_dataset
      path bleed_correction_results

    output:
      path "bleed_correction_results/basis-functions.pdf", emit: basis_functions
      path "bleed_correction_results/*_bleed_vectors.pdf", emit: bleed_vectors
      path "bleed_correction_results/*_bleeding_plot.pdf", emit: bleeding_plots

    script:
      """
      mkdir -p bleed_correction_results
      plot_bleeding_correction \
          --raw-adata ${ann_filtered_dataset} \
          --corrected-adata ${ann_filtered_corrected_dataset} \
          --bleed-correction-results ${bleed_correction_results} \
          --output-dir bleed_correction_results \
          --verbose
      """
      .stripIndent()
}

workflow {
    ann_data = SPACERANGER_TO_ANNDATA()
    ann_filtered_data = FILTER_GENES(ann_data)

    bleeding_results = BLEED_CORRECTION(ann_filtered_data)
    PLOT_BLEEDING_CORRECTION(ann_filtered_data, bleeding_results)
}

workflow.onComplete {
    log.info (
      workflow.success
        ? "\nDone! Check the plot files: ${params.outdir}/bleed_correction_results/basis-functions.pdf\n"
        : "\nOops .. something went wrong\n"
    )
}

