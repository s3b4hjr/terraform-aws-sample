# Implantação de Infraestrutura AWS com Timestream

Este repositório contém uma configuração Terraform para implantar uma infraestrutura na AWS, incluindo uma VPC com subnets públicas e privadas, um banco de dados Amazon Timestream e um usuário IAM para acesso externo. A documentação também inclui um exemplo de código Go para interagir com o Timestream.

## Estrutura do Projeto
terraform/
├── modules/
│   ├── vpc/                  # Módulo para criar VPC e subnets
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── timestream/           # Módulo para criar Timestream database e table
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam-user/             # Módulo para criar usuário IAM com acesso ao Timestream
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                   # Configuração principal
├── variables.tf              # Definição de variáveis
├── terraform.tfvars          # Valores padrão das variáveis
├── us-east-1.tfvars          # Configuração específica para us-east-1
├── backend.tf                # Configuração do backend S3
└── main.go                   # Exemplo de código Go para interagir com Timestream


## Pré-requisitos

- **Terraform**: Versão 1.0 ou superior instalado. [Download](https://www.terraform.io/downloads.html)
- **AWS CLI**: Configurado com credenciais de administrador para aplicar o Terraform. [Instalação](https://aws.amazon.com/cli/)
- **Go**: Versão 1.18 ou superior para o exemplo de código. [Download](https://golang.org/dl/)
- **Credenciais AWS**: Configure via `aws configure` ou variáveis de ambiente (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`). Criar profile tc-inv-hml com Access Key e Secret Key do 1password "tc-terraform | tc-inv-hml ". Usar essa key somente 

## Configuração

1. **Clone o repositório:**
   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd terraform

# Implantação
Inicialize o Terraform:

```bash
terraform init
```
# Planeje a infraestrutura:
```bash
terraform plan -var-file="us-east-1.tfvars"
```
# Aplique a configuração:
```bash
terraform apply -var-file="us-east-1.tfvars"
```

# Veja os outputs:
Após o apply, os outputs são exibidos. Para consultá-los novamente:
```bash
terraform output iam_user_name
terraform output -raw iam_access_key_id
terraform output -raw iam_secret_access_key
```
# Uso do Timestream com Go

Pré-requisitos
Instale as dependências do Go:

go mod init timestream-example
go get github.com/aws/aws-sdk-go-v2/config
go get github.com/aws/aws-sdk-go-v2/service/timestreamwrite
go get github.com/aws/aws-sdk-go-v2/service/timestreamquery

Configuração
Configure as credenciais do usuário IAM:

export AWS_ACCESS_KEY_ID=$(terraform output -raw iam_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw iam_secret_access_key)
export AWS_REGION="us-east-1"

Executar o código
Rode o exemplo em Go (main.go):

go run main.go

O código escreve um registro no Timestream (cpu_usage = 65.8) e consulta os dados da última hora.

Verificação
Use o AWS Console (Timestream > Query Editor) para verificar os dados:

SELECT region, host, measure_name, time, measure_value::double
FROM "example-timestream-db"."example-table"
WHERE measure_name = 'cpu_usage' AND time > ago(1h)

# Estrutura dos Recursos Criados
VPC: Uma VPC com subnets públicas (DMZ) e privadas (APP, BD, INFRA, etc.), incluindo Internet Gateway e NAT Gateway.
Timestream: Banco de dados cadastro com tabela audit-log.
IAM User: Usuário timestream-app-user com permissões para escrever e consultar o Timestream.

# Notas
Segurança: Armazene as credenciais do IAM de forma segura e evite expô-las em logs ou repositórios públicos.
Custo: O Timestream, NAT Gateway e outros recursos geram custos na AWS. Monitore via AWS Cost Explorer.
Personalização: Ajuste os CIDRs, nomes ou retenção do Timestream em us-east-1.tfvars conforme necessário.
