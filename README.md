# Bioinfo, git, testes e CI

Neste repositório organizamos uma prática para experimentarmos diversas ferramentas que fazem parte do dia a dia dentro da Mendelics. Aqui nosso objetivo não é aprofundarmos nos detalhes de cada uma, apenas queremos mostrar sua importancia para nosso desenvolvimento.

## Para começar

Iremos passar por:

- Um workflow definido na [sintaxe de WDL](https://github.com/openwdl/wdl)
- Testes automáticos com a biblioteca [pytest-workflow](https://pytest-workflow.readthedocs.io/en/stable/)
- Integração contínua com [CircleCI](https://circleci.com/).

Para completar esta prática você precisará apenas de uma conta no GitHub. Um computador com WSL2, Ubuntu, macOS e afins ajuda, mas não é essencial.

### Github

Github é esta plataforma onde você está lendo este texto. Dedique um tempo em se familiarizar com ela. Note que logo abaixo do nome do repositório existem algumas abas com "code", "issues", "pull requests", etc. Esses são alguns dos conteúdos disponíveis na plataforma.

![image](https://user-images.githubusercontent.com/12699242/154550821-7584f54e-69d1-432e-bcf0-31516087eb36.png)


* **_"Code"_** você poderá visualizar todo código e arquivos armazenados no repositório.

* **"_Issues_"** são listados todos os problemas e duvidas já postados, é dividido em "_open_" e "_closed_". Quando estiver em sua jornada de bioinfo e tiver problemas com algum programa você pode encontrar nessa sessão outras pessoas que podem ter passado pelo mesmo problema que você, e com sorte também encontrará uma solução ou "_workaround_". Se estiver confiante de que existe mesmo um bug fique a vontade para criar issues, sempre respeitando as sugestões que os autores do repositório. Ex: pode ser importante listar o sistema operacional que você está usando, ou a versão do programa que apresentou o problema, etc. Você pode conferir aqui um [exemplo de issue](https://github.com/broadinstitute/cromwell/issues/5592), note que é de 2020, outras pessoas disseram se tratar de um bug mas ainda assim não foi resolvido pois provavelmente não afeta muitos casos de uso.

* **_"Pull requests"_** são solicitações abertas para que um novo código, ou alterações no código existente, sejam mescladas à sua base de código. Normalmente é onde acontecem discussões sobre as mudanças com os envolvidos para que não entre nada que vá estragar o código existente em sua "linha de produção". [Veja este exemplo](https://github.com/openwdl/wdl/pull/438), onde um dos desenvolvedores propõem a adição de uma nova nota à uma errata e um revisor opina a respeito da mudança.

![image](https://user-images.githubusercontent.com/12699242/154550685-a058a069-6002-4a24-b5d3-27b1503da2d2.png)

Existe um botão escrito "_fork_" na parte superior direita desta tela. Você precisará clicar nele para copiar este repositório para sua conta, e assim realizar as alterações necessárias para posteriormente volta-las para cá, ou mesmo evolui-las em paralelo em um repositório controlado por você.

### Testes automáticos

