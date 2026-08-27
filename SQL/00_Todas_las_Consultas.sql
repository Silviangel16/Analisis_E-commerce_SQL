-- ====================================================================
-- CASO DE ESTUDIO DE NEGOCIO EN SQL: E-COMMERCE OLIST BRASIL
-- Plataforma: Google BigQuery
-- Proyecto: brazilian-e-commerce-511503
-- Conjunto de datos: ecommerce_data
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


-- ====================================================================
-- Parte 6: Métodos de Pago y Análisis de Cuotas
-- ====================================================================

-- 6.1 Número de pedidos mes a mes realizados con diferentes tipos de pago
SELECT
  FORMAT_DATETIME('%Y-%m', o.order_purchase_timestamp) AS mes_pedido,
  p.payment_type AS tipo_pago,
  COUNT(DISTINCT p.order_id) AS total_pedidos
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_order_payments_dataset` p
JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset` o USING (order_id)
GROUP BY
  FORMAT_DATETIME('%Y-%m', o.order_purchase_timestamp),
  p.payment_type
ORDER BY mes_pedido, p.payment_type;

-- 6.2 Número de pedidos realizados según la cantidad de cuotas (installments)
SELECT 
  payment_installments AS numero_cuotas,
  COUNT(DISTINCT order_id) AS total_pedidos
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_order_payments_dataset`
GROUP BY payment_installments
ORDER BY total_pedidos DESC, numero_cuotas;


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