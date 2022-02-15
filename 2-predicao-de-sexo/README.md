# Predição de sexo


## Descrição

Neste workflow temos como objetivo realizar a predição do sexo biológico da amostra analisada. Utilizaremos duas abordagens:

- Razão de heterozigotos no cromossomo X: é esperado que tenham menos sitios heterozigotos em amostras de origem masculina pois existe apenas uma cópia do cromossomo X.
- Leituras alinhadas na região SRY do cromossomo Y: apenas amostras de origem masculina apresentam boa cobertura na região SRY do cromossomo Y.

Verificações como estas importantes pois podem ocorrer trocas de amostras - seja em laboratório parceiro ou em seu próprio. Se a troca for de amostra masculina por masculina ainda será um problema, mas caso ocorra uma troca entre homem/mulher este controle de qualidade irá alerta-lo do problema (desde que você tenha também o sexo cadastrado).


## Etapas

CountVariants: aplica a ferramenta bcftools para contar o número de heterozigotos e de homozigotos no cromossomo X das amostras avaliadas.

CalculateCoverages: utiliza a ferramenta mosdepth para verificar a cobertura horizontal sobre a região SRY do cromossomo Y.

ClassifySex: carrega os valores calculados nas etapas anteriores para classificar cada uma das amostras como de origem masculina ou feminina. Usamos um pequeno script com Python aqui.
