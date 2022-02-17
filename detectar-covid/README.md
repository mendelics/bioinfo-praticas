# Detecção de Covid


## 📚 Descrição

Neste workflow temos como objetivo detectar amostras positivas para covid usando o [pipeline Artic](https://github.com/artic-network/fieldbioinformatics/), conforme [o protocolo do Artic para sequenciamento do coronavírus](https://artic.network/ncov-2019/ncov2019-bioinformatics-sop.html).

O workflow foi feito para analisar arquivos FASTQ obtidos de sequenciadores Nanopore MinION, utilizando o protocolo de laboratório do Artic, sequenciando amplicons de coronavírus.


## 🧰 Etapas

ArticGuppyplex: filtra as reads para unir os arquivos fastq e remover sequências pequenas ou longas demais. Como utilizamos apenas o arquivo "pass" do MinION, que já filtra por qualidade, podemos pular a etapa de quality-check.

ArticMinion: alinha as reads contra o genoma referência de SARS-CoV-2, baseando-se no esquema de primers usado para o sequenciamento do vírus por amplicons. As reads são alinhadas de acordo com os amplicons esperados, e o pipeline do Artic corrige erros das mesmas, gerando uma sequência FASTA consenso.

GetCoverage: carrega os valores calculados nas etapas anteriores para classificar cada uma das amostras como positiva ou negativa para coronavírus, de acordo com uma cobertura mínima necessária para o genoma, definida em um _threshold_.
