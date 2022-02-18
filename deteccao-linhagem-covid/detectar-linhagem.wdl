version 1.0


workflow DetectLineage {
    input {
        File consensus_fasta
    }

    call Pangolin {
        input:
            fasta=consensus_fasta
    }

    output {

    }
}

task Pangolin {
    input {
        File fasta
    }

    command <<<
        set -eux

        pangolin -v > pangolin_version.txt
        pangolin -pv > pangoLEARN_version.txt

        pangolin \
            ~{fasta} \
            --outfile pangolin.lineage.csv
    >>>

    runtime {
        docker: "quay.io/biocontainers/pangolin:3.1.20--pyhdfd78af_0"
        preemptible: 3
    }

    output {
        File pangolin_result_csv = "pangolin.lineage.csv"
        String pangolin_version = read_string("pangolin_version.txt")
        String pangoLEARN_version = read_string("pangoLEARN_version.txt")
    }
}