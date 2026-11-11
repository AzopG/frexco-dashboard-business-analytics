"""
Dashboard interactivo de Frexco - Business Analytics.
TEMA OSCURO (negro) - Cada KPI con sus propios filtros interactivos.
Los gráficos y tablas se actualizan en cada cambio de filtro.
"""
from datetime import date

import streamlit as st
import pandas as pd
from config import DB_CONFIG, COLORS, PREDICTION_CONFIG, ASSETS_DIR
from db import (
    get_connection,
    load_ventas_detalle,
    load_ventas_mensuales,
    load_top_productos,
    load_desperdicio_producto,
    load_desperdicio_motivo,
    load_margen_producto,
    load_margen_global,
    load_clientes_vip,
    load_perdida_proveedor,
)
from etl import (
    to_numeric,
    preparar_kpi2,
    metricas_globales,
    serie_semanal_por_producto,
)
from models import generar_escenarios, tabla_escenarios_ejemplo
from utils import (
    aplicar_estilo,
    formatear_moneda,
    figura_ventas_mes,
    figura_ventas_vs_desperdicio,
    figura_desperdicio_motivo,
    figura_margen_producto,
    figura_clientes_vip,
    figura_perdida_proveedor,
    figura_escenarios,
)

aplicar_estilo()

st.set_page_config(
    page_title="Frexco - Dashboard Business Analytics",
    page_icon="🍎",
    layout="wide",
    initial_sidebar_state="expanded",
)

# ---------------------------------------------------------------------------
# CSS tema oscuro (negro)
# ---------------------------------------------------------------------------
st.markdown(
    """
    <style>
    .stApp { background-color: #0E0E0E; color: #FFFFFF; }
    [data-testid="stSidebar"] { background-color: #121212; color: #FFFFFF; }
    [data-testid="stSidebar"] * { color: #FFFFFF !important; }
    .metric-card { background: #1A1A1A; padding: 1rem; border-radius: 8px; border-left: 4px solid #FFFFFF; color: #FFFFFF; }
    h1, h2, h3 { color: #FFFFFF !important; }
    .stDataFrame { background-color: #1A1A1A !important; }
    .stSelectbox > div > div { background-color: #1A1A1A !important; color: #FFFFFF !important; }
    .stMultiSelect > div > div { background-color: #1A1A1A !important; color: #FFFFFF !important; }
    /* Chips (tags) de los multiselect: fondo verde visible y texto blanco legible */
    [data-baseweb="tag"] { background-color: #2E7D32 !important; border: 1px solid #43A047 !important; }
    [data-baseweb="tag"] span { color: #FFFFFF !important; font-weight: 600 !important; }
    [data-baseweb="tag"] svg { fill: #FFFFFF !important; }
    /* Texto del buscador dentro del multiselect */
    .stMultiSelect input { color: #FFFFFF !important; }
    .stMultiSelect [data-baseweb="select"] { background-color: #1A1A1A !important; }
    .stSlider > div > div { color: #FFFFFF !important; }
    .conclusion { background: #1A1A1A; padding: 0.8rem; border-radius: 6px; font-size: 0.95rem; color: #FFFFFF; border-left: 4px solid #FFFFFF; }
    #MainMenu {visibility: hidden;} footer {visibility: hidden;} header {visibility: hidden;}
    </style>
    """,
    unsafe_allow_html=True,
)

