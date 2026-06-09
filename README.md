# IDelivery

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![.NET](https://img.shields.io/badge/.NET-9.0-512BD4)
![React](https://img.shields.io/badge/React-19-61DAFB)
![Vite](https://img.shields.io/badge/Vite-8-646CFF)
![Docker](https://img.shields.io/badge/Docker-ready-2496ED)

IDelivery é uma aplicação full stack para delivery de alimentos, composta por uma API em **ASP.NET Core/.NET 9** e um frontend em **React + Vite**. O projeto implementa fluxos de autenticação, restaurantes, produtos, carrinho, pedidos, pagamento, entregas, cupons e avaliações.

---

## Sumário

- [Visão geral](#visão-geral)
- [Tecnologias](#tecnologias)
- [Funcionalidades](#funcionalidades)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Configuração de ambiente](#configuração-de-ambiente)
- [Como executar com Docker](#como-executar-com-docker)
- [Como executar em desenvolvimento](#como-executar-em-desenvolvimento)
- [Testes](#testes)
- [Regras de negócio](#regras-de-negócio)
- [Rotas principais da API](#rotas-principais-da-api)
- [Autor](#autor)

---

## Visão geral

O IDelivery simula uma plataforma de pedidos online no estilo iFood, separando responsabilidades por tipo de usuário:

- **Cliente:** navega por restaurantes, adiciona produtos ao carrinho e cria pedidos.
- **Restaurante:** gerencia pedidos e produtos.
- **Entregador:** acompanha e atualiza entregas.
- **Administrador:** possui acesso ampliado para gerenciamento do sistema.

A API segue uma organização em camadas, com foco em regras de domínio, serviços de aplicação, persistência e infraestrutura.

---

## Tecnologias

### Backend

- **.NET 9**
- **ASP.NET Core Web API**
- **Entity Framework Core**
- **PostgreSQL**
- **JWT Authentication**
- **Roles e autorização**
- **Swagger/OpenAPI**
- **AutoMapper**
- **xUnit**

### Frontend

- **React 19**
- **Vite**
- **React Router DOM**
- **CSS**
- **Nginx para build em produção**

### DevOps / Infra

- **Docker**
- **Docker Compose**
- **PostgreSQL 17 Alpine**
- Serviço separado para arquivos em `uploads`

---

## Funcionalidades

- Cadastro e login de usuários.
- Autenticação com JWT.
- Refresh token.
- Controle de permissões por perfil:
  - `Admin`
  - `Customer`
  - `RestaurantOwner`
  - `DeliveryDriver`
- Listagem de restaurantes.
- Listagem de categorias.
- Página pública de restaurante.
- Página pública de produto.
- Carrinho global.
- Criação de pedidos.
- Cadastro de endereço de entrega.
- Fluxo de pagamento.
- Fluxo de entrega.
- Cupons de desconto.
- Reviews/avaliações.
- Testes automatizados para regras de negócio e cobertura de endpoints.

---

## Estrutura do projeto

```text
IDelivery_/
├── Frontend/
│   ├── public/
│   ├── src/
│   │   ├── assets/
│   │   ├── App.jsx
│   │   ├── App.css
│   │   ├── index.css
│   │   └── main.jsx
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   └── vite.config.js
│
├── IDelivery/
│   ├── IDelivery/
│   │   ├── API/
│   │   ├── Application/
│   │   │   ├── DTOs/
│   │   │   ├── IServices/
│   │   │   ├── Services/
│   │   │   ├── UseCases/
│   │   │   └── Mappings/
│   │   ├── Domain/
│   │   │   ├── Entities/
│   │   │   ├── ValueObjects/
│   │   │   └── Interfaces/
│   │   ├── Infrastructure/
│   │   ├── Persistence/
│   │   ├── scripts/
│   │   ├── Dockerfile
│   │   ├── Program.cs
│   │   └── IDelivery.csproj
│   │
│   ├── IDelivery.Tests/
│   ├── IDelivery.sln
│   └── README.md
│
├── uploads/
├── backups/
├── docker-compose.yml
├── .gitignore
└── .env.example
```

---

## Pré-requisitos

Para rodar o projeto localmente, instale:

- [.NET SDK 9](https://dotnet.microsoft.com/)
- [Node.js](https://nodejs.org/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- PostgreSQL, caso rode sem Docker

---

## Configuração de ambiente

Crie um arquivo `.env` na raiz do projeto.

Exemplo recomendado:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=idelivery
IDENTITY_DB_NAME=idelivery_identity
DELIVERY_DB_NAME=idelivery_delivery

ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_URLS=http://+:8080

Jwt__Issuer=IDelivery
Jwt__Audience=IDelivery.Client
Jwt__Key=CHANGE_THIS_TO_A_32_PLUS_CHAR_SECRET_KEY

Cors__AllowedOrigins=http://localhost:5173;http://localhost:5174;http://localhost:8080;http://localhost

Payments__WebhookSecret=CHANGE_THIS_TO_A_LONG_RANDOM_WEBHOOK_SECRET

ADMIN_EMAIL=admin@idelivery.local
ADMIN_PASSWORD=CHANGE_THIS_TO_A_STRONG_PASSWORD

CUSTOMER_EMAIL=customer@idelivery.local
CUSTOMER_PASSWORD=CHANGE_THIS_TO_A_STRONG_PASSWORD

RESTAURANT_OWNER_EMAIL=owner@idelivery.local
RESTAURANT_OWNER_PASSWORD=CHANGE_THIS_TO_A_STRONG_PASSWORD

DELIVERY_DRIVER_EMAIL=driver@idelivery.local
DELIVERY_DRIVER_PASSWORD=CHANGE_THIS_TO_A_STRONG_PASSWORD

VITE_API_BASE_URL=http://localhost:5175
```

> Nunca suba o arquivo `.env` real para o GitHub.

---

## Como executar com Docker

Na raiz do projeto, execute:

```bash
docker compose up --build
```

Para rodar em segundo plano:

```bash
docker compose up -d --build
```

Para parar:

```bash
docker compose down
```

Para remover volumes, incluindo dados do banco:

```bash
docker compose down -v
```

### Observação sobre portas

Se o `docker-compose.yml` não estiver expondo portas para o host, adicione algo parecido com isto:

```yml
api:
  ports:
    - "5175:8080"

frontend:
  ports:
    - "5173:80"

uploads:
  ports:
    - "8081:80"
```

Depois disso, os acessos principais ficam:

- Frontend: `http://localhost:5173`
- API: `http://localhost:5175`
- Swagger: `http://localhost:5175/swagger`

---

## Como executar em desenvolvimento

### 1. Clonar o repositório

```bash
git clone https://github.com/Lucas-Bozyk/IDelivery_.git
cd IDelivery_
```

### 2. Rodar o backend

Entre na pasta da solução:

```bash
cd IDelivery
```

Restaure os pacotes:

```bash
dotnet restore IDelivery.sln
```

Execute a API:

```bash
dotnet run --project IDelivery/IDelivery.csproj
```

A API ficará disponível na porta configurada pelo projeto.

Swagger:

```text
http://localhost:<porta>/swagger
```

### 3. Rodar o frontend

Em outro terminal, volte para a raiz do projeto e entre na pasta do frontend:

```bash
cd Frontend
```

Instale as dependências:

```bash
npm install
```

Rode em modo desenvolvimento:

```bash
npm run dev
```

O Vite normalmente sobe em:

```text
http://localhost:5173
```

---

## Testes

Para rodar os testes do backend:

```bash
cd IDelivery
dotnet test IDelivery.Tests/IDelivery.Tests.csproj
```

O projeto possui testes para:

- autenticação;
- rate limiting;
- regras de negócio;
- validação de entrada;
- cobertura de endpoints.

---

## Regras de negócio

Algumas regras implementadas no domínio:

- Produto indisponível não pode ser adicionado ao carrinho.
- Carrinho e pedido devem conter produtos de um único restaurante.
- Restaurante fechado não deve receber pedido.
- Pedido calcula subtotal, taxa, desconto e total.
- Cupom valida expiração, valor mínimo e limite de uso.
- Pagamento aprovado confirma o pedido.
- Pedido cancelado não deve seguir para entrega.
- Entrega só pode ser concluída com pagamento aprovado.
- Review só pode ser feita para pedido concluído.

---

## Rotas principais da API

Algumas rotas utilizadas pelo frontend:

```text
POST   /api/auth/login
POST   /api/auth/register
POST   /api/auth/refresh-token
POST   /api/auth/logout

GET    /api/restaurants
GET    /api/restaurants/{id}
GET    /api/restaurants/{id}/products
GET    /api/restaurants/{id}/reviews

GET    /api/products/{id}

GET    /api/cart
POST   /api/cart/items
DELETE /api/cart

GET    /api/orders
POST   /api/orders

POST   /api/customers/addresses

GET    /api/restaurant-categories
```

---

## Build de produção do frontend

Dentro da pasta `Frontend`:

```bash
npm run build
```

Para visualizar o build localmente:

```bash
npm run preview
```

---


---

## Autor

Projeto desenvolvido por **Lucas Bozyk**.

Repositório: `Lucas-Bozyk/IDelivery_`
