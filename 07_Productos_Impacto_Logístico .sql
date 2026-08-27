-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
-- by: Silvia Angel 
-- ====================================================================

-- ====================================================================
-- Parte 7: Catálogo de Productos e Impacto Logístico 
-- ====================================================================

-- 7.1 Rendimiento por Categoría: Volumen de Ventas e Ingresos por Categoría de Producto
SELECT 
    COALESCE(p.product_category_name, 'Desconocido') AS categoria_producto,
    COUNT(i.order_item_id) AS total_articulos_vendidos,
    ROUND(SUM(i.price), 2) AS ingresos_totales,
    ROUND(AVG(i.price), 2) AS precio_promedio_producto
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_order_items_dataset` i
JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_products_dataset` p 
    ON i.product_id = p.product_id
GROUP BY categoria_producto
ORDER BY ingresos_totales DESC
LIMIT 15;

-- 7.2 Impacto Logístico: Peso del Producto vs. Retrasos en el Envío
WITH retrasos_articulos AS (
    SELECT 
        o.order_id,
        i.product_id,
        p.product_weight_g,
        DATE_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY) AS dias_retraso,
        DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS dias_totales_entrega
    FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o
    JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_order_items_dataset` i 
        ON o.order_id = i.order_id
    JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_products_dataset` p 
        ON i.product_id = p.product_id
    WHERE o.order_delivered_customer_date IS NOT NULL 
      AND o.order_estimated_delivery_date IS NOT NULL
),
rangos_peso AS (
    SELECT 
        CASE 
            WHEN product_weight_g <= 500 THEN '1. 0 - 500g (Muy ligero)'
            WHEN product_weight_g <= 1500 THEN '2. 500g - 1.5kg (Ligero)'
            WHEN product_weight_g <= 5000 THEN '3. 1.5kg - 5kg (Mediano)'
            WHEN product_weight_g <= 15000 THEN '4. 5kg - 15kg (Pesado)'
            ELSE '5. > 15kg (Muy pesado)'
        END AS rango_peso,
        dias_retraso,
        dias_totales_entrega
    FROM retrasos_articulos
)
SELECT 
    rango_peso,
    COUNT(*) AS total_pedidos_analizados,
    ROUND(AVG(dias_totales_entrega), 2) AS promedio_dias_entrega_total,
    ROUND(AVG(dias_retraso), 2) AS promedio_dias_retraso,
    ROUND(100.0 * COUNT(CASE WHEN dias_retraso > 0 THEN 1 END) / COUNT(*), 2) AS porcentaje_pedidos_con_retraso
FROM rangos_peso
GROUP BY rango_peso
ORDER BY rango_peso;