# ---------------------------------------------------------------------------
# Carga de datos (cacheada)
# ---------------------------------------------------------------------------
@st.cache_data(show_spinner="Conectando a la base frexco en MySQL ...")
def cargar_todos_los_datos():
    conn = get_connection()
    try:
        data = {
            "ventas_detalle": load_ventas_detalle(conn),
            "ventas_mensuales": load_ventas_mensuales(conn),
            "top_productos": load_top_productos(conn),
            "desperdicio_producto": load_desperdicio_producto(conn),
            "desperdicio_motivo": load_desperdicio_motivo(conn),
            "margen_producto": load_margen_producto(conn),
            "margen_global": load_margen_global(conn),
            "clientes_vip": load_clientes_vip(conn),
            "perdida_proveedor": load_perdida_proveedor(conn),
        }
    finally:
        conn.close()

    to_numeric(data["ventas_mensuales"], ["Numero_Ventas", "Ventas_Totales", "Ticket_Promedio"])
    to_numeric(data["top_productos"], ["Unidades_Vendidas", "Venta_Detallada"])
    to_numeric(data["desperdicio_producto"], ["Unidades_Desperdiciadas", "Eventos_Desperdicio"])
    to_numeric(data["desperdicio_motivo"], ["Registros", "Cantidad_Desperdiciada", "Porcentaje"])
    to_numeric(data["margen_producto"], ["Precio_Venta_Promedio", "Costo_Unitario_Promedio",
                                         "Margen_Absoluto", "Margen_Porcentual"])
    to_numeric(data["margen_global"], ["Ingresos_Totales", "Costo_Estimado_Total",
                                       "Margen_Absoluto_Global", "Margen_Porcentual_Global"])
    to_numeric(data["clientes_vip"], ["Valor_Compras", "Pct_Ingresos", "Pct_Acumulado"])
    to_numeric(data["perdida_proveedor"], ["Cantidad_Suministrada_Por_Proveedor",
                                           "Total_Recibido_Producto", "Total_Desperdicio_Producto",
                                           "Perdida_Atribuida_Estimada", "Pct_Perdida_Sobre_Lo_Suministrado"])

    data["kpi2"] = preparar_kpi2(data["top_productos"], data["desperdicio_producto"])
    return data


# ---------------------------------------------------------------------------
# Sidebar: solo título y conexión (sin filtros globales que rompan la comparación)
# ---------------------------------------------------------------------------
st.sidebar.title("🍎 Frexco")
st.sidebar.caption("Fruver Facatativá · Business Analytics")
st.sidebar.divider()

try:
    DATA = cargar_todos_los_datos()
    st.sidebar.success("Conexión MySQL OK")
except Exception as e:
    st.sidebar.error(f"Error de conexión: {e}")
    st.stop()

st.sidebar.divider()
st.sidebar.caption("Datos en tiempo real desde MySQL `frexco`")

# Catálogos para filtros locales por KPI
CATEGORIAS = ["Todas"] + sorted(DATA["top_productos"]["Categoria"].dropna().unique().tolist())
PRODUCTOS = sorted(DATA["top_productos"]["Producto"].tolist())
PROVEEDORES = sorted(DATA["perdida_proveedor"]["Nombre_Proveedor"].dropna().unique().tolist())

# ---------------------------------------------------------------------------
# Métricas globales (cards superiores - sin filtro, son del negocio completo)
# ---------------------------------------------------------------------------
met = metricas_globales(DATA)

st.title("Dashboard Interactivo — Frexco")
st.caption("Simulando predicciones de demanda y reducción de mermas · Fruver Facatativá")

col1, col2, col3, col4 = st.columns(4)
col1.metric("Ventas totales", formatear_moneda(met["total_ventas"]))
col2.metric("Ticket promedio", formatear_moneda(met["ticket_promedio"]))
col3.metric("Margen global", "-" if pd.isna(met["margen_global"]) else f"{met['margen_global']:.1f}%")
col4.metric("Desperdicio total", f"{met['desperdicio_total']:,.0f} und.")

st.divider()

# ---------------------------------------------------------------------------
# Sección 1: KPIs ejecutivos - CADA UNO CON SUS PROPIOS FILTROS
# ---------------------------------------------------------------------------
st.header("1. KPIs Ejecutivos")

