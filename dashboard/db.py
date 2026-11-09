"""
Capa de acceso a datos: conexión a MySQL y carga de tablas del proyecto Frexco.
"""
import mysql.connector
import pandas as pd
from config import DB_CONFIG


def get_connection():
    """Establece y devuelve una conexión a la base de datos MySQL `frexco`."""
    return mysql.connector.connect(**DB_CONFIG)


def load_ventas_detalle(conn):
    """Carga ventas con detalle de producto, categoría y unidad de medida."""
    query = """
    SELECT
        v.Fecha_Venta,
        dv.ID_Producto,
        p.Nombre AS Producto,
        p.Unidad_Medida,
        p.Durabilidad_Dias,
        cat.Nombre_Categoria AS Categoria,
        dv.Cantidad,
        dv.Subtotal
    FROM venta v
    JOIN detalle_venta dv ON dv.ID_Venta = v.ID_Venta
    JOIN producto p ON p.ID_Producto = dv.ID_Producto
    JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria
    """
    df = pd.read_sql(query, conn)
    df["Fecha_Venta"] = pd.to_datetime(df["Fecha_Venta"])
    return df


def load_ventas_mensuales(conn):
    """Carga agregación de ventas por mes (KPI 1)."""
    query = """
    SELECT
        YEAR(Fecha_Venta) AS Anio,
        MONTH(Fecha_Venta) AS Mes,
        COUNT(*) AS Numero_Ventas,
        SUM(Total_Venta) AS Ventas_Totales,
        AVG(Total_Venta) AS Ticket_Promedio
    FROM venta
    GROUP BY YEAR(Fecha_Venta), MONTH(Fecha_Venta)
    ORDER BY Anio, Mes
    """
    return pd.read_sql(query, conn)


def load_top_productos(conn):
    """Carga top productos por cantidad vendida con su categoría."""
    query = """
    SELECT
        p.ID_Producto,
        p.Nombre AS Producto,
        cat.Nombre_Categoria AS Categoria,
        SUM(dv.Cantidad) AS Unidades_Vendidas,
        SUM(dv.Subtotal) AS Venta_Detallada
    FROM detalle_venta dv
    JOIN producto p ON p.ID_Producto = dv.ID_Producto
    JOIN categoria cat ON cat.ID_Categoria = p.ID_Categoria
    GROUP BY p.ID_Producto, p.Nombre, cat.Nombre_Categoria
    ORDER BY Unidades_Vendidas DESC
    """
    return pd.read_sql(query, conn)


def load_desperdicio_producto(conn):
    """Carga desperdicio total por producto."""
    query = """
    SELECT
        p.ID_Producto,
        p.Nombre AS Producto,
        SUM(dd.Cantidad) AS Unidades_Desperdiciadas,
        COUNT(DISTINCT dd.ID_Desperdicio) AS Eventos_Desperdicio
    FROM detalle_desperdicio dd
    JOIN producto p ON p.ID_Producto = dd.ID_Producto
    GROUP BY p.ID_Producto, p.Nombre
    ORDER BY Unidades_Desperdiciadas DESC
    """
    return pd.read_sql(query, conn)


def load_desperdicio_motivo(conn):
    """Carga desperdicio por motivo (KPI 3)."""
    query = """
    SELECT
        Motivo,
        COUNT(*) AS Registros,
        SUM(Cantidad) AS Cantidad_Desperdiciada,
        ROUND(100 * SUM(Cantidad) /
              (SELECT SUM(Cantidad) FROM detalle_desperdicio), 2) AS Porcentaje
    FROM detalle_desperdicio
    GROUP BY Motivo
    ORDER BY Cantidad_Desperdiciada DESC
    """
    return pd.read_sql(query, conn)


def load_margen_producto(conn):
    """Carga margen de ganancia por producto (KPI 4a)."""
    query = """
    SELECT
        p.ID_Producto,
        p.Nombre AS Producto,
        ROUND(AVG(dv.Precio_Unitario), 2) AS Precio_Venta_Promedio,
        ROUND(costo.Costo_Unitario_Promedio, 2) AS Costo_Unitario_Promedio,
        ROUND(AVG(dv.Precio_Unitario) - costo.Costo_Unitario_Promedio, 2) AS Margen_Absoluto,
        ROUND(100 * (AVG(dv.Precio_Unitario) - costo.Costo_Unitario_Promedio)
              / AVG(dv.Precio_Unitario), 2) AS Margen_Porcentual
    FROM producto p
    JOIN detalle_venta dv ON dv.ID_Producto = p.ID_Producto
    JOIN (
        SELECT ID_Producto, AVG(Precio_Compra / Cantidad_Recibida)
             AS Costo_Unitario_Promedio
        FROM detalle_proveedor
        GROUP BY ID_Producto
    ) costo ON costo.ID_Producto = p.ID_Producto
    GROUP BY p.ID_Producto, p.Nombre, costo.Costo_Unitario_Promedio
    ORDER BY Margen_Porcentual DESC
    """
    return pd.read_sql(query, conn)


