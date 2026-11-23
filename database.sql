CREATE DATABASE IF NOT EXISTS loja_checkout CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE loja_checkout;

CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT,
    preco_centavos INT NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE pedidos (
    id VARCHAR(36) PRIMARY KEY,
    comprador VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    cpf VARCHAR(14) NOT NULL,
    total_centavos INT NOT NULL,
    status ENUM('pendente', 'aprovado', 'recusado', 'expirado', 'cancelado') DEFAULT 'pendente',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE itens_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id VARCHAR(36) NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario_centavos INT NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

CREATE TABLE pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id VARCHAR(36) NOT NULL,
    provedor VARCHAR(50) NOT NULL,
    id_externo VARCHAR(100) UNIQUE NOT NULL,
    metodo VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL,
    checkout_url TEXT,
    qr_code TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
);

CREATE TABLE eventos_pagamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id VARCHAR(100) UNIQUE NOT NULL,
    referencia_externa VARCHAR(100) NOT NULL,
    tipo_evento VARCHAR(50) NOT NULL,
    payload_sanitizado JSON,
    recebido_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Carga inicial de produtos
INSERT INTO produtos (nome, descricao, preco_centavos, ativo) VALUES
('Fone de Ouvido Bluetooth ANC', 'Cancelamento de ruído ativo, bateria 30h', 29990, TRUE),
('Teclado Mecânico RGB 65%', 'Switch Brown, layout ABNT2, cabo USB-C', 34900, TRUE),
('Mouse Gamer Sem Fio 26K DPI', 'Sensor óptico de alta precisão, 60g', 21950, TRUE),
('Hub USB-C 7 em 1', 'HDMI 4K, PD 100W, 3x USB 3.0 e leitor SD', 14990, TRUE);
