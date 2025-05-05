# Infraestrutura como Código (IaC) para Hospedagem de Site Estático na AWS S3

Este projeto provisiona uma infraestrutura de hospedagem de site estático com permissões públicas de leitura na AWS S3 usando Terraform. Também inclui um workflow do GitHub Actions para integração contínua (CI), então, sempre que você fizer um push neste repositório, as mudanças são testadas e o conteúdo da pasta `public/` é automaticamente enviado para o bucket.

## Dependências

- Terraform v1.10.5

## Pré-requisitos

### Para a Infraestrutura AWS

- Um domínio registrado com uma zona hospedada existente no Route 53  
- Terraform instalado e configurado com credenciais válidas da AWS

### Para o CI do GitHub Actions

- Configure os seguintes segredos no repositório do GitHub:
  - `AWS_ACCOUNT_ID`
  - `AWS_REGION`
  - `AWS_REGISTERED_DOMAIN`  
  Essas variáveis são necessárias no arquivo de workflow `deploy.yaml`.

## Recursos Criados na AWS

- **Dois Buckets S3**:
  - Um para o domínio raiz (ex: `example.com`) que redireciona para o segundo bucket
  - Um para o subdomínio `www` (ex: `www.example.com`), que hospeda o conteúdo do site

- **Registros no Route 53**:
  - Registros alias apontando para os buckets S3, criados dentro da zona hospedada existente

- **Função IAM**:
  - Configurada com OIDC e pode ser assumida pelo GitHub Actions para acesso seguro e de curta duração

## Como Usar

1. Defina as variáveis do Terraform em um arquivo `.tfvars` ou passe-as como argumentos no próximo passo.
2. Execute `terraform apply`. Esse passo é necessário para criar a função IAM e as permissões que permitem ao GitHub Actions fazer o deploy no seu bucket S3.
3. Atualize o arquivo `index.html` e faça push das alterações para a branch `main` para acionar o CI. O conteúdo da pasta `public/` será enviado para o bucket S3.
4. Pronto! Seu site estático estará funcionando no domínio registrado (`www.example.com` ou `example.com`).

## Aviso

Esta infraestrutura atualmente suporta apenas conexões **HTTP**. **Não use este setup para hospedar dados sensíveis ou privados.**

## Documentação de Referência

- [Documentação do Provider AWS no Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)  
- [Como usar funções IAM para conectar o GitHub Actions à AWS](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)  
- [GitHub: Configurando OIDC na AWS](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
