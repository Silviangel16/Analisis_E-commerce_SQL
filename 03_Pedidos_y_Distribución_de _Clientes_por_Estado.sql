-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
-- by: Silvia Angel 
-- ====================================================================

-- ====================================================================
-- Parte 3: Evolución de Pedidos y Distribución de Clientes por Estado
-- ====================================================================

-- 3.1 Obtener el número de pedidos mes a mes por cada estado
SELECT
  c.customer_state AS estado_cliente,
  FORMAT_DATETIME('%Y-%m', o.order_purchase_timestamp) AS mes_pedido,
  COUNT(o.order_id) AS total_pedidos
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset` c 
JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o
  ON c.customer_id = o.customer_id
GROUP BY
  c.customer_state,
  FORMAT_DATETIME('%Y-%m', o.order_purchase_timestamp)
ORDER BY c.customer_state, mes_pedido;

-- 3.2 ¿Cómo se distribuyen los clientes entre todos los estados?
SELECT 
  customer_state AS estado_cliente,
  COUNT(customer_unique_id) AS total_clientes_unicos
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset`
GROUP BY customer_state
ORDER BY total_clientes_unicos DESC;
