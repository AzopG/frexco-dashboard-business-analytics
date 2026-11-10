"""
Utilidades de visualización y formato para el dashboard Frexco (tema oscuro).
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import pandas as pd
from config import COLORS


def aplicar_estilo():
    """Aplica el estilo visual oscuro corporativo a matplotlib."""
    plt.rcParams.update({
        "figure.facecolor": "#0E0E0E",
        "axes.facecolor": "#0E0E0E",
        "savefig.facecolor": "#0E0E0E",
        "font.family": "sans-serif",
        "font.size": 10,
        "axes.titlesize": 13,
        "axes.titleweight": "bold",
        "axes.titlecolor": "#FFFFFF",
        "axes.labelsize": 10,
        "axes.labelcolor": "#FFFFFF",
        "axes.edgecolor": "#404040",
        "axes.grid": True,
        "grid.color": "#333333",
        "grid.linewidth": 0.6,
        "grid.alpha": 0.5,
        "xtick.color": "#FFFFFF",
        "ytick.color": "#FFFFFF",
        "legend.frameon": False,
        "text.color": "#FFFFFF",
    })


def formatear_moneda(valor):
    """Formatea un valor numérico en pesos colombianos."""
    if pd.isna(valor):
        return "-"
    return f"${valor:,.0f}"


def figura_ventas_mes(df, ancho=10, alto=5):
    """Gráfico de ventas por mes con barra + línea de tendencia (tema oscuro)."""
    fig, ax = plt.subplots(figsize=(ancho, alto))
    d = df.sort_values(["Anio", "Mes"]).copy()
    d["Periodo"] = d["Anio"].astype(str) + "/" + d["Mes"].astype(str).str.zfill(2)
    x = range(len(d))
    ax.bar(x, d["Ventas_Totales"], color=COLORS["secondary"], width=0.65,
           label="Ventas del mes", zorder=3)
    ax.plot(x, d["Ventas_Totales"], color="#FFFFFF", marker="o",
            markersize=5, linewidth=2, label="Tendencia", zorder=4)
    ax.set_title("Ventas totales por mes")
    ax.set_xlabel("Mes/Año")
    ax.set_ylabel("Ventas ($ COP)")
    ax.set_xticks(list(x))
    ax.set_xticklabels(d["Periodo"], rotation=45, ha="right")
    ax.yaxis.set_major_formatter(
        mtick.FuncFormatter(lambda v, _: f"${v:,.0f}")
    )
    ax.legend(loc="upper left", fontsize=9)
    ax.set_axisbelow(True)
    fig.tight_layout()
    return fig


def figura_ventas_vs_desperdicio(df, ancho=10, alto=6):
    """Gráfico agrupado: ventas vs desperdicio por producto (tema oscuro)."""
    fig, ax = plt.subplots(figsize=(ancho, alto))
    d = df.sort_values("Unidades_Vendidas", ascending=False).copy()
    d["Etiqueta"] = d["Producto"].astype(str) + " (" + d["Categoria"].astype(str) + ")"
    x = range(len(d))
    w = 0.38
    ax.bar([i - w / 2 for i in x], d["Unidades_Vendidas"], width=w,
           color=COLORS["secondary"], label="Unidades vendidas", zorder=3)
    ax.bar([i + w / 2 for i in x], d["Unidades_Desperdiciadas"], width=w,
           color=COLORS["danger"], label="Unidades desperdiciadas", zorder=3)
    ax.set_title(f"Ventas vs. desperdicio por producto ({len(d)} seleccionados)")
    ax.set_xlabel("Producto")
    ax.set_ylabel("Unidades")
    ax.set_xticks(list(x))
    ax.set_xticklabels(d["Etiqueta"], rotation=45, ha="right", fontsize=8)
    ax.legend(loc="upper right", fontsize=9)
    ax.set_axisbelow(True)
    fig.tight_layout()
    return fig


def figura_desperdicio_motivo(df, ancho=9, alto=6):
    """Gráfico circular de desperdicio por motivo (tema oscuro)."""
    fig, ax = plt.subplots(figsize=(ancho, alto))
    d = df.sort_values("Cantidad_Desperdiciada", ascending=False).reset_index(drop=True)
    paleta = [COLORS["primary"], COLORS["secondary"], COLORS["accent"],
              COLORS["success"], "#666666"]
    colores = [paleta[i % len(paleta)] for i in range(len(d))]
    etiquetas = [f"{m} ({p:.1f}%)" for m, p in zip(d["Motivo"], d["Porcentaje"])]
    ax.pie(d["Cantidad_Desperdiciada"], labels=etiquetas, colors=colores,
           autopct="%1.1f%%", startangle=90, counterclock=False,
           textprops={"fontsize": 9, "color": "#FFFFFF"},
           wedgeprops={"edgecolor": "#0E0E0E", "linewidth": 1.2})
    ax.set_title("Desperdicio por motivo (% del total de unidades)")
    ax.axis("equal")
    fig.tight_layout()
    return fig


def figura_margen_producto(df, margen_global, ancho=10, alto=6):
    """Gráfico de margen: 5 mejores (verde) vs 5 más bajos (rojo, tema oscuro)."""
    fig, ax = plt.subplots(figsize=(ancho, alto))
    d = df.dropna(subset=["Margen_Porcentual"]).sort_values(
        "Margen_Porcentual", ascending=False
    ).reset_index(drop=True)
    top5 = d.head(5)
    bottom5 = d.tail(5)
    sel = pd.concat([top5, bottom5]).sort_values("Margen_Porcentual", ascending=True)
    colores = [
        COLORS["danger"] if m in set(bottom5["Margen_Porcentual"])
        else COLORS["success"]
        for m in sel["Margen_Porcentual"]
    ]
    ax.barh(sel["Producto"], sel["Margen_Porcentual"], color=colores, zorder=3)
    ax.set_title("Margen de ganancia (%): 5 mejores vs. 5 más bajos")
    ax.set_xlabel("Margen porcentual (%)")
    ax.axvline(margen_global, color="#FFFFFF", linestyle="--", linewidth=1)
    ax.text(
        margen_global, ax.get_ylim()[1] * 0.95,
        f"Global: {margen_global:.1f}%", rotation=90,
        va="top", ha="right", fontsize=8, color="#FFFFFF"
    )
    ax.set_axisbelow(True)
    fig.tight_layout()
    return fig


def figura_clientes_vip(df, ancho=11, alto=6):
    """Gráfico Pareto: top 15 clientes con línea de % acumulado (tema oscuro)."""
    fig, ax = plt.subplots(figsize=(ancho, alto))
    d = df.sort_values("Valor_Compras", ascending=False).head(15).reset_index(drop=True)
    x = range(len(d))
    ax.bar(x, d["Valor_Compras"], color=COLORS["secondary"], width=0.65,
           label="Valor de compras", zorder=3)
    ax.set_title("Top 15 clientes: valor de compra y % acumulado (Pareto)")
    ax.set_xlabel("Cliente")
    ax.set_ylabel("Valor de compras ($ COP)")
    ax.set_xticks(list(x))
    ax.set_xticklabels(d["Nombre"], rotation=45, ha="right", fontsize=8)
    ax.yaxis.set_major_formatter(
        mtick.FuncFormatter(lambda v, _: f"${v:,.0f}")
    )
    ax2 = ax.twinx()
    ax2.plot(x, d["Pct_Acumulado"], color=COLORS["accent"], marker="o",
             markersize=5, linewidth=2, label="% acumulado", zorder=4)
    ax2.set_ylabel("% acumulado de ingresos")
    ax2.set_ylim(0, 105)
    ax2.grid(False)
    h1, l1 = ax.get_legend_handles_labels()
    h2, l2 = ax2.get_legend_handles_labels()
    ax.legend(h1 + h2, l1 + l2, loc="upper right", fontsize=9)
    ax.set_axisbelow(True)
    fig.tight_layout()
    return fig


def figura_perdida_proveedor(df, ancho=10, alto=6):
    """Gráfico de % de pérdida estimado por proveedor (tema oscuro)."""
    fig, ax = plt.subplots(figsize=(ancho, alto))
    agg = (df.groupby("Nombre_Proveedor", as_index=False)
             .agg(Perdida=("Perdida_Atribuida_Estimada", "sum"),
                  Recibido=("Cantidad_Suministrada_Por_Proveedor", "sum")))
    agg["Pct"] = (100 * agg["Perdida"] / agg["Recibido"].replace(0, pd.NA)).fillna(0.0)
    agg = agg.sort_values("Pct", ascending=False).reset_index(drop=True)
    x = range(len(agg))
    ax.bar(x, agg["Pct"], color=COLORS["accent"], width=0.65, zorder=3)
    ax.set_title("% de pérdida estimado por proveedor (ponderado)")
    ax.set_ylabel("% de pérdida sobre lo suministrado")
    ax.set_xlabel("Proveedor")
    ax.set_xticks(list(x))
    ax.set_xticklabels(agg["Nombre_Proveedor"], rotation=45, ha="right", fontsize=8)
    ax.set_axisbelow(True)
    fig.tight_layout()
    return fig


def figura_escenarios(df_escenarios, producto_seleccionado, ancho=10, alto=5):
    """Gráfico de barras de escenarios para un producto seleccionado (tema oscuro)."""
    fig, ax = plt.subplots(figsize=(ancho, alto))
    from config import PREDICTION_CONFIG
    config = PREDICTION_CONFIG["scenarios"]

    nombres = [config[s]["label"] for s in ["Conservador", "Medio", "Optimista"]]
    valores = []
    colores = []
    for clave in ["Conservador", "Medio", "Optimista"]:
        fila = df_escenarios[df_escenarios["ID_Producto"] == producto_seleccionado]
        if not fila.empty:
            valores.append(fila.iloc[0][f"P{config[clave]['percentile']}"])
        else:
            valores.append(0)
        colores.append(config[clave]["color"])

    barras = ax.bar(nombres, valores, color=colores, width=0.5, zorder=3)
    for barra, val in zip(barras, valores):
        ax.text(barra.get_x() + barra.get_width() / 2, barra.get_height() + 0.5,
                f"{val:.1f}", ha="center", va="bottom", fontsize=9, fontweight="bold", color="#FFFFFF")

    ax.set_title(f"Escenarios de demanda a 4 semanas — {producto_seleccionado}")
    ax.set_ylabel("Unidades")
    ax.set_axisbelow(True)
    fig.tight_layout()
    return fig
