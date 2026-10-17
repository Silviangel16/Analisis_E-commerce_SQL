<div align="center">
  
  # 🛒 Análisis de E-Commerce con SQL

![Google BigQuery](https://img.shields.io/badge/GOOGLE%20BIGQUERY-4285F4?style=for-the-badge&logo=googlebigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-ADVANCED%20QUERIES-0B3D91?style=for-the-badge&logo=postgresql&logoColor=white)
![Data Modeling](https://img.shields.io/badge/DATA%20MODELING-ERD-2E7D32?style=for-the-badge)

Este estudio explora la dinámica del negocio de Olist, una plataforma de comercio electrónico de Brasil, mediante consultas SQL en Google BigQuery sobre un modelo de 5 tablas (`customers`, `orders`, `order_items`, `payments` y `products`). Los datos provienen del *Brazilian E-Commerce Public Dataset by Olist* (Kaggle): 99.441 pedidos de 96.096 clientes entre 2016 y 2018.

[Dataset](ENLACE_DE_KAGGLE)

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
