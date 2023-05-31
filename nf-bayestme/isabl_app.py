from os.path import join

from isabl_cli import AbstractApplication
from isabl_cli import options


class BayesTME(AbstractApplication):
    """
    A reference-free Bayesian method for analyzing spatial transcriptomics data.
    """

    VERSION = "#5db7cd5"  # https://github.com/tansey-lab/bayestme/tree/5db7cd5
    NAME = "BAYES_TME"
    cli_help = (
        "A reference-free Bayesian method for analyzing spatial transcriptomics data."
    )
    cli_options = [options.TARGETS]
    application_settings = {
        "nf_bayestme": "juanesarango/nf-bayestme",
        "profile": "hpc",
    }
    application_results = {
        "basis_functions": {
            "frontend_type": "pdf",
            "description": "Basis Functions Plot.",
            "verbose_name": "basis functions",
        },
        "bleeding_pdfs": {
            "frontend_type": "pdf",
            "description": "Bleeding Plots and Vectors.",
            "verbose_name": "bleeding results",
        },
        "10x_spaceranger_counts": {
            "frontend_type": "html",
            "description": "10x Spaceranger counts Summary.",
            "verbose_name": "10x spaceranger counts",
        },
        "nextflow_report": {
            "frontend_type": "html",
            "description": "Nextflow html pipeline report.",
            "verbose_name": "Nextflow report",
        },
        "nextflow_dag": {
            "frontend_type": "html",
            "description": "Nextflow tsv pipeline dag.",
            "verbose_name": "Nextflow graph",
        },
        "nextflow_trace": {
            "frontend_type": "tsv-file",
            "description": "Nextflow tsv pipeline metrics.",
            "verbose_name": "Nextflow metrics",
        },
    }

    def get_experiments_from_cli_options(self, **cli_options):
        """Build tuples of (targets, references) from cli options."""
        return [([i], []) for i in cli_options["targets"]]

    def validate_experiments(self, targets, references):
        """Validate inputs and tuples are correct."""
        self.validate_one_target_no_references(targets, references)

    def get_command(self, analysis, _inputs, settings):
        """Build command to run."""
        target = analysis["targets"][0]
        outdir = analysis["storage_url"]
        space_ranger_data = "$PWD/A1_spaceranger_output"  # target.get_raw_data()
        cmd = f"""
            nextflow -dockerize run {settings.nf_bayestme} \
                --input_dir  {space_ranger_data} \
                --sample {target.system_id} \
                --outdir {outdir}
        """
        if settings.profile:
            cmd += f" -profile {settings.profile}"
        if settings.restart:
            cmd += " -resume"
        return " ".join(cmd.split())

    def get_analysis_results(self, analysis):
        """Assign output files to analyses results."""
        outdir = analysis.storage_url
        bleed_dir = join(outdir, "bleed_correction_results")
        return {
            "basis_functions": join(outdir, bleed_dir, "basis-functions.pdf"),
            "bleeding_pdfs": join(outdir, bleed_dir, "output.pdf"),
            "nextflow_report": join(outdir, "pipeline_report.html"),
            "nextflow_trace": join(outdir, "pipeline_trace.txt"),
            "nextflow_dag": join(outdir, "pipeline_dag.html"),
        }


class BayesTMEGRCh37(BayesTME):
    """BayesTME for GRCh37."""

    ASSEMBLY = "GRCh37"
    SPECIES = "HUMAN"
