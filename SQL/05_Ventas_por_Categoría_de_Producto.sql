-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
-- by: Silvia Angel 
-- ====================================================================

-- ====================================================================
-- Parte 5: Análisis de Ventas por Categoría de Producto 
-- ====================================================================

-- 5.1 ¿Qué categorías de producto generan más ingresos y cuánto pesa cada una?
-- Supuestos: ingresos = suma de price (productos, sin flete); se incluyen todos los estados de pedid.
SELECT 
  COALESCE(p.product_category_name, 'Desconocido') AS categoria_producto,
  COUNT(*) AS total_articulos_vendidos,
  ROUND(SUM(i.price), 2) AS ingresos_totales,
  ROUND(100 * SUM(i.price) / SUM(SUM(i.price)) OVER (), 1) AS pct_ingresos,
  ROUND(AVG(i.price), 2) AS precio_promedio_articulo
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_order_items_dataset` i
JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_products_dataset` p 
  ON i.product_id = p.product_id
GROUP BY categoria_producto
ORDER BY ingresos_totales DESC
LIMIT 15;

