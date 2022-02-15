version 1.0


workflow SexPrediction {
    input {
        Array[File] vcf_files
        Array[File] vcf_files_idx
        Array[File] bam_files
        Array[File] bam_files_idx
    }

    call CountVariants {
        input:
            vcf_files=vcf_files,
            vcf_files_idx=vcf_files_idx
    }

    call CalculateCoverages {
        input:
            bam_files=bam_files,
            bam_files_idx=bam_files_idx,
            interval="chrY\t2786854\t2787741\tSRY"
    }

    call ClassifySex {
        input:
            coverages_tsv=CalculateCoverages.coverages,
            counts_tsv=CountVariants.counts
    }

    output {
        File predictions = ClassifySex.predictions
    }
}



task CountVariants {
    input {
        Array[File] vcf_files
        Array[File] vcf_files_idx
    }

    command <<<
        set -eux
        # A sintaxe ~{sep=" " vcf_files} é de WDL, ela expande o array
        # em uma string separada por espaço. Ex: "item1 item2 item3"
        for vcf in ~{sep=" " vcf_files}; do
            name=$(basename $vcf .vcf.gz)
            het_count=$(bcftools view -H -g het $vcf chrX | wc -l)
            hom_count=$(bcftools view -H -g hom $vcf chrX | wc -l)
            echo -e "$name\t$het_count\t$hom_count" >> counts.tsv
        done
    >>>

    runtime {
        docker: "quay.io/biocontainers/bcftools:1.14--hde04aa1_1"
    }

    output {
        File counts = "counts.tsv"
    }
}



task CalculateCoverages {
    input {
        Array[File] bam_files
        Array[File] bam_files_idx
        String interval
    }

    command <<<
        set -eux
        echo -e "~{interval}" >> interval.bed
        for bam in ~{sep=" " bam_files}; do
            name=$(basename $bam .bam)
            mosdepth --chrom chrY --no-per-base --thresholds 10,20,30,40 --by interval.bed $name.output $bam
            data=$(zcat $name.output.thresholds.bed.gz | grep SRY)
            echo -e "$name\t$data" >> coverages.txt
        done
    >>>


    runtime {
        docker: "quay.io/biocontainers/mosdepth:0.3.3--hdfd78af_1"
    }

    output {
        File coverages = "coverages.txt"
    }
}


task ClassifySex {
    input {
        File coverages_tsv
        File counts_tsv
    }

    command <<<
        python <<CODE
        def predict_by_sry(path, cutoff):
            results = {}
            with open(path) as fh:
                for l in fh:
                    sample, _, start, end, _, x10, x20, x30, x40 = l.strip().split("\t")
                    total_size = int(end) - int(start)
                    perc_above_10x = int(x10)/total_size
                    results[sample] = "male" if perc_above_10x > cutoff else "female"
            return results

        def predict_by_chr_x(path, cutoff):
            results = {}
            with open(path) as fh:
                for l in fh:
                    sample, het, hom = l.strip().split("\t")
                    ratio = int(het) / (int(hom) + int(het))
                    results[sample] = "male" if ratio < cutoff else "female"
            return results

        print("--- Prediction by SRY coverage ---")
        for sample, prediction in predict_by_sry("~{coverages_tsv}", 0.8).items():
            print(f"{sample}\t{prediction}")

        print("--- Prediction by chrX heterozigous ratio ---")
        for sample, prediction in predict_by_chr_x("~{counts_tsv}", 0.1).items():
            print(f"{sample}\t{prediction}")
        CODE
    >>>


    runtime {
        docker: "quay.io/biocontainers/python:3.8--1"
    }

    output {
        File predictions = stdout()
    }
}
