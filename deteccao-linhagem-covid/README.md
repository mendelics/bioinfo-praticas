# Detecção de Linhagem de Covid


## 📚 Descrição

Neste workflow temos como objetivo detectar qual a linhagem/variante do SARS-CoV-2 dado um determinado genoma consenso, utilizando para isso o programa [Pangolin](https://github.com/cov-lineages/pangolin).


## 🧰 Etapas

### 🧪 Pangolin

O programa Pangolin pode ser rodado em [Docker](https://quay.io/biocontainers/pangolin:3.1.20--pyhdfd78af_0) ou instalado localmente seguindo uma das [instruções do repositório oficial](https://cov-lineages.org/resources/pangolin/installation.html).

Embora a versão do Pangolin que usamos seja fixada através da imagem do Docker, é possível atualizar o programa automaticamente com o comando `pangolin --update`. De forma similar, podemos atualizar apenas o banco de dados de variantes/linhagens usadas pelo programa, com o comando `pangolin --update-data`. Neste exemplo de workflow, atualizamos apenas os dados do banco, visto que já escolhemos a imagem mais recente e alterações na versão do programa em si podem alterar o formato dos arquivos de output - mas alterações no banco apenas servem para melhorar a identificação de variantes, sendo muito importantes visto que o banco é atualizado com alta frequência, dada a velocidade de mutação do vírus (de forma que o banco é atualizado mais frequentemente que o versionamento do programa).

## Desafio

Veja que o Workflow de Detecção de SARS-CoV-2 gera um arquivo de genoma consenso FASTA. É interessante, portanto, unir ambos os workflows, permitindo automatizar todo o processo desde o processamento dos FASTQs até a identificação de uma variante. 
Note que, como usamos um downsample para os arquivos do workflow de detecção de coronavírus que resultou em grande perda de cobertura, usar os mesmos FASTQs pode não dar um resultado preciso para a linhagem, mas o workflow pode ser utilizado para qualquer outro arquivo de input - o que significa que você pode rodar e testar o mesmo com outros conjuntos de FASTQ.