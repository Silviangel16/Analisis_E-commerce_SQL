-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
-- by: Silvia Angel 
-- ====================================================================

-- ====================================================================
-- Parte 1: Estructura del Dataset, Esquema y Exploración Inicial
-- ====================================================================

-- 1.1 Obtener los tipos de datos de todas las columnas de la tabla "customers"
SELECT *
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset`;

-- 1.2 Obtener el rango de horas y patrones diarios en los que se realizaron los pedidos
SELECT
  FORMAT_DATE('%a', order_purchase_timestamp) AS dia_semana,
  MIN(EXTRACT(TIME FROM order_purchase_timestamp)) AS primera_hora_pedido,
  MAX(EXTRACT(TIME FROM order_purchase_timestamp)) AS ultima_hora_pedido,
  AVG(EXTRACT(HOUR FROM order_purchase_timestamp)) AS hora_promedio_pedido
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset`
WHERE order_status = 'delivered'
GROUP BY FORMAT_DATE('%a', order_purchase_timestamp);

-- 1.2 (Cont.) Obtener el rango de fechas en el que se realizaron las órdenes
SELECT 
  MAX(DATE(order_purchase_timestamp)) AS ultimo_pedido_realizado,
  MIN(DATE(order_purchase_timestamp)) AS primer_pedido_realizado,
  DATE_DIFF(MAX(DATE(order_purchase_timestamp)),
            MIN(DATE(order_purchase_timestamp)), MONTH) AS duracion_meses_pedidos
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset`
WHERE order_status = 'delivered';

-- 1.3 Contar las ciudades y estados distintos de los clientes que ordenaron durante el periodo
SELECT 
  COUNT(DISTINCT c.customer_state) AS total_estados,
  COUNT(DISTINCT c.customer_city) AS total_ciudades
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset` c 
JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o
  ON c.customer_id = o.customer_id;
