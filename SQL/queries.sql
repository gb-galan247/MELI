-- Punto 1: Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500.
-- Ponto 1: Liste os usuários com aniversário de hoje cujo número de vendas realizadas em janeiro de 2020 seja superior a 1.500.

SELECT c.name, c.last_name
FROM `ecommerce.CUSTOMER` c
INNER JOIN `ecommerce.ORDER` o ON c.customer_id = o.customer_id
WHERE DATE_DIFF(CURRENT_DATE(), DATE(c.birth_date), YEAR) = 0
  AND EXTRACT(MONTH FROM o.order_date) = 1
  AND EXTRACT(YEAR FROM o.order_date) = 2020
GROUP BY 1,2
HAVING COUNT(o.total) > 1500;

-- 2. Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, cantidad de productos vendidos y el monto total transaccionado. 
-- 2. Para cada mês de 2020 são solicitados os 5 principais usuários que mais venderam ($) na categoria Celulares. São obrigatórios o mês e ano da análise, nome e sobrenome do vendedor, quantidade de vendas realizadas, quantidade de produtos vendidos e valor total transacionado.
WITH monthly_sales AS (
  SELECT 
    EXTRACT(MONTH FROM o.order_date) AS mes,
    EXTRACT(YEAR FROM o.order_date) AS ano,
    c.name,
    c.last_name,
    COUNT(o.order_id) AS qtd_vendas,
    SUM(o.quantity) AS qtd_prod_vendidos,
    SUM(o.quantity * i.price) AS val_total_transacionado
  FROM `ecommerce.ORDER` o
  LEFT JOIN `ecommerce.ITEM` i ON o.item_id = i.item_id
  LEFT JOIN `ecommerce.CUSTOMER` c ON o.customer_id = c.customer_id
  LEFT JOIN `ecommerce.CATEGORY` cat ON i.category_id = cat.category_id and UPPER(cat.name) = 'CELULARES'
  WHERE EXTRACT(YEAR FROM o.order_date) = 2020
  GROUP BY mes, ano, c.name, c.last_name
)

SELECT 
  mes,
  ano,
  name,
  last_name,
  qtd_vendas,
  qtd_prod_vendidos,
  val_total_transacionado
FROM (
  SELECT 
    mes,
    ano,
    name,
    last_name,
    qtd_vendas,
    qtd_prod_vendidos,
    val_total_transacionado,
    ROW_NUMBER() OVER (PARTITION BY mes ORDER BY val_total_transacionado DESC) AS num_linha
  FROM monthly_sales
) AS classificado
WHERE num_linha <= 5;


-- 3. Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item, vamos a tener únicamente el último estado informado por la PK definida. (Se puede resolver a través de StoredProcedure) 
-- 3. É solicitada uma nova tabela a ser preenchida com o preço e status dos Itens no final do dia. Lembre-se de que deve ser reprocessável. Vale ressaltar que na tabela Item teremos apenas o último status informado pelo PK definido. (Pode ser resolvido através de StoredProcedure)
CREATE OR REPLACE PROCEDURE ecommerce.upd_status_item()
BEGIN

  -- Busca o publico a ser inserido hoje
  EXECUTE IMMEDIATE """
    CREATE TEMP TABLE TEMP_ITEM_STATUS_DAILY AS
    SELECT DISTINCT item_id, state, price, current_date() dt_processamento
    FROM `ecommerce.ITEM`
    WHERE low_date IS NULL-- filtrando apenas itens ativos
  """;

  -- Deleta os dados processados de hoje
  EXECUTE IMMEDIATE """
    DELETE FROM `ecommerce.ITEM_STATUS_DAILY`
    WHERE dt_processamento = current_date()
  """;

  -- Insere os registros na tabela final
  EXECUTE IMMEDIATE """
    INSERT INTO `ecommerce.ITEM_STATUS_DAILY`
    SELECT * FROM TEMP_ITEM_STATUS_DAILY
  """;

END;

-- chamada da procedure
call ecommerce.upd_status_item();