def load_margen_global(conn):
    """Carga margen global estimado del negocio (KPI 4b)."""
    query = """
    SELECT
        SUM(dv.Subtotal) AS Ingresos_Totales,
        ROUND(SUM(dv.Cantidad * costo.Costo_Unitario_Promedio), 2)
            AS Costo_Estimado_Total,
        ROUND(SUM(dv.Subtotal) - SUM(dv.Cantidad * costo.Costo_Unitario_Promedio), 2)
            AS Margen_Absoluto_Global,
        ROUND(100 * (SUM(dv.Subtotal) - SUM(dv.Cantidad * costo.Costo_Unitario_Promedio))
              / SUM(dv.Subtotal), 2) AS Margen_Porcentual_Global
    FROM detalle_venta dv
    JOIN (
        SELECT ID_Producto, AVG(Precio_Compra / Cantidad_Recibida)
             AS Costo_Unitario_Promedio
        FROM detalle_proveedor
        GROUP BY ID_Producto
    ) costo ON costo.ID_Producto = dv.ID_Producto
    """
    return pd.read_sql(query, conn)


def load_clientes_vip(conn):
    """Carga clientes VIP con regla 80/20 y % acumulado (KPI 5)."""
    query = """
    SELECT
        t1.ID_Cliente,
        t1.Nombre,
        t1.Valor_Compras,
        ROUND(100 * t1.Valor_Compras /
              (SELECT SUM(Total_Venta) FROM venta), 2) AS Pct_Ingresos,
        ROUND(100 * (
            SELECT SUM(t2.Valor_Compras)
            FROM (
                SELECT c2.ID_Cliente, SUM(v2.Total_Venta) AS Valor_Compras
                FROM cliente c2
                JOIN venta v2 ON v2.ID_Cliente = c2.ID_Cliente
                GROUP BY c2.ID_Cliente
            ) t2
            WHERE t2.Valor_Compras >= t1.Valor_Compras
        ) / (SELECT SUM(Total_Venta) FROM venta), 2) AS Pct_Acumulado
    FROM (
        SELECT c.ID_Cliente, c.Nombre, SUM(v.Total_Venta) AS Valor_Compras
        FROM cliente c
        JOIN venta v ON v.ID_Cliente = c.ID_Cliente
        GROUP BY c.ID_Cliente, c.Nombre
    ) t1
    ORDER BY t1.Valor_Compras DESC
    """
    return pd.read_sql(query, conn)


def load_perdida_proveedor(conn):
    """Carga pérdida estimada por proveedor y producto (KPI 6)."""
    query = """
    SELECT
        pr.ID_Proveedor,
        pr.Nombre_Proveedor,
        p.ID_Producto,
        p.Nombre AS Producto,
        dpp.Cantidad_Recibida AS Cantidad_Suministrada_Por_Proveedor,
        tot.Total_Recibido_Producto,
        COALESCE(totd.Total_Desperdicio_Producto, 0) AS Total_Desperdicio_Producto,
        ROUND(dpp.Cantidad_Recibida / tot.Total_Recibido_Producto
              * COALESCE(totd.Total_Desperdicio_Producto, 0), 2)
            AS Perdida_Atribuida_Estimada,
        ROUND(100 * (dpp.Cantidad_Recibida / tot.Total_Recibido_Producto
              * COALESCE(totd.Total_Desperdicio_Producto, 0))
              / dpp.Cantidad_Recibida, 2) AS Pct_Perdida_Sobre_Lo_Suministrado
    FROM (
        SELECT ID_Proveedor, ID_Producto, SUM(Cantidad_Recibida) AS Cantidad_Recibida
        FROM detalle_proveedor
        GROUP BY ID_Proveedor, ID_Producto
    ) dpp
    JOIN proveedor pr ON pr.ID_Proveedor = dpp.ID_Proveedor
    JOIN producto p ON p.ID_Producto = dpp.ID_Producto
    JOIN (
        SELECT ID_Producto, SUM(Cantidad_Recibida) AS Total_Recibido_Producto
        FROM detalle_proveedor
        GROUP BY ID_Producto
    ) tot ON tot.ID_Producto = dpp.ID_Producto
    LEFT JOIN (
        SELECT ID_Producto, SUM(Cantidad) AS Total_Desperdicio_Producto
        FROM detalle_desperdicio
        GROUP BY ID_Producto
    ) totd ON totd.ID_Producto = dpp.ID_Producto
    ORDER BY Pct_Perdida_Sobre_Lo_Suministrado DESC
    """
    return pd.read_sql(query, conn)
