# Dashboard Interactivo — Frexco (Business Analytics)

Dashboard construido con **Python + Streamlit** que responde a las preguntas de
negocio del proyecto de aula y simula predicciones de demanda por producto bajo
tres escenarios (Conservador / Medio / Optimista).

## Estructura del proyecto (modular)

```
dashboard/
├── config.py        # Configuración, colores corporativos, variables de entorno
├── db.py            # Capa de acceso a datos (conexión MySQL y carga de tablas)
├── etl.py           # Procesamiento/ETL (limpieza, agregación, series semanales)
├── models.py        # Lógica de predicción (backtest, escenarios P10/P50/P90)
├── utils.py         # Utilidades de visualización y formato
├── dashboard.py     # Interfaz Streamlit principal
└── requirements.txt # Dependencias de Python
```

## Requisitos previos

1. Python 3.9 o superior.
2. Base de datos MySQL llamada `frexco` cargada con el script `Frexco (3).sql`.
3. Credenciales de acceso a MySQL (por defecto: `localhost`, `root`, `123`).

## Instalación y ejecución local

```bash
# 1. Entrar a la carpeta del dashboard
cd dashboard

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. (Opcional) Crear archivo .env con credenciales propias
#    FREXCO_DB_HOST=localhost
#    FREXCO_DB_USER=root
#    FREXCO_DB_PASSWORD=123
#    FREXCO_DB_NAME=frexco

# 4. Ejecutar el dashboard
streamlit run dashboard.py
```

El dashboard quedará disponible en `http://localhost:8501`.

## Conexión a datos

La conexión a MySQL se realiza mediante el módulo `db.py` usando `mysql-connector-python`.
Las credenciales se resuelven en este orden:

1. Variables de entorno (`FREXCO_DB_HOST`, `FREXCO_DB_USER`, `FREXCO_DB_PASSWORD`, `FREXCO_DB_NAME`).
2. Archivo `.env` en la raíz del dashboard (si existe).
3. Valores por defecto definidos en `config.py`.

## Módulos y responsabilidades

| Módulo | Responsabilidad |
|--------|-----------------|
| `config.py` | Configuración centralizada, colores corporativos, variables de entorno |
| `db.py` | Conexión a MySQL y carga de las 8 consultas del proyecto |
| `etl.py` | Limpieza numérica, combinación de datasets, series semanales por producto |
| `models.py` | Predicción de demanda, backtest, clasificación de previsibilidad, escenarios |
| `utils.py` | Gráficos matplotlib con estilo corporativo y formateo de moneda |
| `dashboard.py` | Interfaz Streamlit: KPIs, filtros, simulador y entrega de escenarios |

## Pregunta de predicción

> ¿Cuántas unidades de cada producto, en su propia unidad de medida, se venderán
> en cada una de las 4 semanas siguientes al último dato con detalle, y dentro
> de qué rango se espera que caiga esa demanda, para dimensionar el pedido
> semanal por producto y proveedor?

## Escenarios de prueba

El simulador genera tres escenarios basados en percentiles del acumulado a 4
semanas:

| Escenario | Percentil | Uso recomendado |
|-----------|-----------|-----------------|
| Conservador | P10 | Evitar sobrecompra y merma; pedir cerca del mínimo histórico |
| Medio | P50 | Pedido estándar con stock de seguridad normal |
| Optimista | P90 | Priorizar no quedarse sin producto; monitorear merma semanal |

## Interacciones disponibles

1. **Selector de categoría**: filtra todos los KPIs y el simulador por categoría de producto.
2. **Selector de producto (drill-down)**: muestra el detalle y los escenarios de predicción de un producto específico.
3. **Tarjetas KPI**: métricas globales (ventas, ticket, margen, desperdicio) actualizadas desde MySQL.
4. **Tablas de datos**: cada KPI muestra su tabla subyacente con posibilidad de ordenar y buscar.
5. **Gráficos interactivos**: cada KPI incluye su gráfico estadístico correspondiente.
6. **Simulador de escenarios**: métricas P10 / P50 / P90 para el producto seleccionado con gráfico de barras.
7. **Tabla de escenarios de prueba**: los 3 escenarios con valores asignados para la entrega del PDF.

## Preguntas de negocio respondidas

- ¿Cuáles son los productos con mayor venta y mayor desperdicio?
- ¿Qué motivos explican el desperdicio y en qué proporción?
- ¿Qué productos tienen mejor y peor margen de ganancia?
- ¿Qué clientes concentran el 80% de los ingresos (regla 80/20)?
- ¿Qué proveedores presentan mayor pérdida estimada?
- ¿Cuánta demanda se espera por producto en las próximas 4 semanas bajo 3 escenarios?

## Entrega

La entrega formal es un documento PDF que incluye:
- Contexto del proyecto y empresa analizada.
- Pregunta de predicción formulada.
- Tabla con los 3 escenarios de prueba y valores asignados.
- Pantallazos del dashboard en funcionamiento.
- Lista de interacciones disponibles.
- Link al código del repositorio.

## Autor

Equipo de trabajo — Analítica de Negocios · Proyecto de Aula Frexco