# ---------- KPI 1: Ventas por mes ----------
st.subheader("KPI 1 — Ventas totales por mes")
ventas_mensuales = DATA["ventas_mensuales"].copy()
ventas_mensuales["Periodo"] = ventas_mensuales.apply(
    lambda r: f"{int(r['Anio'])}-{int(r['Mes']):02d}", axis=1
)
fecha_min = DATA["ventas_detalle"]["Fecha_Venta"].min().date()
fecha_max = DATA["ventas_detalle"]["Fecha_Venta"].max().date()
with st.columns(2)[0]:
    rango_fecha = st.date_input(
        "Rango de fechas",
        value=(fecha_min, fecha_max),
        min_value=fecha_min,
        max_value=fecha_max,
        format="YYYY-MM-DD",
    )
if isinstance(rango_fecha, (tuple, list)) and len(rango_fecha) == 2:
    per_ini = f"{rango_fecha[0].year}-{rango_fecha[0].month:02d}"
    per_fin = f"{rango_fecha[1].year}-{rango_fecha[1].month:02d}"
    ventas_f = ventas_mensuales[
        (ventas_mensuales["Periodo"] >= per_ini)
        & (ventas_mensuales["Periodo"] <= per_fin)
    ]
else:
    ventas_f = ventas_mensuales
col_t1, col_g1 = st.columns([1, 1.4])
with col_t1:
    st.dataframe(ventas_f, width="stretch", hide_index=True)
with col_g1:
    st.pyplot(figura_ventas_mes(ventas_f))
st.markdown(
    '<div class="conclusion"><b>Conclusión de negocio:</b> Las ventas presentan estacionalidad mensual: '
    'los picos son marzo ($2,04 M) y julio ($1,83 M), y el valle es mayo ($0,49 M). '
    'Alinear compras, stock y personal con esos picos permite evitar quiebres y capturar el máximo ingreso.</div>',
    unsafe_allow_html=True,
)
st.divider()

# ---------- KPI 2: Top productos ----------
st.subheader("KPI 2 — Top productos: ventas vs. desperdicio")
col_f2a, col_f2b = st.columns(2)
with col_f2a:
    cat_kpi2 = st.selectbox("Categoría", CATEGORIAS, key="kpi2_cat")
    prods_kpi2 = st.multiselect(
        "Seleccionar productos (comparar varios)",
        options=PRODUCTOS,
        default=PRODUCTOS[:5],
        key="kpi2_prods",
    )
kpi2_f = DATA["kpi2"].copy()
if cat_kpi2 != "Todas":
    kpi2_f = kpi2_f[kpi2_f["Categoria"] == cat_kpi2]
if prods_kpi2:
    kpi2_f = kpi2_f[kpi2_f["Producto"].isin(prods_kpi2)]
kpi2_f = kpi2_f.sort_values("Unidades_Vendidas", ascending=False).head(15)

col_t2, col_g2 = st.columns([1, 1.4])
with col_t2:
    st.dataframe(kpi2_f, width="stretch", hide_index=True)
with col_g2:
    st.pyplot(figura_ventas_vs_desperdicio(kpi2_f))
st.markdown(
    '<div class="conclusion"><b>Conclusión de negocio:</b> El desperdicio se concentra en productos de baja rotación '
    '(Lechuga: 156 und. con solo 18 vendidas; Pera: 146; Uva: 128), mientras el de mayor venta (Mango: 158 vendidas) '
    'no presenta merma. Priorizar rotación y reposición en los ítems de alta merma y baja venta reduce pérdidas sin afectar el servicio.</div>',
    unsafe_allow_html=True,
)
st.divider()

# ---------- KPI 3: Desperdicio por motivo ----------
st.subheader("KPI 3 — Desperdicio por motivo")
# El motivo de desperdicio no tiene categoría de producto asociada en el modelo
# de datos, por lo que este KPI se muestra a nivel global (sin filtro).
desp_f = DATA["desperdicio_motivo"].copy()
col_t3, col_g3 = st.columns([1, 1.4])
with col_t3:
    st.dataframe(desp_f, width="stretch", hide_index=True)
with col_g3:
    st.pyplot(figura_desperdicio_motivo(desp_f))
