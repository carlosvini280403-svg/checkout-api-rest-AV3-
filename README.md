# Checkout Web Integrado — API RESTful com Padrões de Projeto

Projeto desenvolvido para a disciplina **Construção e Integração de APIs RESTful com Padrões de Projeto** (Prof. Daniel Martins).

## 1. Como Executar Localmente
1. Instale o Node.js (v18+).
2. No terminal, dentro da pasta do projeto, instale as dependências:
   ```bash
   npm install
   ```
3. (Opcional) Insira seu `MP_ACCESS_TOKEN` de teste do Mercado Pago no arquivo `.env`. Caso fique em branco, a aplicação utiliza o **Modo Sandbox Controlado** para demonstração offline/local.
4. Inicie o servidor:
   ```bash
   npm start
   ```
5. Acesse no navegador: `http://localhost:3000`

## 2. Diagrama de Arquitetura e Fluxo de Pagamento

```text
[ Navegador (Frontend) ]
        │  1. POST /api/pedidos (itens, comprador, método)
        ▼
[ API RESTful (Express) ]
        │  2. Valida itens no DB e calcula total em centavos (RF02)
        │  3. Persiste Pedido e Itens (status: pendente) (RF03)
        ▼
[ PaymentGateway (Adapter) ] ───► [ Provedor Externo (Mercado Pago / Sandbox) ]
        │  4. Retorna id_externo, checkout_url e QR Code Pix (RF04/RF05)
        ▼
[ Banco de Dados Relacional ] ◄── 5. POST /api/webhooks/pagamentos (Idempotente - RF07)
                                  6. GET /api/pedidos/:id (Consulta ativa - RF06)
```

## 3. Documentação dos Endpoints da API

| Método | Endpoint | Descrição |
| :--- | :--- | :--- |
| `GET` | `/api/produtos` | Lista todos os produtos ativos do catálogo com valores em centavos (RF01). |
| `POST` | `/api/pedidos` | Valida carrinho, recalcula subtotal + frete no backend, grava pedido e inicia pagamento no provedor (RF02–RF05). |
| `GET` | `/api/pedidos` | Lista os últimos pedidos registrados e seus status atuais. |
| `GET` | `/api/pedidos/:id` | Consulta detalhes do pedido e sincroniza status ativo com o provedor (RF06). |
| `POST` | `/api/webhooks/pagamentos` | Recebe notificações assíncronas de mudança de status com chave de idempotência `event_id` (RF07). |

## 4. Decisões de Projeto, Segurança e Limitações
* **Valores Monetários em Centavos (`INTEGER`/`INT`):** Evita erros de arredondamento de ponto flutuante (`FLOAT`/`DOUBLE`) em cálculos financeiros.
* **Cálculo Exclusivo no Servidor:** O frontend envia apenas `produto_id` e `quantidade`; os preços unitários são buscados diretamente no banco de dados.
* **Padrão Adapter (`src/gateways/paymentGateway.js`):** Desacopla a regra de negócio da API específica do provedor, permitindo trocar Mercado Pago por InfinitePay ou Asaas sem alterar as rotas.
* **Idempotência no Webhook:** A tabela `eventos_pagamento` possui restrição `UNIQUE` em `event_id`, garantindo que reentregas de webhook não dupliquem confirmações.
* **Segurança:** Nenhum dado de cartão de crédito ou CVV trafega ou é armazenado no backend; credenciais ficam isoladas em `.env`.
