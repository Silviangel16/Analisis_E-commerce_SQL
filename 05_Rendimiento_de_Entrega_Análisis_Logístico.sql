-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
-- by: Silvia Angel 
-- ====================================================================

-- ====================================================================
-- Parte 5: Rendimiento de Entrega y Análisis Logístico
-- ====================================================================

-- 5.1 Tiempo de entrega (días) y diferencia entre la fecha estimada vs. la fecha de entrega real
SELECT 
  order_id,
  DATE(order_purchase_timestamp) AS fecha_compra,
  DATE(order_delivered_customer_date) AS fecha_entrega_cliente,
  DATE(order_estimated_delivery_date) AS fecha_estimada_entrega,
  DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS dias_para_entregar,
  DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS diferencia_dias_estimado
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset`
WHERE order_delivered_customer_date IS NOT NULL;

-- 5.2 Top 5 estados con el valor promedio de flete Más Alto y Más Bajo (usando DENSE_RANK)
WITH fletes_orden AS (
  SELECT 
    order_id,
    c.customer_state,
    ROUND(SUM(i.freight_value), 2) AS costo_flete_orden
  FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o
  JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_order_items_dataset` i USING (order_id)
  JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset` c USING (customer_id)
  GROUP BY order_id, customer_state
),
ranking_fletes AS (
  SELECT 
    customer_state,
    ROUND(AVG(costo_flete_orden), 2) AS flete_promedio_total,
    DENSE_RANK() OVER (ORDER BY AVG(costo_flete_orden) DESC) AS rank_altos,
    DENSE_RANK() OVER (ORDER BY AVG(costo_flete_orden)) AS rank_bajos
  FROM fletes_orden
  GROUP BY customer_state
  ORDER BY flete_promedio_total DESC
)
SELECT 
  customer_state AS estado_cliente,
  flete_promedio_total,
  CASE
    WHEN rank_altos <= 5 THEN 'Top 5 Más Alto'
    WHEN rank_bajos <= 5 THEN 'Top 5 Más Bajo'
  END AS categoria_rank
FROM ranking_fletes
WHERE rank_altos <= 5 OR rank_bajos <= 5
ORDER BY flete_promedio_total DESC;

-- 5.3 Top 5 estados con el tiempo promedio de entrega Más Alto y Más Bajo
WITH tiempos_entrega AS (
  SELECT
    o.order_id,
    c.customer_state,
    DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS dias_entrega
  FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o
  JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset` c USING (customer_id)
  WHERE order_delivered_customer_date IS NOT NULL
),
ranking_tiempos AS (
  SELECT
    customer_state,
    ROUND(AVG(dias_entrega), 2) AS tiempo_promedio_entrega,
    DENSE_RANK() OVER (ORDER BY AVG(dias_entrega) DESC) AS rank_lentos,
    DENSE_RANK() OVER (ORDER BY AVG(dias_entrega)) AS rank_rapidos
  FROM tiempos_entrega
  GROUP BY customer_state
)
SELECT 
  customer_state AS estado_cliente,
  tiempo_promedio_entrega,
  CASE
    WHEN rank_lentos <= 5 THEN 'Top 5 Más Lentos'
    WHEN rank_rapidos <= 5 THEN 'Top 5 Más Rápidos'
  END AS categoria_rank
FROM ranking_tiempos
WHERE rank_lentos <= 5 OR rank_rapidos <= 5
ORDER BY tiempo_promedio_entrega DESC;

-- 5.4 Top 5 estados donde la entrega de pedidos fue más rápida que la fecha estimada
WITH diferencia_dias AS (
  SELECT
    o.order_id,
    c.customer_state,
    DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS dias_diferencia
  FROM `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset` c 
  JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o USING (customer_id)
  WHERE order_delivered_customer_date IS NOT NULL
), 
ranking_anticipacion AS (
  SELECT
    customer_state,
    ROUND(AVG(dias_diferencia), 2) AS promedio_dias_anticipacion,
    DENSE_RANK() OVER (ORDER BY AVG(dias_diferencia)) AS rank_rapidez
  FROM diferencia_dias
  GROUP BY customer_state
)
SELECT
  customer_state AS estado_cliente,
  promedio_dias_anticipacion,
  rank_rapidez AS top_5_entregas_mas_rapidas
FROM ranking_anticipacion
WHERE rank_rapidez <= 5
ORDER BY promedio_dias_anticipacion;