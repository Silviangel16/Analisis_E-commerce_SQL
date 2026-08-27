-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
-- by: Silvia Angel 
-- ====================================================================

-- ====================================================================
-- Parte 2: Tendencias de Pedidos y Análisis de Estacionalidad
-- ====================================================================

-- 2.1 ¿Existe una tendencia de crecimiento en el número de pedidos a lo largo de los años?
SELECT 
  EXTRACT(YEAR FROM order_purchase_timestamp) AS anio,
  COUNT(order_id) AS total_pedidos
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset`
GROUP BY EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY anio;

-- 2.2 ¿Existe algún tipo de estacionalidad mensual en el número de pedidos realizados?
SELECT
  FORMAT_DATE('%B', order_purchase_timestamp) AS mes,
  COUNT(order_id) AS total_pedidos
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset`
GROUP BY FORMAT_DATE('%B', order_purchase_timestamp),
  EXTRACT(MONTH FROM order_purchase_timestamp)
ORDER BY EXTRACT(MONTH FROM order_purchase_timestamp);

-- 2.3 ¿En qué momento del día realizan sus pedidos la mayoría de los clientes brasileños?
-- Categorización:
-- 0-6 hrs  : Madrugada (Dawn)
-- 7-12 hrs : Mañana (Morning)
-- 13-18 hrs: Tarde (Afternoon)
-- 19-23 hrs: Noche (Night)
WITH horas AS (
  SELECT 
    order_id,
    EXTRACT(HOUR FROM order_purchase_timestamp) AS hora_compra
  FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset`
),
momento_dia AS (
  SELECT
    order_id,
    CASE 
      WHEN hora_compra BETWEEN 0 AND 6 THEN 'Madrugada'
      WHEN hora_compra BETWEEN 7 AND 12 THEN 'Mañana'
      WHEN hora_compra BETWEEN 13 AND 18 THEN 'Tarde'
      ELSE 'Noche' 
    END AS franja_horaria
  FROM horas
)
SELECT 
  franja_horaria,
  COUNT(order_id) AS total_pedidos
FROM momento_dia
GROUP BY franja_horaria
ORDER BY
  CASE 
    WHEN franja_horaria = 'Madrugada' THEN 1
    WHEN franja_horaria = 'Mañana' THEN 2
    WHEN franja_horaria = 'Tarde' THEN 3
    ELSE 4 
  END;

