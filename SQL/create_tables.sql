-- considerando a nao criacao das chaves primarias e estrangeiras por conta do uso no BigQuery
-- considerando que o dataset ecommerce esta criado
-- criacao tabela de cliente
CREATE OR REPLACE TABLE ecommerce.CUSTOMER (
    customer_id INT64 NOT NULL,
    name STRING,
    last_name STRING,
    sex STRING,
    email STRING,
    birth_date DATE,
    address STRING,
    phone STRING
);

-- criacao tabela de categoria
CREATE OR REPLACE TABLE ecommerce.CATEGORY (
    category_id INT64 NOT NULL,
    name STRING,
    path STRING
);

-- criacao tabela de item
CREATE OR REPLACE TABLE ecommerce.ITEM (
    item_id INT64 NOT NULL,
    item_name STRING,
    description STRING,
    price NUMERIC,
    state STRING,
    low_date DATE,
    category_id INT64
);
-- criacao tabela de order
CREATE OR REPLACE TABLE ecommerce.ORDER (
    order_id INT64 NOT NULL,
    order_date DATE ,
    total NUMERIC,
    quantity INT64,
    customer_id INT64,
    item_id INT64
);
-- criacao tabela de preço e status dos Itens no final do dia
CREATE OR REPLACE TABLE ecommerce.ITEM_STATUS_DAILY (
    item_id INT64,
    state STRING,
    price NUMERIC,
    dt_processamento DATE
);
