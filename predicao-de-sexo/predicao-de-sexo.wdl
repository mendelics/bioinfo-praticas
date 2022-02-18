version 1.0

# Processar arquivos com variantes (VCF) e alinhamentos (BAM) a fim de obter
# a predição do sexo de cada amostra.
# Este é o workflow, responsável por definir os inputs e executar cada uma das etapas definidas.
workflow SexPrediction {
    input {
        # A maneira habitual de se passar os inputs de um worflow WDL é via um arquivo JSON
        # como os contidos no diretório tests/.
        Array[File] vcf_files
        Array[File] vcf_files_idx
        Array[File] bam_files
        Array[File] bam_files_idx
    }

    # Mais abaixo no arquivo você encontrará a definição de cada uma das
    # tasks usadas neste workflow.
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

    # Definimos aqui quais os outputs que desejamos. Caso essa sessão
    # não seja especificada todos os outputs de todas as tasks serão listados.
    output {
        File predictions = ClassifySex.predictions
    }
}


# Esta é uma task, o nome é usado para referencia-la no workflow.
# É permitido, no workflow, se usar "alias", caso seja conveniente. 
# Ex: `call CountVariants as MinhaContagem {}`. Apenas para info ;)
task CountVariants {
    input {
        Array[File] vcf_files
        Array[File] vcf_files_idx
    }

    # Neste bloco definimos o que de fato será executado, todo o resto lida apenas
    # com questões de infraestrutura e orquestração. Para acessar os valores fornecidos
    # como inputs da task usamos a notação "~{nome_do_input}". Documentação completa em
    # https://github.com/openwdl/wdl/blob/main/versions/1.1/SPEC.md#an-example-wdl-workflow
    command <<<
        set -e  # Importante para que o script pare no primeiro erro que ocorrer.

        # A sintaxe ~{sep=" " vcf_files} é de WDL, ela expande o array
        # em uma string separada por espaço. Ex: "item1 item2 item3".
        # De resto, isto é apenas um for-loop em bash.
        for vcf in ~{sep=" " vcf_files}; do
            # Armazenamos o stdout (print na tela) dos comandos em variáveis, assim podemos
            # acessa-los posteriormente, no comando "echo"
            name=$(basename $vcf .vcf.gz)
            het_count=$(bcftools view -H -g het $vcf chrX | wc -l) # contagem de heterozigotos
            hom_count=$(bcftools view -H -g hom $vcf chrX | wc -l) # contagem de homozigotos
            echo -e "$name\t$het_count\t$hom_count" >> counts.tsv
        done
    >>>

    # Aqui definimos quais recursos a task precisa para executar seus processos. Em ambiente
    # de cloud poderiamos definir campos como "cpu" e "memory" para solicitar maquinas com
    # determinada capacidade de CPUs e memória RAM, respectivamente. Aqui apenas definimos que
    # desejamos executar a task em um container com bcftools.
    runtime {
        docker: "quay.io/biocontainers/bcftools:1.14--hde04aa1_1"
    }

    # Definimos os outputs. Neste caso o arquivo foi gerado como consequencia do comando "echo" da
    # linha 69.
    output {
        File counts = "counts.tsv"
    }
}


# O programa mosdepth gera diversos outputs, entre eles o *.thresholds.bed.gz.
# esse output nos informa o numero de bases do intervalo fornecido (no caso a região SRY)
# que apresentaram no minimo 10,20,30,40 reads alinhados, conforme solicitado pelo
# parâmetro "--thresholds".
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
            mosdepth --chrom chrY --no-per-base --parametro-que-nao-existe --thresholds 10,20,30,40 --by interval.bed $name.output $bam
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


# Um pouco de python nesta, apenas para ler os arquivos gerados
# nas etapas anteriores e usar seus valores para classificar "male" ou "female".
# O gabarito é:
# OZX502-001    female"
# UQE098-001    female"
# CXT070-001    male"
# KAB133-001    male"
# NQB080-001    male"
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
