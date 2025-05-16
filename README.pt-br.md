# Infrastructure as Code (IaC) para Hospedagem de Site Estático na AWS S3 (Tradução pelo ChatGPT)

## Demo: https://dev.otaviocoding.click

Este projeto provisiona uma infraestrutura de hospedagem de site estático com permissões públicas de leitura na **AWS S3** usando **Terraform**.  
Também inclui um workflow do **GitHub Actions** para integração contínua (CI), de modo que toda vez que você fizer um push neste repositório, as alterações são testadas e o conteúdo da pasta `public/` é automaticamente implantado no bucket.

---

## 📦 Dependências

- Terraform v1.10.5

---

## ✅ Pré-requisitos

### Para a Infraestrutura AWS

- Credenciais válidas da AWS  
- Um domínio registrado `example.com` com uma **hosted zone** existente no **Route 53**  
- Um certificado emitido pelo **ACM (Amazon Certificate Manager)** para o domínio `*.example.com`  
- Sua **Hosted Zone** no Route 53 deve conter:
  - O registro CNAME do certificado
  - Registro **NS (Name Server)** e **SOA (Start of Authority)**  
    *(Se você comprou o domínio através do Route 53, a hosted zone será criada automaticamente com esses registros)*

### Para o GitHub Actions CI

- Defina os seguintes **repository secrets** no GitHub:
  - `AWS_ACCOUNT_ID`
  - `AWS_REGION`
  - `AWS_REGISTERED_DOMAIN`  

> Essas variáveis são utilizadas no arquivo de workflow `deploy.yaml`.

---

## ☁️ Recursos AWS criados após `terraform apply`

- **S3 Bucket**  
  - Um bucket para o subdomínio `www` (ex: `www.example.com`) onde o conteúdo do site será armazenado

- **Distribuição CloudFront**  
  - Uma distribuição **CloudFront** que servirá o `index.html` a partir do bucket S3 via conexão **HTTPS**

- **Registros Route 53**  
  - Registros **Alias** apontando de `subdomain.example.com` para a distribuição CloudFront, criados na **hosted zone** existente

- **IAM Role**  
  - Configurada com **OIDC**, pode ser assumida pelo **GitHub Actions** para acesso seguro e temporário

---

## 🚀 Como usar

1. Crie o arquivo `infra/.tfvars` com o seguinte conteúdo:
```hcl
registered_domain = "example.com"
acm_domain_name   = "*.example.com"
subdomain         = "dev"
aws_account_id    = <seu-aws-account-id>
github_account_id = "<seu-github-id>"
github_repo       = "<nome-do-repo-no-github>" 
```

2. Execute `terraform apply`  
   > Esse passo cria a **IAM Role** e as permissões que permitem ao GitHub Actions fazer deploy no S3.

3. Atualize o arquivo `index.html` e faça `git push` para a branch `main`  
   > O conteúdo da pasta `public/` será implantado automaticamente no bucket S3.

4. Pronto! Seu site estático estará rodando em `subdominio.example.com`

---

## 📚 Documentação de Referência

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)  
- [Use IAM Roles to Connect GitHub Actions to AWS](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)  
- [GitHub Docs: Configuring OIDC in AWS](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)