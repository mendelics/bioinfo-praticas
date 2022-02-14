version 1.0


workflow SexPrediction {
    input {
        Array[File] vcf_files
        Array[File] bam_files
        Array[File] bam_files_idx
    }

    call GatherVariants {
        input:
            vcf_files=vcf_files,
            region="chrX"
    }

    call CountVariants {
        input:
            vcf_files=GatherVariants.variants,
            vcf_files_idx=GatherVariants.variants_idx
    }

    call GatherBAMRegions {
        input:
            bam_files=bam_files,
            bam_files_idx=bam_files_idx,
    }

    call CalculateCoverages {
        input:
            bam_files=GatherBAMRegions.alignments,
            bam_files_idx=GatherBAMRegions.alignments_idx,
    }

    output {
        File chrX_predictions = CountVariants.predictions
        File sry_predictions = CalculateCoverages.predictions
    }
}


task GatherVariants {
    input {
        Array[File] vcf_files
        String region
    }

    command <<<

    >>>


    runtime {

    }

    output {
        Array[File] variants = glob("results/*.vcf.gz")
        Array[File] variants_idx = glob("results/*.vcf.gz.tbi")
    }
}

task CountVariants {
    input {
        Array[File] vcf_files
        Array[File] vcf_files_idx
    }

    command <<<

    >>>


    runtime {

    }

    output {
        File predictions = "output.tsv"
    }
}


task GatherBAMRegions {
    input {
        Array[File] bam_files
        Array[File] bam_files_idx
    }

    command <<<

    >>>


    runtime {

    }

    output {
        Array[File] alignments = glob("results/*.bam")
        Array[File] alignments_idx = glob("results/*.bam.bai")
    }
}


task CalculateCoverages {
    input {
        Array[File] bam_files
        Array[File] bam_files_idx
    }

    command <<<

    >>>


    runtime {

    }

    output {
        File predictions = "sry-predictons.tsv"
    }
}

