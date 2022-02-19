# Bioinfo, git, testes e CI

Neste repositório organizamos práticas para experimentarmos diversas ferramentas que fazem parte do dia a dia dentro da Mendelics. Aqui nosso objetivo não é aprofundarmos nos detalhes de cada uma, apenas queremos mostrar sua importância para nosso desenvolvimento.

### Acesso rápido:
- [Práticas](#-práticas)
- [Ferramentas](#-ferramentas)
  - [Github](#-github)
  - [Organização de workflow](#-organização-de-workflow)
  - [Testes automáticos](#-testes-automáticos)
  - [Integração continua](#-integração-continua)


## Práticas

Preparamos dois workflows - visando serem didáticos - com parte das tarefas que executamos rotineiramente na empresa. 

- [_deteccao-sars-cov-2_](deteccao-sars-cov-2/): utiliza dados de sequenciamento nanopore. Resumidamente, este workflow alinha as leituras contra o genoma referência do sars-cov-2 para montar uma sequencia consenso.
- [deteccao-linhagem-covid](deteccao-linhagem-covid/): Classifica montagens de genomas virais em suas respectivas linhagens. Ex: BA.1, BA.2, etc.
- [_predicao-de-sexo_](predicao-de-sexo/): realiza a predição do sexo biológico de duas formas: 1) porcentagem de sitios heterozigotos no cromossomo X e 2) presença de leituras sobre a região SRY do cromossomo Y.

## 🧰 Ferramentas

Iremos passar por:

- Um workflow definido na [sintaxe de WDL](https://github.com/openwdl/wdl)
- Controle de versões do código com [Github](https://github.com/)
- Testes automáticos com a biblioteca [pytest-workflow](https://pytest-workflow.readthedocs.io/en/stable/)
- Integração contínua com [CircleCI](https://circleci.com/).

Para completar esta prática você precisará apenas de uma conta no GitHub. Um computador com WSL2, Ubuntu, macOS e afins ajuda, mas não é essencial.

> **Nota:** para executar estes testes (e workflows) em seu computador você precisará de no mínimo: [Docker](https://docs.docker.com/engine/install/ubuntu/), Python e [miniwdl](https://miniwdl.readthedocs.io/en/latest/getting_started.html#install-miniwdl). Como são coleções pequenas para testes a capacidade da máquina não precisa ser alta.

### 🔧 Organização de workflow

Optamos por usar a linguagem WDL ([pronunciada widdle](https://support.terra.bio/hc/en-us/articles/360037117492-Overview-Getting-started-with-WDL)). Para processos simples ou operações apenas exploratórias pode ser questionável a adoção de uma linguagem para organizar workflows, pois adiciona complexidade. No entanto a complexidade se paga quando temos uma linha de produção, como na Mendelics onde centenas de exomas são processados semanalmente. Entre os ganhos podemos citar:

- As etapas ficam bem definidas, podendo ser reaproveitadas. Muitas vezes podemos até mesmo usar algumas das disponibilizadas pelo [Broad Institute via projeto WARP](https://broadinstitute.github.io/warp/).

- Temos controle fácil dos recursos computacionais de infraestrutura. Pode-se configurar para usar HPC, Google Cloud, AWS, alibaba cloud, etc. Dessa forma, para etapas leves podemos reservar poucos recursos, enquanto que para as mais pesadas podemos fazer o oposto.

### 🔧 Github

Github é esta plataforma onde você está lendo este texto. Dedique um tempo em se familiarizar com ela. Repositório é o local em que se encontram todos os arquivos referentes a um projeto dentro do Github para uma conta. Como por exemplo, aqui o repositório é bioinfo-praticas, dentro da conta mendelics. Note que logo abaixo do nome do repositório existem algumas abas com "code", "issues", "pull requests", etc. Esses são alguns dos conteúdos disponíveis na plataforma.

![image](https://user-images.githubusercontent.com/12699242/154550821-7584f54e-69d1-432e-bcf0-31516087eb36.png)


* **_"Code"_** você poderá visualizar todo código e arquivos armazenados no repositório.

* **"_Issues_"** são listados todos os problemas e dúvidas já postados, é dividido em "_open_" e "_closed_". Quando estiver em sua jornada de bioinfo e tiver problemas com algum programa você pode encontrar nessa sessão outras pessoas que podem ter passado pelo mesmo problema que você, e com sorte também encontrará uma solução ou "_workaround_". Se estiver confiante de que existe mesmo um bug fique a vontade para criar issues, sempre respeitando as sugestões que os autores do repositório. Ex: pode ser importante listar o sistema operacional que você está usando, ou a versão do programa que apresentou o problema, etc. Você pode conferir aqui um [exemplo de issue](https://github.com/broadinstitute/cromwell/issues/5592), note que é de 2020, outras pessoas disseram se tratar de um bug mas ainda assim não foi resolvido pois provavelmente não afeta muitos casos de uso.

* **_"Pull requests"_** são solicitações abertas para que um novo código, ou alterações no código existente, sejam mescladas à sua base de código. Normalmente é onde acontecem discussões sobre as mudanças com os envolvidos para que não entre nada que vá estragar o código existente em sua "linha de produção". [Veja este exemplo](https://github.com/openwdl/wdl/pull/438), onde um dos desenvolvedores propõem a adição de uma nova nota à uma errata e um revisor opina a respeito da mudança.

![image](https://user-images.githubusercontent.com/12699242/154550685-a058a069-6002-4a24-b5d3-27b1503da2d2.png)

Existe um botão escrito "_fork_" na parte superior direita desta tela (ilustrado na imagem acima). Você precisará clicar nele para copiar este repositório para sua conta, e assim realizar as alterações necessárias para posteriormente voltá-las para cá, ou mesmo evoluí-las em paralelo em um repositório controlado por você.

### 🔧 Testes automáticos

Quando interagimos com o computador sempre realizamos testes em um nivel ou em outro. Por exemplo: alguém desenvolvendo um programa para montagem de genomas certamente irá separar uma coleção mínima de dados para testar periodicamente o código em que está trabalhando. Por que devemos manualmente rodar esses testes? Não seria melhor que os testes rodassem sempre que uma alteração fosse submetida à sua base de código? Esse é o intuito dos testes automáticos. 

Vale a pena dedicarmos um tempo elaborando testes automáticos para as principais funcionalidades de nossos programas (ou sistemas), pois dessa forma temos segurança ao fazermos mudanças. Existem diversas maneiras de preparar tais testes. Nesta prática usamos a biblioteca [pytest-workflow](https://pytest-workflow.readthedocs.io/en/stable/) para verificar as diferentes etapas de nosso pipeline.

[Neste arquivo](https://github.com/lmtani/agua-triste/blob/8f0a061b24b8e2d7d3eb563e009c43f336c7aa44/2-predicao-de-sexo/test_sex_prediction.yml) temos todos os testes que desejamos. Eles são executados automaticamente sempre que algo é alterado neste repositório, graças ao processo de integração contínua.

### 🔧 Integração contínua

É relativamente comum que novas versões de software sejam manualmente disponibilizadas após uma série de mudanças feitas pelos desenvolvedores, que podem ser reorganizações de código ou novos recursos. O processo de integração contínua é um sistema onde uma vez que a mudança para o software é proposta ela será avaliada por uma série de testes automáticos, como os desta prática, pode ser revisada por um colega humano e, se tudo for aprovado, entrará em sua linha de produção. Em suma, a integração automática permite que os testes rodem automaticamente a cada processo de revisão de mudança no software para garantir que não haja erro em nenhum processo importante.

Usamos o CircleCI, que oferece uma cota gratuita para projetos publicos. [Neste link](colocar link) você pode conferir a interface que a plataforma oferece. Existem outros que também são bons, como o [Travis](https://www.travis-ci.com/).


### Links

[Dicas para desenvolvimento](https://github.com/mendelics/lbb-mendelics-2021/blob/main/dicas-desenvolvimento.md): Material preparado por nós para a competição organizada pela Liga Brasileira de Bioinformatica. Discorre sobre os mesmos assuntos dessa prática, com algumas curiosidades e exemplos a diferentes.
