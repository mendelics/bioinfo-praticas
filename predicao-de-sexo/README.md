# Predição de sexo


## 📚 Descrição

Neste workflow temos como objetivo realizar a predição do sexo biológico das amostras analisadas. Utilizaremos duas abordagens:

- Razão de heterozigotos no cromossomo X: é esperado que tenham menos sítios heterozigotos em amostras de origem masculina pois existe apenas uma cópia do cromossomo X.
- Leituras alinhadas na região SRY do cromossomo Y: apenas amostras de origem masculina apresentam boa cobertura na região SRY do cromossomo Y.

Verificações como estas são importantes pois podem ocorrer trocas de amostras - seja em laboratório parceiro ou em seu próprio. Se a troca for de amostra masculina por masculina ainda será um problema, mas caso ocorra uma troca entre homem/mulher este controle de qualidade irá alerta-lo do problema (desde que você tenha também o sexo cadastrado).


> Quando se tem muitas amostras pode acontecer de existir alguma anomalia genética, como o SRY inserido no cromossomo X, ou erros no cadastro, como por exemplo a mãe que preenche o cadastro do filho colocar o sexo dela, e não da prole.

## 🧰 Etapas

Preparamos este workflow para ser bastante simples, pois o principal objetivo é apresentar algumas ferramentas, e não aprofundar em uma específica.

### 🧪 CountVariants

Aplica a ferramenta _bcftools_ para contar o número de heterozigotos e de homozigotos no cromossomo X das amostras avaliadas. 

O programa _bcftools_ pode ser instalado de diversas maneiras em seu sistema, exemplo:

```sh
# Se for um sistema como Debian/Ubuntu
sudo apt install bcftools

# Se utilizar conda
conda install -c bioconda bcftools

# Se quiser usar dentro um container (ex: com Docker)
docker run -it --rm -v $(pwd):/work -w /work quay.io/biocontainers/bcftools:1.14--hde04aa1_1 bash
```

No workflow desta prática ele é usado [aqui](https://github.com/lmtani/agua-triste/blob/4fe26e34ad364cb36da36eb910ff3b58416a6886/2-predicao-de-sexo/predicao-de-sexo.wdl#L67-L68).

### 🧪 CalculateCoverages

Utiliza a ferramenta _mosdepth_ para verificar a cobertura horizontal sobre a região SRY do cromossomo Y. 

Esta ferramenta também está disponível para instalação via conda ou pelo próprio [repositório oficial](https://github.com/brentp/mosdepth), basta baixar o binário para o caso de usar linux.

No workflow desta prática ele é usado [aqui](https://github.com/lmtani/agua-triste/blob/main/2-predicao-de-sexo/predicao-de-sexo.wdl#L105).

### 🧪 ClassifySex

Carrega os valores calculados nas etapas anteriores para classificar cada uma das amostras como de origem masculina ou feminina. Usamos um pequeno script com Python [aqui](https://github.com/lmtani/agua-triste/blob/main/2-predicao-de-sexo/predicao-de-sexo.wdl#L137-L164).

É bastante inconveniente trabalhar com script embutido em arquivos WDL pois perdemos todo auxílio que IDEs (como pycharm ou vscode) oferecem. Muitas vezes costumo começar em um arquivo .py e depois apenas copiar para o WDL.

Neste quesito o [Nextflow](https://www.nextflow.io/) é mais conveniente, pois podemos deixar os scripts em um diretório `bin/` no repositório e chamá-los diretamente, como [este exemplo](https://github.com/epi2me-labs/wf-artic/tree/master/bin) com um workflow para análise de linhagens de sars-cov-2 usando sequenciamento Nanopore.
