-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
-- by: Silvia Angel 
-- ====================================================================

-- ====================================================================
-- Parte 4: Métodos de Pago y Análisis de Cuotas
-- ====================================================================

-- 4.1 ¿Qué métodos de pago usan los clientes y con qué frecuencia?
-- Supuesto: un pedido puede usar más de un método de pago.
SELECT
  payment_type AS tipo_pago,
  COUNT(DISTINCT order_id) AS total_pedidos,
  ROUND(100 * COUNT(DISTINCT order_id) /
    (SELECT COUNT(DISTINCT order_id)
     FROM `brazilian-e-commerce-511503.ecommerce_data.olist_order_payments_dataset`), 1) AS pct_pedidos
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_order_payments_dataset`
GROUP BY payment_type
ORDER BY total_pedidos DESC;


-- 4.2 ¿Cómo se distribuyen los pagos con tarjeta de crédito según el número de cuotas?
-- Supuesto: se cuentan pagos (un pedido puede tener más de uno); solo tarjeta de crédito.
SELECT
  CASE
    WHEN payment_installments <= 1 THEN '1. Una cuota (pago único)'
    WHEN payment_installments <= 3 THEN '2. 2 a 3 cuotas'
    WHEN payment_installments <= 6 THEN '3. 4 a 6 cuotas'
    WHEN payment_installments <= 10 THEN '4. 7 a 10 cuotas'
    ELSE '5. Más de 10 cuotas'
  END AS rango_cuotas,
  COUNT(*) AS total_pagos,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_pagos,
  ROUND(AVG(payment_value), 2) AS valor_promedio_pago
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_order_payments_dataset`
WHERE payment_type = 'credit_card'
GROUP BY rango_cuotas
ORDER BY rango_cuotas;
