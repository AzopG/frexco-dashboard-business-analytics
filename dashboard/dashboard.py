"""
Dashboard interactivo de Frexco - Business Analytics.
TEMA OSCURO (negro) - versión para entrega.
"""
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
from models import METODOS_DISPONIBLES, mejor_metodo_por_tipo, generar_escenarios, tabla_escenarios_ejemplo
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
# CSS tema oscuro (negro) - estilo corporativo
# ---------------------------------------------------------------------------
st.markdown(
    f"""
    <style>
    /* Fondo general oscuro */
    .stApp {{
        background-color: #0E0E0E;
        color: #FFFFFF;
    }}
    /* Sidebar oscuro */
    [data-testid="stSidebar"] {{
        background-color: #121212;
        color: #FFFFFF;
    }}
    [data-testid="stSidebar"] * {{
        color: #FFFFFF !important;
    }}
    /* Tarjetas métricas oscuras */
    .metric-card {{
        background: #1A1A1A;
        padding: 1rem;
        border-radius: 8px;
        border-left: 4px solid #FFFFFF;
        color: #FFFFFF;
    }}
    /* Títulos */
    h1, h2, h3 {{
        color: #FFFFFF !important;
    }}
    /* Tablas oscuras */
    .stDataFrame {{
        background-color: #1A1A1A !important;
    }}
    /* Botones y selectores */
    .stSelectbox > div > div {{
        background-color: #1A1A1A !important;
        color: #FFFFFF !important;
    }}
    .stRadio > div {{
        background-color: #1A1A1A !important;
        color: #FFFFFF !important;
    }}
    /* Texto de conclusión */
    .conclusion {{
        background: #1A1A1A;
        padding: 0.8rem;
        border-radius: 6px;
        font-size: 0.95rem;
        color: #FFFFFF;
        border-left: 4px solid #FFFFFF;
    }}
    /* Ocultar elementos de streamlit que rompen el estilo */
    #MainMenu {{visibility: hidden;}}
    footer {{visibility: hidden;}}
    header {{visibility: hidden;}}
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
    to_numeric(data["margen_producto"], ["Precio_Venta_Promedio", "Costo_Unitario_Promedio", "Margen_Absoluto", "Margen_Porcentual"])
    to_numeric(data["margen_global"], ["Ingresos_Totales", "Costo_Estimado_Total", "Margen_Absoluto_Global", "Margen_Porcentual_Global"])
    to_numeric(data["clientes_vip"], ["Valor_Compras", "Pct_Ingresos", "Pct_Acumulado"])
    to_numeric(data["perdida_proveedor"], ["Cantidad_Suministrada_Por_Proveedor", "Total_Recibido_Producto", "Total_Desperdicio_Producto", "Perdida_Atribuida_Estimada", "Pct_Perdida_Sobre_Lo_Suministrado"])

    data["kpi2"] = preparar_kpi2(data["top_productos"], data["desperdicio_producto"])
    return data


# ---------------------------------------------------------------------------
# Sidebar
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

categorias = ["Todas"] + sorted(DATA["top_productos"]["Categoria"].dropna().unique().tolist())
categoria_sel = st.sidebar.selectbox("Categoría de producto", categorias)

productos_disponibles = DATA["top_productos"]
if categoria_sel != "Todas":
    productos_disponibles = productos_disponibles[productos_disponibles["Categoria"] == categoria_sel]
producto_opciones = ["Todos los productos"] + sorted(productos_disponibles["Producto"].tolist())
producto_sel = st.sidebar.selectbox("Producto (drill-down)", producto_opciones)

st.sidebar.divider()
st.sidebar.caption("Datos en tiempo real desde MySQL `frexco`")

# ---------------------------------------------------------------------------
# Métricas globales
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
# KPIs ejecutivos
# ---------------------------------------------------------------------------
st.header("1. KPIs Ejecutivos")

kpis = [
    {
        "titulo": "KPI 1 — Ventas totales por mes",
        "df": DATA["ventas_mensuales"],
        "fig_fn": figura_ventas_mes,
        "fig_args": (DATA["ventas_mensuales"],),
        "tabla": DATA["ventas_mensuales"],
        "conclusion": ("Las ventas presentan estacionalidad mensual. Alinear compras, stock y personal con los picos de demanda permite evitar quiebres y capturar el máximo ingreso."),
    },
    {
        "titulo": "KPI 2 — Top productos: ventas vs. desperdicio",
        "df": DATA["kpi2"],
        "fig_fn": figura_ventas_vs_desperdicio,
        "fig_args": (DATA["kpi2"],),
        "tabla": DATA["kpi2"],
        "conclusion": ("Un conjunto reducido de productos concentra tanto las ventas como el desperdicio. Aplicar control de rotación y reposición prioritaria sobre esos ítems reduce pérdidas sin afectar el servicio al cliente."),
    },
    {
        "titulo": "KPI 3 — Desperdicio por motivo",
        "df": DATA["desperdicio_motivo"],
        "fig_fn": figura_desperdicio_motivo,
        "fig_args": (DATA["desperdicio_motivo"],),
        "tabla": DATA["desperdicio_motivo"],
        "conclusion": ("El desperdicio se explica por pocos motivos dominantes. Atacarlos con mayor rotación, manejo cuidadoso y cadena de frío reduce las pérdidas de forma directa y medible."),
    },
    {
        "titulo": "KPI 4 — Margen de ganancia por producto",
        "df": DATA["margen_producto"],
        "fig_fn": figura_margen_producto,
        "fig_args": (DATA["margen_producto"], float(DATA["margen_global"]["Margen_Porcentual_Global"].iloc[0]) if not DATA["margen_global"].empty else 0.0),
        "tabla": DATA["margen_producto"],
        "conclusion": ("Los márgenes son desiguales entre productos. Revisar precios y costos de los ítems de menor margen, sin perder competitividad, mejora la rentabilidad global del negocio."),
    },
    {
        "titulo": "KPI 5 — Clientes VIP (regla 80/20)",
        "df": DATA["clientes_vip"],
        "fig_fn": figura_clientes_vip,
        "fig_args": (DATA["clientes_vip"],),
        "tabla": DATA["clientes_vip"],
        "conclusion": ("La regla 80/20 se cumple: pocos clientes concentran la mayor parte de los ingresos. Un programa de fidelización a esos clientes VIP protege la facturación."),
    },
    {
        "titulo": "KPI 6 — Pérdida estimada por proveedor",
        "df": DATA["perdida_proveedor"],
        "fig_fn": figura_perdida_proveedor,
        "fig_args": (DATA["perdida_proveedor"],),
        "tabla": DATA["perdida_proveedor"],
        "conclusion": ("La pérdida estimada se concentra en pocos proveedores y productos. Renegociar condiciones o reforzar el control en la recepción con esos proveedores disminuye el desperdicio atribuible."),
    },
]

for kpi in kpis:
    st.subheader(kpi["titulo"])
    df_show = kpi["tabla"]
    if categoria_sel != "Todas" and "Categoria" in df_show.columns:
        df_show = df_show[df_show["Categoria"] == categoria_sel]
    st.dataframe(df_show, width="stretch", hide_index=True)
    st.pyplot(kpi["fig_fn"](*kpi["fig_args"]))
    st.markdown(f'<div class="conclusion"><b>Conclusión de negocio:</b> {kpi["conclusion"]}</div>', unsafe_allow_html=True)
    st.divider()

# ---------------------------------------------------------------------------
# Predicción y escenarios
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
meta["Unidad_Medida"] = meta.get("Unidad_Medida", "und")
meta["Vida_d"] = 14

escenarios_df = generar_escenarios(pivote, meta, h=4)

if producto_sel != "Todos los productos":
    fila_sel = escenarios_df[escenarios_df["Producto"] == producto_sel]
else:
    fila_sel = escenarios_df.head(1)

if not fila_sel.empty:
    pid_sel = fila_sel.iloc[0]["ID_Producto"]
    nombre_sel = fila_sel.iloc[0]["Producto"]

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
    detalle = fila_sel.T
    detalle.columns = ["Valor"]
    st.dataframe(detalle, width="stretch")

st.divider()
st.subheader("Tabla de escenarios de prueba (entrega)")
st.dataframe(tabla_escenarios_ejemplo(), width="stretch", hide_index=True)
st.caption("Los tres escenarios representan valores asignados para las variables predictoras bajo diferentes supuestos de demanda (P10, P50, P90).")

st.divider()
st.markdown("<small>Dashboard generado con Streamlit · Datos desde MySQL `frexco` · Código modular en /dashboard</small>", unsafe_allow_html=True)
