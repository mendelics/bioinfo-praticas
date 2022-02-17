version 1.0


workflow DetectCovid {
    input {
        Array[File] fastqs
        File primer_schemes_compressed
        String scheme = "SARS-CoV-2/V3"
    }

    call ArticGuppyplex {
        input:
            fastqs=fastqs
    }

    call ArticMinion {
        input:
            fastq=ArticGuppyplex.fastq,
            primer_schemes_compressed=primer_schemes_compressed,
            scheme=scheme
    }

    call GetCoverage {
        input:
            fasta=ArticMinion.consensus_fasta
    }

    output {
        Boolean covid_presence = GetCoverage.covid_presence
        Float coverage = GetCoverage.coverage
        File filtered_fastq = ArticGuppyplex.fastq
        File consensus_fasta = ArticMinion.consensus_fasta
    }
}

task ArticGuppyplex {
    input {
        Array[File] fastqs
        Int min_read_length = 300
        Int max_read_length = 800
    }
    command <<<
        set -eux

        mkdir fastqs
        # A sintaxe ~{sep=" " fastqs} é de WDL, ela expande o array
        # em uma string separada por espaço. Ex: "item1 item2 item3"
        mv ~{sep=" " fastqs} fastqs/

        # Como utilizamos apenas os arquivos "pass" do MinION, podemos pular
        # a etapa de quality-check, conforme descrito no protocolo do Artic
        artic guppyplex \
            --skip-quality-check \
            --min-length ~{min_read_length} \
            --max-length ~{max_read_length} \
            --directory fastqs \
            --output "guppyplexed.fastq"

        gzip guppyplexed.fastq
    >>>

    runtime {
        docker: "quay.io/biocontainers/artic:1.2.1--py_0"
        preemptible: 3
    }

    output {
        File fastq = "guppyplexed.fastq.gz"
    }
}



task ArticMinion {
    input {
        File fastq
        File primer_schemes_compressed
        String scheme
        Int normalise = 100
    }

    command <<<
        set -eux

        tar -xzf ~{primer_schemes_compressed}

        artic minion \
            --medaka \
            --medaka-model "r10_min_high_g340" \
            --normalise "~{normalise}" \
            --strict \
            --read-file "~{fastq}" \
            --scheme-directory "primer_schemes" \
            "~{scheme}" \
            "artic_result"
    >>>

    runtime {
        docker: "quay.io/biocontainers/artic:1.2.1--py_0"
        preemptible: 3
    }

    output {
        File consensus_fasta = "artic_result.consensus.fasta"
    }
}

task GetCoverage {
    input {
        File fasta
        Float coverage_threshold = 0.1
    }

    command <<<
        set -eux

        python <<CODE
        sequence = ""
        with open("~{fasta}") as fh:
            for line in fh:
                line = line.strip()
                if not line.startswith(">"):
                    sequence += line
        number_of_ns = sequence.count("N")
        sequence_length = len(sequence)
        n_percentage = number_of_ns / sequence_length
        rounded_n_percentage = round(n_percentage, 3)
        coverage = 1 - n_percentage
        with open("coverage.float", "w") as out:
            out.write(f"{coverage}")

        if coverage >= ~{coverage_threshold}:
            covid_presence = True
        else:
            covid_presence = False

        with open("covid_presence.boolean", "w") as out:
            out.write(f"{covid_presence}".lower())
        CODE
    >>>

    runtime {
        docker: "quay.io/biocontainers/python:3.8--1"
        preemptible: 3
    }

    output {
        Float coverage = read_float("coverage.float")
        Boolean covid_presence = read_boolean("covid_presence.boolean")
    }
}