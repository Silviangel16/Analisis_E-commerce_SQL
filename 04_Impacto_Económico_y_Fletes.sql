-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
-- by: Silvia Angel 
-- ====================================================================

-- ====================================================================
-- Parte 4: Impacto Económico - Valor de Órdenes, Crecimiento e Costo de Fletes
-- ====================================================================

-- 4.1 Obtener el % de incremento en el costo de los pedidos de 2017 a 2018 (Solo periodo Enero - Agosto)
WITH total_costos AS (
  SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS anio_pedido,
    ROUND(SUM(p.payment_value), 2) AS costo_total_pedidos
  FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o 
  JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_order_payments_dataset` p
    ON o.order_id = p.order_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
    AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 01 AND 08
  GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp)
), 
calculo_lag AS (
  SELECT
    anio_pedido,
    costo_total_pedidos,
    LAG(costo_total_pedidos) OVER (ORDER BY anio_pedido) AS costo_anio_anterior
  FROM total_costos
)
SELECT
  anio_pedido,
  costo_total_pedidos,
  costo_anio_anterior,
  ROUND((costo_total_pedidos - costo_anio_anterior) / costo_anio_anterior * 100, 2) AS porcentaje_crecimiento
FROM calculo_lag
ORDER BY anio_pedido;

-- 4.2 Calcular el valor Total y Promedio de las órdenes para cada estado
SELECT 
  c.customer_state AS estado_cliente,
  ROUND(SUM(i.price), 2) AS valor_total_ordenes,
  ROUND(AVG(i.price), 2) AS valor_promedio_ordenes
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o
JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_order_items_dataset` i ON i.order_id = o.order_id
JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset` c ON c.customer_id = o.customer_id
GROUP BY c.customer_state;

-- 4.3 Calcular el valor Total y Promedio del costo del flete para cada estado
WITH resumen_flete AS (
  SELECT 
    order_id,
    c.customer_state,
    SUM(freight_value) AS valor_total_flete
  FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o
  JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_order_items_dataset` i USING (order_id)
  JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset` c USING (customer_id)
  GROUP BY order_id, c.customer_state
)
SELECT 
  customer_state AS estado_cliente,
  ROUND(SUM(valor_total_flete), 2) AS costo_total_flete,
  ROUND(AVG(valor_total_flete), 2) AS costo_promedio_flete
FROM resumen_flete
GROUP BY customer_state
ORDER BY costo_total_flete DESC;
