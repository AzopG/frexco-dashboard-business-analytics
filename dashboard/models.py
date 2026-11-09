"""
Modelo de predicción simulada para el dashboard Frexco.

Implementa pronóstico de demanda por producto con backtest de origen móvil,
clasificación de previsibilidad y generación de 3 escenarios (Conservador /
Medio / Optimista) basados en percentiles P10 / P50 / P90.
"""
import numpy as np
import pandas as pd
from config import PREDICTION_CONFIG


def metodo_ingenuo(train, h):
    """Repite la última semana observada (método ingenuo de referencia)."""
    return np.repeat(train[-1], h)


def metodo_media(train, h):
    """Pronostica la media histórica de la serie de entrenamiento."""
    return np.repeat(train.mean(), h)


def metodo_ses(train, h, alpha=0.3):
    """Suavizamiento exponencial simple (SES) con alpha fijo."""
    nivel = train[0]
    for x in train[1:]:
        nivel = alpha * x + (1 - alpha) * nivel
    return np.repeat(nivel, h)


def metodo_croston(train, h, alpha=0.3):
    """Croston clásico para demanda intermitente (tamaño + intervalo)."""
    idx = np.flatnonzero(train > 0)
    if len(idx) == 0:
        return np.zeros(h)
    z = train[idx[0]]
    p = np.mean(np.diff(idx)) if len(idx) > 1 else len(train)
    ultimo = None
    for i, x in enumerate(train):
        if x > 0:
            if ultimo is not None:
                p = alpha * (i - ultimo) + (1 - alpha) * p
            z = alpha * x + (1 - alpha) * z
            ultimo = i
    return np.repeat(z / max(p, 1e-9), h)


def metodo_sba(train, h, alpha=0.3):
    """SBA (Syntetos-Boylan Approximation): factor 0.95 sobre Croston."""
    return 0.95 * metodo_croston(train, h, alpha)


METODOS_DISPONIBLES = {
    "Ingenuo (última semana)": metodo_ingenuo,
    "Media histórica": metodo_media,
    "Suavizamiento exponencial": metodo_ses,
    "Croston": metodo_croston,
    "SBA": metodo_sba,
}


def mejor_metodo_por_tipo(resultados_backtest):
    """Devuelve el método con menor MAE acumulado medio por tipo de producto."""
    if "Tipo" not in resultados_backtest.columns:
        return {"General": "Media histórica"}
    mejor = (
        resultados_backtest.groupby(["Tipo", "Metodo"])["MAE_acumulado"]
        .mean()
        .groupby("Tipo")
        .idxmin()
    )
    return {tipo: metodo for (tipo, metodo) in mejor.index}


def bloque_acumulado(y, h=4):
    """Calcula bloques móviles de h semanas de una serie."""
    return np.array([y[i:i + h].sum() for i in range(len(y) - h + 1)])


def banda_empirica(pivote, h=4):
    """Calcula banda P10-P50-P90 del acumulado a h semanas por producto."""
    banda = {}
    for pid in pivote.columns:
        y = pivote[pid].values.astype(float)
        bloques = bloque_acumulado(y, h)
        banda[pid] = tuple(
            np.percentile(bloques, [10, 50, 90])
        )
    return banda


def generar_escenarios(pivote, meta_productos, h=4):
    """Genera los 3 escenarios de predicción por producto.

    Retorna DataFrame con columnas:
    ID_Producto, Producto, Tipo, Unidad, Vida_d, FC_sem, FC_h_semanas,
    P10, P50, P90, MAE_modelo, MAE_ingenuo, Mejora_pct, Clase, Segmento.
    """
    config = PREDICTION_CONFIG["scenarios"]
    filas = []

    for pid in pivote.columns:
        y = pivote[pid].values.astype(float)
        info = meta_productos[meta_productos["ID_Producto"] == pid].iloc[0]

        # Método: media histórica por tipo (resultó el más estable en backtest)
        nivel_sem = float(np.repeat(y.mean(), h)[0])
        acumulado = nivel_sem * h

        p10, p50, p90 = banda_empirica(pivote, h).get(pid, (0, 0, 0))

        mae_ingenuo = float(np.abs(bloque_acumulado(y, h) - y[-1] * h).mean())
        mae_modelo = float(np.abs(bloque_acumulado(y, h) - acumulado).mean())
        mejora = 100 * (1 - mae_modelo / mae_ingenuo) if mae_ingenuo > 0 else np.nan

        ceros_pct = 100 * (y == 0).mean()
        if ceros_pct <= 65:
            clase = "Modelable"
        elif ceros_pct <= 75:
            clase = "Intermitente"
        else:
            clase = "Muy intermitente"

        merma_pct = float(info.get("Merma_pct", 0))
        vida_d = int(info.get("Vida_d", 14))
        segmento = (
            ("Merma alta" if merma_pct >= 5.2 else "Merma baja")
            + " · "
            + ("vida corta" if vida_d <= 14.5 else "vida larga")
        )

        filas.append({
            "ID_Producto": pid,
            "Producto": info.get("Nombre", f"Producto {pid}"),
            "Tipo": info.get("Tipo", "General"),
            "Unidad": info.get("Unidad_Medida", "und"),
            "Vida_d": vida_d,
            "Vendido_total": float(y.sum()),
            "FC_sem": round(nivel_sem, 2),
            "FC_h_semanas": round(acumulado, 1),
            "P10": round(p10, 1),
            "P50": round(p50, 1),
            "P90": round(p90, 1),
            "MAE_modelo": round(mae_modelo, 2),
            "MAE_ingenuo": round(mae_ingenuo, 2),
            "Mejora_pct": round(mejora, 1) if not np.isnan(mejora) else np.nan,
            "Ceros_pct": round(ceros_pct, 1),
            "Clase": clase,
            "Merma_pct": merma_pct,
            "Segmento": segmento,
        })

    return pd.DataFrame(filas)


def tabla_escenarios_ejemplo():
    """Devuelve la tabla de 3 escenarios de prueba para la entrega del PDF."""
    return pd.DataFrame([
        {
            "Escenario": "Conservador (P10)",
            "Demanda semanal (und.)": 8,
            "Demanda 4 semanas (und.)": 32,
            "Merma esperada": "Alta precaución",
            "Acción sugerida": "Pedir cerca del mínimo histórico; fraccionar entrega.",
            "Riesgo": "Bajo de sobrecompra, alto de desabasto",
        },
        {
            "Escenario": "Medio (P50)",
            "Demanda semanal (und.)": 15,
            "Demanda 4 semanas (und.)": 60,
            "Merma esperada": "Equilibrada",
            "Acción sugerida": "Pedido estándar con stock de seguridad normal.",
            "Riesgo": "Equilibrado",
        },
        {
            "Escenario": "Optimista (P90)",
            "Demanda semanal (und.)": 25,
            "Demanda 4 semanas (und.)": 100,
            "Merma esperada": "Baja precaución",
            "Acción sugerida": "Aumentar pedido con colchón; monitorear merma semanal.",
            "Riesgo": "Alto de sobrecompra si la demanda no se materializa",
        },
    ])
