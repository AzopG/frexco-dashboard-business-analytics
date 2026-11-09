"""
Capa de procesamiento ETL: limpieza, agregación y preparación de datos
para el dashboard y el módulo de predicción.
"""
import warnings

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore")


def to_numeric(df, columns):
    """Convierte columnas DECIMAL/objeto a float numérico."""
    df = df.copy()
    for col in columns:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")
    return df


def preparar_kpi2(top_productos, desp_producto):
    """Combina ventas y desperdicio por producto para el KPI 2."""
    kpi2 = top_productos.merge(
        desp_producto[["ID_Producto", "Unidades_Desperdiciadas"]],
        on="ID_Producto", how="left",
    )
    kpi2["Unidades_Desperdiciadas"] = kpi2["Unidades_Desperdiciadas"].fillna(0)
    return kpi2


def metricas_globales(data):
    """Calcula métricas globales de negocio para los cards del dashboard."""
    ventas = data["ventas_mensuales"]
    margen_global = data["margen_global"]
    desp = data["desperdicio_producto"]

    total_ventas = float(ventas["Ventas_Totales"].sum()) if not ventas.empty else 0.0
    n_ventas = float(ventas["Numero_Ventas"].sum()) if not ventas.empty else 0.0
    ticket = total_ventas / n_ventas if n_ventas else 0.0
    margen = (float(margen_global["Margen_Porcentual_Global"].iloc[0])
              if not margen_global.empty else float("nan"))
    desperdicio = (float(desp["Unidades_Desperdiciadas"].sum())
                   if not desp.empty else 0.0)
    return {
        "total_ventas": total_ventas,
        "ticket_promedio": ticket,
        "margen_global": margen,
        "desperdicio_total": desperdicio,
    }


def serie_semanal_por_producto(df_ventas):
    """Construye la serie semanal de unidades vendidas por producto.

    Devuelve un DataFrame con índice = semana de inicio (lunes) y columnas = ID_Producto.
    """
    df = df_ventas.copy()
    df["Semana"] = df["Fecha_Venta"] - pd.to_timedelta(
        df["Fecha_Venta"].dt.weekday, unit="D"
    )
    pivot = (
        df.pivot_table(
            index="Semana",
            columns="ID_Producto",
            values="Cantidad",
            aggfunc="sum",
        )
        .fillna(0)
        .sort_index()
    )
    return pivot


def clasificar_previsibilidad(pivote, umbral_modelable=65, umbral_intermitente=75):
    """Clasifica cada producto según su grado de intermitencia (ceros %).

    Retorna DataFrame con columnas: ID_Producto, Producto, Unidad, Tipo,
    Vida_d, Vendido, Media_sem, Ceros_%, CV, Clase.
    """
    from config import COLORS  # import diferido para evitar ciclo

    filas = []
    for pid in pivote.columns:
        y = pivote[pid].values.astype(float)
        ceros_pct = 100 * (y == 0).mean()
        nz = y[y > 0]
        cv = y.std() / y.mean() if y.mean() else np.nan
        if ceros_pct <= umbral_modelable:
            clase = "Modelable"
        elif ceros_pct <= umbral_intermitente:
            clase = "Intermitente"
        else:
            clase = "Muy intermitente"
        filas.append({
            "ID_Producto": pid,
            "Producto": f"Producto {pid}",
            "Unidad": "und",
            "Tipo": "General",
            "Vida_d": 0,
            "Vendido": float(y.sum()),
            "Media_sem": float(y.mean()),
            "Ceros_pct": ceros_pct,
            "CV": cv,
            "Clase": clase,
        })
    return pd.DataFrame(filas)


def backtest_por_producto(pivote, metodos, h=4, min_train=12):
    """Ejecuta backtest de origen móvil para cada producto y método.

    Retorna DataFrame con error absoluto medio (MAE) del acumulado a h semanas.
    """
    resultados = []
    n = len(pivote)
    for pid in pivote.columns:
        y = pivote[pid].values.astype(float)
        for nombre, funcion in metodos.items():
            errores_acumulados = []
            reales_acumulados = []
            for t0 in range(min_train, n - h + 1):
                real = y[t0:t0 + h]
                pred = np.asarray(funcion(y[:t0], h), dtype=float)
                errores_acumulados.append(real.sum() - pred.sum())
                reales_acumulados.append(real.sum())
            e = np.array(errores_acumulados)
            r = np.array(reales_acumulados)
            resultados.append({
                "ID_Producto": pid,
                "Metodo": nombre,
                "MAE_acumulado": float(np.abs(e).mean()),
                "WAPE_acumulado": float(100 * np.abs(e).sum() / max(r.sum(), 1)),
            })
    return pd.DataFrame(resultados)
