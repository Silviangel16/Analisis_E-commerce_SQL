-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
-- By: Silvia Angel
-- ====================================================================

-- ====================================================================
-- Parte 1: Estructura del Dataset, Esquema y Exploración Inicial
-- ====================================================================

-- 1.1 Esquema de las tablas
-- Pregunta: ¿qué columnas y tipos de datos tiene cada tabla?
SELECT table_name, column_name, data_type
FROM `brazilian-e-commerce-511503.ecommerce_data.INFORMATION_SCHEMA.COLUMNS`
ORDER BY table_name, ordinal_position;

-- 1.2 Granularidad: pedidos vs. clientes
-- Pregunta: ¿cuántos pedidos y cuántos clientes reales hay?
-- Supuesto: customer_id es único por pedido; para contar personas se usa customer_unique_id.
SELECT
  COUNT(*) AS filas,
  COUNT(DISTINCT customer_id) AS customer_id_distintos,
  COUNT(DISTINCT customer_unique_id) AS clientes_unicos
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset`;

-- 1.3 Cobertura temporal
-- Pregunta: ¿qué periodo cubren los pedidos y cuántos llegaron a estado 'delivered'?
SELECT
  COUNT(*) AS total_ordenes,
  COUNTIF(order_status = 'delivered') AS ordenes_entregadas,
  MIN(DATE(order_purchase_timestamp)) AS primer_pedido,
  MAX(DATE(order_purchase_timestamp)) AS ultimo_pedido
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset`;


-- 1.4 Pedidos por mes
-- Pregunta: ¿cómo se distribuye el volumen en el tiempo y qué meses tienen datos completos?        
SELECT
  FORMAT_DATE('%Y-%m', DATE(order_purchase_timestamp)) AS anio_mes,
  COUNT(*) AS total_ordenes
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset`
GROUP BY anio_mes
ORDER BY anio_mes;


-- 1.5 Alcance geográfico
-- Pregunta: ¿en cuántos estados y ciudades hay clientes?
-- Supuesto: se cuenta la pareja ciudad-estado porque hay ciudades con el mismo nombre en estados distintos.
SELECT
  COUNT(DISTINCT customer_state) AS total_estados,
  COUNT(DISTINCT CONCAT(customer_city, '-', customer_state)) AS total_ciudades
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset`;