st.markdown(
    '<div class="conclusion"><b>Conclusión de negocio:</b> Tres motivos explican el 67% del desperdicio: '
    'golpe en transporte (24,8%), vencimiento (22,1%) y maduración excesiva (20,4%). '
    'Atacarlos con mejor manipulación, cadena de frío y rotación reduce las pérdidas de forma directa y medible.</div>',
    unsafe_allow_html=True,
)
st.divider()

# ---------- KPI 4: Margen por producto ----------
st.subheader("KPI 4 — Margen de ganancia por producto")
col_f4a, col_f4b = st.columns(2)
with col_f4a:
    prods_kpi4 = st.multiselect(
        "Seleccionar productos (comparar varios)",
        options=PRODUCTOS,
        default=PRODUCTOS[:8],
        key="kpi4_prods",
    )
margen_f = DATA["margen_producto"].copy()
if prods_kpi4:
    margen_f = margen_f[margen_f["Producto"].isin(prods_kpi4)]
margen_f = margen_f.sort_values("Margen_Porcentual", ascending=False)
margen_global_val = float(DATA["margen_global"]["Margen_Porcentual_Global"].iloc[0]) if not DATA["margen_global"].empty else 0.0
col_t4, col_g4 = st.columns([1, 1.4])
with col_t4:
    st.dataframe(margen_f, width="stretch", hide_index=True)
with col_g4:
    st.pyplot(figura_margen_producto(margen_f, margen_global_val))
st.markdown(
    '<div class="conclusion"><b>Conclusión de negocio:</b> Los márgenes van de 66,9% (Pepino) a 36,6% (Piña), con un global de 41,2%. '
    'Verde = por encima del margen global; rojo = por debajo. Revisar precios y costos de los ítems en rojo '
    'mejora la rentabilidad global sin perder competitividad.</div>',
    unsafe_allow_html=True,
)
st.divider()

# ---------- KPI 5: Clientes VIP ----------
st.subheader("KPI 5 — Clientes VIP (concentración de ingresos / Pareto)")
col_f5a, col_f5b = st.columns(2)
with col_f5a:
    top_n = st.slider("Cantidad de clientes top", min_value=5, max_value=30, value=15, key="kpi5_topn")
clientes_f = DATA["clientes_vip"].sort_values("Valor_Compras", ascending=False).head(top_n)
col_t5, col_g5 = st.columns([1, 1.4])
with col_t5:
    st.dataframe(clientes_f, width="stretch", hide_index=True)
with col_g5:
    st.pyplot(figura_clientes_vip(clientes_f))
st.markdown(
    '<div class="conclusion"><b>Conclusión de negocio:</b> La concentración es <b>moderada</b>, no un 80/20 estricto: '
    'el 20% de clientes (8 de 39) aporta ~39% de los ingresos, y se necesita ~54% de los clientes (21 de 39) para llegar al 80%. '
    'Aun así, priorizar la fidelización de la mitad superior de clientes protege la mayor parte de la facturación.</div>',
    unsafe_allow_html=True,
)
st.divider()

# ---------- KPI 6: Pérdida por proveedor ----------
st.subheader("KPI 6 — Pérdida estimada por proveedor")
col_f6a = st.columns(1)[0]
with col_f6a:
    provs_kpi6 = st.multiselect(
        "Seleccionar proveedores (comparar varios)",
        options=PROVEEDORES,
        default=PROVEEDORES[:5],
        key="kpi6_provs",
    )
perdida_f = DATA["perdida_proveedor"].copy()
if provs_kpi6:
    perdida_f = perdida_f[perdida_f["Nombre_Proveedor"].isin(provs_kpi6)]
col_t6, col_g6 = st.columns([1, 1.4])
with col_t6:
    st.dataframe(perdida_f, width="stretch", hide_index=True)
with col_g6:
    st.pyplot(figura_perdida_proveedor(perdida_f))
