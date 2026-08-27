<div align="center">
  
  # 🛒 Análisis de E-Commerce con SQL

![Google BigQuery](https://img.shields.io/badge/GOOGLE%20BIGQUERY-4285F4?style=for-the-badge&logo=googlebigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-ADVANCED%20QUERIES-0B3D91?style=for-the-badge&logo=postgresql&logoColor=white)
![Data Modeling](https://img.shields.io/badge/DATA%20MODELING-ERD-2E7D32?style=for-the-badge)

Este proyecto explora la dinámica del negocio de Olist, una plataforma de comercio electrónico de Brasil, mediante consultas SQL en Google BigQuery sobre un modelo de 5 tablas (`customers`, `orders`, `order_items`, `payments` y `products`). Los datos provienen del *Brazilian E-Commerce Public Dataset by Olist* (Kaggle): 99.441 pedidos de 96.096 clientes entre 2016 y 2018.

[Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

</div>

## 📌 Vistazo a los Principales Hallazgos

| Métrica | Valor Cuantitativo | Perspectiva Operativa |
|---|---|---|
| Escala del Dataset | 99.441 pedidos de 96.096 clientes en 27 estados | Pedidos entre sep 2016 y oct 2018; el 99,6% se concentra entre ene 2017 y ago 2018. Solo el 3,4% de los pedidos son de clientes recurrentes |
| Crecimiento YoY de Pedidos | +135,07% (ene-ago 2017 vs 2018) | El volumen se multiplicó por 2,35 y en 2018 se estabiliza entre 6.167 y 7.269 pedidos al mes |
| Horario de Mayor Demanda | 10:00-22:59 concentra el 81,5% de los pedidos; máximo a las 16:00 | Demanda sostenida, sin un único pico; de 02:00 a 06:00 hay menos de 520 pedidos por hora |
| Concentración de Clientes | SP, RJ y MG reúnen el 66,5% de los clientes (SP solo, 41,9%) | 14 estados aportan menos del 1% de los clientes cada uno |
| Disparidad Regional de Tiempo de Entrega | Brecha de 3,5x (RR: 28,98 días vs SP: 8,30 días) | Los 5 estados más lentos son del Norte y Nordeste; los 5 más rápidos, del Sureste, el Sur y el Distrito Federal |
| Preferencias de Pago | Tarjeta de crédito: 76,9% de los pedidos | El 66,9% de los pagos con tarjeta se hace en 2 o más cuotas |
| Categorías Líderes | Belleza y salud: 9,3% de los ingresos | Las 5 principales categorías suman casi el 40% y las 15 primeras, cerca del 76% |

## 🎯 Problema de Negocio y Objetivos

Olist, una plataforma de comercio electrónico brasileña, experimentó una rápida adopción por parte de los consumidores. Sin embargo, crecer de forma acelerada en una geografía tan extensa como la de Brasil plantea retos operativos. Mediante consultas SQL en Google BigQuery sobre un modelo de 5 tablas (`customers`, `orders`, `order_items`, `payments` y `products`), el análisis busca responder:

1. **Crecimiento y demanda** (Parte 2): ¿Cuál fue el ritmo de crecimiento interanual de los pedidos, cómo varían mes a mes y a qué horas se concentra la demanda?
2. **Geografía y logística** (Parte 3): ¿Dónde están los clientes y qué tan grandes son las brechas en los tiempos de entrega entre el Sureste y las regiones Norte y Nordeste?
3. **Hábitos de pago** (Parte 4): ¿Qué métodos de pago prefieren los clientes y qué peso tiene el pago en cuotas con tarjeta de crédito?
4. **Mix de productos** (Parte 5): ¿Qué categorías generan más ingresos y qué tan concentrados están?

## 📁 Estructura del repositorio

```text
Analisis_E-commerce_SQL/
│
├── sql/
│   ├── 00_todas_las_consultas.sql              
│   ├── 01_esquema_y_exploracion_inicial.sql   
│   ├── 02_tendencias_y_estacionalidad.sql     
│   ├── 03_geografia_y_logistica.sql           
│   ├── 04_metodos_de_pago_y_cuotas.sql       
│   └── 05_ventas_por_categoria_de_producto.sql 
│
├── informes
│   └── Analisis_SQL_Ecommerce_Olist.pdf       
│
├── docs/
│   └── diagrama_erd.png                  
└── README.md
```

## Modelado de Datos (ERD)

<img width="1530" height="741" alt="image" src="https://github.com/user-attachments/assets/16d464d9-b399-415d-bf5c-5bf036265793" />

## 🔍 Desarrollo Técnico, Consultas SQL e Insights

### Parte 1. Esquema y Exploración Inicial

| Pregunta | Resultado |
|---|---|
| 1.1 ¿Qué tablas y columnas hay? | 5 tablas y 34 columnas (pedidos, clientes, ítems, pagos y productos). Sin inventario ni tabla de vendedores; categorías en portugués |
| 1.2 ¿Cuántos pedidos y clientes reales hay? | 99.441 pedidos y 96.096 clientes únicos; solo el 3,4% de los pedidos son de clientes recurrentes |
| 1.3 ¿Qué periodo cubren los pedidos? | Del 04/09/2016 al 17/10/2018; 96.478 pedidos entregados (97,0%) |
| 1.4 ¿Qué meses tienen datos completos? | El 99,6% está entre ene 2017 y ago 2018; 2016 (329 pedidos) y sep-oct 2018 (20) quedan fuera de los comparativos |
| 1.5 ¿En cuántos estados y ciudades hay clientes? | 27 estados y 4.310 ciudades |

### Parte 2. Tendencias y Estacionalidad

| Pregunta | Resultado |
|---|---|
| 2.1 ¿Cómo evolucionan los pedidos por año? | Ene–ago pasó de 22.968 pedidos en 2017 a 53.991 en 2018 (+135,1%). Solo 2017 y 2018 tienen datos casi completos |
| 2.2 ¿Cómo varía el volumen mes a mes, 2017 vs 2018? | Pico en nov 2017 (7.544 pedidos); en 2018 el volumen se estabiliza entre 6.167 y 7.269 pedidos al mes |
| 2.3 ¿A qué hora se hacen más pedidos? | El 81,5% se concentra entre las 10:00 y las 22:59; el máximo es a las 16:00 (6.675) y de 02:00 a 06:00 hay menos de 520 por hora |

**Consulta destacada: 2.2.** Compara cada mes de 2017 y 2018 por separado, sin sumar años distintos, y se limita al rango con datos completos.

```sql
-- 2.2 ¿Cómo varía el número de pedidos mes a mes, comparando 2017 y 2018 por separado?
-- Supuesto: no se suman meses de años distintos; 2016 y sep-oct 2018 se excluyen por tener datos casi nulos.
SELECT
  EXTRACT(MONTH FROM order_purchase_timestamp) AS mes_num,
  COUNTIF(EXTRACT(YEAR FROM order_purchase_timestamp) = 2017) AS pedidos_2017,
  COUNTIF(EXTRACT(YEAR FROM order_purchase_timestamp) = 2018) AS pedidos_2018
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_orders_dataset`
WHERE DATE(order_purchase_timestamp) BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY mes_num
ORDER BY mes_num;
```
**Insight:** el crecimiento de 2017 a 2018 es claro, pero con un solo noviembre completo no se puede afirmar una estacionalidad recurrente, solo un posible efecto de temporada.

### Parte 3. Geografía y Logística

| Pregunta | Resultado |
|---|---|
| 3.1 ¿Cómo se distribuyen los clientes entre los estados? | SP concentra el 41,9% de los clientes, seguido de RJ (12,9%) y MG (11,7%): entre los tres suman el 66,5% |
| 3.2 ¿Qué estados tardan más y menos en entregar? | Los más lentos son RR, AP, AM, AL y PA; los más rápidos, SC, DF, MG, PR y SP. RR tarda 28,98 días en promedio frente a 8,30 de SP (3,5 veces más), aunque con solo 41 pedidos |

**Consulta destacada: 3.1.** Cuenta clientes reales (`customer_unique_id`, no `customer_id`, que cambia en cada pedido) y calcula el porcentaje con una función de ventana dentro de una `CTE`.

```sql
-- 3.1 ¿Cómo se distribuyen los clientes entre todos los estados?
-- Supuesto: cliente = customer_unique_id (customer_id se genera por pedido).
WITH clientes_estado AS (
  SELECT
    customer_state AS estado_cliente,
    COUNT(DISTINCT customer_unique_id) AS total_clientes_unicos
  FROM `brazilian-e-commerce-511503.ecommerce_data.olist_customers_dataset`
  GROUP BY customer_state
)
SELECT
  estado_cliente,
  total_clientes_unicos,
  ROUND(100 * total_clientes_unicos / SUM(total_clientes_unicos) OVER (), 1) AS pct_clientes
FROM clientes_estado
ORDER BY total_clientes_unicos DESC, estado_cliente;
```

**Insight:** la demanda y la logística se concentran en el Sureste; los estados del Norte reciben sus pedidos mucho más tarde, pero con pocos pedidos, así que ese promedio hay que leerlo con cautela.
### Parte 4. Métodos de Pago y Cuotas

| Pregunta | Resultado |
|---|---|
| 4.1 ¿Qué métodos de pago se usan más? | La tarjeta de crédito está presente en el 76,9% de los pedidos |
| 4.2 ¿Cómo se reparten los pagos con tarjeta según las cuotas? | El 66,9% de los pagos con tarjeta se hace en 2 o más cuotas, y el valor promedio sube de 95,87 (1 cuota) a 333,83 BRL (más de 10 cuotas) |

**Consulta destacada: 4.2.** Agrupa las cuotas en rangos con `CASE` y calcula el porcentaje de cada rango con una función de ventana.

```sql
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
```

**Insight:** el crédito domina y el pago en cuotas se asocia a compras más grandes, lo que sugiere que financiar facilita el ticket alto.

---

### Parte 5. Ventas por Categoría de Producto

| Pregunta | Resultado |
|---|---|
| 5.1 ¿Qué categorías generan más ingresos? | Salud y belleza lidera con el 9,3% de los ingresos, seguida de relojes y regalos (8,9%) y cama, mesa y baño (7,6%) |

**Consulta destacada: 5.1.** Calcula el peso de cada categoría sobre el total con `SUM(SUM()) OVER ()`; las categorías sin nombre se agrupan como "Desconocido".

```sql
-- 5.1 ¿Qué categorías de producto generan más ingresos?
-- Supuesto: ingresos = suma del precio de los artículos (sin flete); categorías en portugués.
SELECT
  COALESCE(p.product_category_name, 'Desconocido') AS categoria_producto,
  COUNT(*) AS total_articulos_vendidos,
  ROUND(SUM(i.price), 2) AS ingresos_totales,
  ROUND(100 * SUM(i.price) / SUM(SUM(i.price)) OVER (), 1) AS pct_ingresos,
  ROUND(AVG(i.price), 2) AS precio_promedio_producto
FROM `brazilian-e-commerce-511503.ecommerce_data.olist_order_items_dataset` i
JOIN `brazilian-e-commerce-511503.ecommerce_data.olist_products_dataset` p
  ON i.product_id = p.product_id
GROUP BY categoria_producto
ORDER BY ingresos_totales DESC
LIMIT 15;
```
**Insight:** los ingresos están repartidos entre muchas categorías; ninguna supera el 10%, así que el negocio no depende de un solo tipo de producto.

## 💡 Recomendaciones de Negocio

| Hallazgo | Recomendación |
|---|---|
| Posible pico en noviembre | Preparar inventario, logística y atención para noviembre, y probar una campaña para confirmar si el efecto se repite |
| Demanda entre las 10:00 y las 22:59 | Concentrar campañas y atención al cliente en esa franja, con refuerzo hacia las 16:00 |
| Clientes concentrados en SP, RJ y MG | Proteger el servicio en el Sureste y evaluar acciones de captación en estados con pocos clientes |
| Entregas lentas en el Norte | Revisar rutas y transportistas para esos estados y comunicar plazos realistas al comprador |
| Crédito en cuotas y ticket alto | Mantener y destacar las cuotas en compras de valor alto, y probar si ofrecerlas en más productos sube el ticket |
| Ingresos repartidos entre categorías | Mantener un catálogo diverso y revisar el margen, no solo los ingresos, para decidir en qué categorías invertir |
