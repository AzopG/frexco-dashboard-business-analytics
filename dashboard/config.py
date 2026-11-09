"""
Configuración centralizada del dashboard Frexco - Business Analytics.
"""
import os
from dotenv import load_dotenv

load_dotenv()

# ---------------------------------------------------------------------------
# Base de datos MySQL (variables de entorno con valores por defecto seguros)
# ---------------------------------------------------------------------------
DB_CONFIG = {
    "host": os.getenv("FREXCO_DB_HOST", "localhost"),
    "user": os.getenv("FREXCO_DB_USER", "root"),
    "password": os.getenv("FREXCO_DB_PASSWORD", ""),
    "database": os.getenv("FREXCO_DB_NAME", "frexco"),
    "charset": "utf8",
}

# ---------------------------------------------------------------------------
# Paleta de colores corporativa (coherente con la identidad Frexco)
# ---------------------------------------------------------------------------
COLORS = {
    "primary": "#1F3864",      # Azul oscuro corporativo
    "secondary": "#4768B5",    # Azul medio
    "accent": "#ED7D31",       # Naranja de alerta
    "success": "#4CAF50",      # Verde de ok
    "danger": "#C00000",       # Rojo de riesgo
    "warning": "#FFC000",      # Ámbar de precaución
    "light": "#F2F2F2",        # Fondo claro
    "text": "#404040",         # Texto principal
    "muted": "#808080",        # Texto secundario
}

# ---------------------------------------------------------------------------
# Configuración del módulo de predicción
# ---------------------------------------------------------------------------
PREDICTION_CONFIG = {
    "horizon_weeks": 4,
    "min_train_weeks": 12,
    "scenarios": {
        "Conservador": {
            "label": "Conservador (P10)",
            "percentile": 10,
            "color": COLORS["danger"],
            "descripcion": "Escenario cauteloso: demanda baja, evita sobrecompra y merma.",
        },
        "Medio": {
            "label": "Medio (P50)",
            "percentile": 50,
            "color": COLORS["secondary"],
            "descripcion": "Escenario base: demanda mediana esperada, equilibrio stock/venta.",
        },
        "Optimista": {
            "label": "Optimista (P90)",
            "percentile": 90,
            "color": COLORS["success"],
            "descripcion": "Escenario agresivo: demanda alta, prioriza no quedarse sin producto.",
        },
    },
}

# ---------------------------------------------------------------------------
# Rutas del proyecto
# ---------------------------------------------------------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ASSETS_DIR = os.path.join(BASE_DIR, "assets")

os.makedirs(ASSETS_DIR, exist_ok=True)