st.markdown(
    '<div class="conclusion"><b>Conclusión de negocio:</b> El % de pérdida es relativamente homogéneo (4,0%–7,8%); '
    'los más críticos son Agroinsumos San Miguel (7,8%), Fruitsfull (7,6%) y Canasta Fresh (7,5%). '
    'Reforzar el control en la recepción con esos proveedores reduce el desperdicio atribuible.</div>',
    unsafe_allow_html=True,
)

st.divider()

# ---------------------------------------------------------------------------
# Sección 2: Predicción de demanda y simulador de escenarios
# ---------------------------------------------------------------------------
st.header("2. Predicción de Demanda y Simulador de Escenarios")

st.markdown("**Pregunta de predicción:** ¿Cuántas unidades de cada producto, en su <b>propia unidad de medida</b>, se venderán en cada una de las <b>4 semanas siguientes</b> al último dato con detalle, y dentro de qué <b>rango</b> se espera que caiga esa demanda, para dimensionar el pedido semanal por producto y proveedor?", unsafe_allow_html=True)

st.markdown("Esta pregunta se formula producto por producto porque los 20 productos del catálogo se miden en 4 unidades distintas (Libra, Kg, Unidad y Atado), por lo que no es válido sumar cantidades entre productos. El tipo de producto se usa para agrupar comportamientos y decisiones de pedido, no para sumar unidades.", unsafe_allow_html=True)

pivote = serie_semanal_por_producto(DATA["ventas_detalle"])

meta = DATA["top_productos"].merge(DATA["desperdicio_producto"][["ID_Producto", "Unidades_Desperdiciadas"]], on="ID_Producto", how="left").fillna({"Unidades_Desperdiciadas": 0})
recibidos = DATA["ventas_detalle"].groupby("ID_Producto")["Cantidad"].sum()
meta["Recibido_proxy"] = meta["ID_Producto"].map(recibidos).fillna(meta["Unidades_Vendidas"])
meta["Merma_pct"] = (100 * meta["Unidades_Desperdiciadas"] / meta["Recibido_proxy"].replace(0, pd.NA)).fillna(0)
meta["Tipo"] = meta["Categoria"]
meta["Nombre"] = meta["Producto"]
if "Unidad_Medida" not in meta.columns:
    meta["Unidad_Medida"] = "und"
meta["Vida_d"] = 14

escenarios_df = generar_escenarios(pivote, meta, h=4)

prod_sel = st.selectbox("Seleccionar producto para ver escenarios", options=PRODUCTOS, key="pred_prod")
if prod_sel:
    pid_sel = DATA["top_productos"].set_index("Producto").loc[prod_sel, "ID_Producto"]
    nombre_sel = prod_sel
    fila_sel = escenarios_df[escenarios_df["Producto"] == nombre_sel]

    st.subheader(f"Simulador — {nombre_sel}")
    colA, colB, colC = st.columns(3)
    config = PREDICTION_CONFIG["scenarios"]
    for idx, (clave, info) in enumerate(config.items()):
        col = [colA, colB, colC][idx]
        fila = escenarios_df[escenarios_df["ID_Producto"] == pid_sel]
        valor = fila.iloc[0][f"P{info['percentile']}"] if not fila.empty else 0
        col.metric(info["label"], f"{valor:.1f} und.", help=info["descripcion"])

    st.pyplot(figura_escenarios(escenarios_df, pid_sel))

    st.markdown("**Detalle del producto seleccionado:**")
    detalle = fila_sel.T.reset_index()
    detalle.columns = ["Campo", "Valor"]
    detalle["Valor"] = detalle["Valor"].astype(str)
    st.dataframe(detalle, width="stretch", hide_index=True)

st.divider()
st.subheader("Tabla de escenarios de prueba (entrega)")
st.dataframe(tabla_escenarios_ejemplo(), width="stretch", hide_index=True)
st.caption("Los tres escenarios representan valores asignados para las variables predictoras bajo diferentes supuestos de demanda (P10, P50, P90).")

st.divider()
st.markdown("<small>Dashboard generado con Streamlit · Datos desde MySQL `frexco` · Código modular en /dashboard</small>", unsafe_allow_html=True)
