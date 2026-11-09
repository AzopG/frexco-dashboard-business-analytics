-- =====================================================================
-- SCRIPT DE CORRECCION FREXCO (generado automaticamente)
-- Fuente: Frexco (3).sql  |  Base destino: frexco
-- =====================================================================

USE frexco;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. Reasignacion semantica de categorias de producto
UPDATE producto SET ID_Categoria = 1 WHERE ID_Producto = 1;
UPDATE producto SET ID_Categoria = 1 WHERE ID_Producto = 2;
UPDATE producto SET ID_Categoria = 1 WHERE ID_Producto = 3;
UPDATE producto SET ID_Categoria = 5 WHERE ID_Producto = 4;
UPDATE producto SET ID_Categoria = 5 WHERE ID_Producto = 5;
UPDATE producto SET ID_Categoria = 1 WHERE ID_Producto = 6;
UPDATE producto SET ID_Categoria = 1 WHERE ID_Producto = 7;
UPDATE producto SET ID_Categoria = 1 WHERE ID_Producto = 8;
UPDATE producto SET ID_Categoria = 1 WHERE ID_Producto = 9;
UPDATE producto SET ID_Categoria = 1 WHERE ID_Producto = 10;
UPDATE producto SET ID_Categoria = 7 WHERE ID_Producto = 11;
UPDATE producto SET ID_Categoria = 7 WHERE ID_Producto = 12;
UPDATE producto SET ID_Categoria = 3 WHERE ID_Producto = 13;
UPDATE producto SET ID_Categoria = 3 WHERE ID_Producto = 14;
UPDATE producto SET ID_Categoria = 7 WHERE ID_Producto = 15;
UPDATE producto SET ID_Categoria = 7 WHERE ID_Producto = 16;
UPDATE producto SET ID_Categoria = 2 WHERE ID_Producto = 17;
UPDATE producto SET ID_Categoria = 4 WHERE ID_Producto = 18;
UPDATE producto SET ID_Categoria = 7 WHERE ID_Producto = 19;
UPDATE producto SET ID_Categoria = 7 WHERE ID_Producto = 20;

-- 2. Dia_Semana recalculado desde Fecha_Venta (177 registros incorrectos)
UPDATE venta
SET Dia_Semana = ELT(WEEKDAY(Fecha_Venta)+1,
  'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo');

-- 3. Correo electronico duplicado (cliente 24)
UPDATE cliente SET Correo = 'ricardo.garcia.2@gmail.com' WHERE ID_Cliente = 24;

-- 4. Fecha_Vencimiento recortada a Fecha_Ingreso + Durabilidad_Dias (68 recepciones)
UPDATE detalle_proveedor dp
JOIN producto p ON p.ID_Producto = dp.ID_Producto
SET dp.Fecha_Vencimiento = DATE_ADD(dp.Fecha_Ingreso, INTERVAL p.Durabilidad_Dias DAY)
WHERE DATEDIFF(dp.Fecha_Vencimiento, dp.Fecha_Ingreso) > p.Durabilidad_Dias;

-- 5. Precios unitarios fuera de rango razonable (costo x [0.5, 5.0])
--    Se normalizan a costo x 1.5 y se recalcula Subtotal
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 7261.42 WHERE ID_DetalleVenta = 2;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 2480.35 WHERE ID_DetalleVenta = 3;
UPDATE detalle_venta SET Precio_Unitario = 5373.08, Subtotal = 5373.08 WHERE ID_DetalleVenta = 5;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 9002.76 WHERE ID_DetalleVenta = 9;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 2480.35 WHERE ID_DetalleVenta = 10;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 11;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 7753.76 WHERE ID_DetalleVenta = 12;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 25439.95 WHERE ID_DetalleVenta = 13;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 17;
UPDATE detalle_venta SET Precio_Unitario = 3620.10, Subtotal = 7240.20 WHERE ID_DetalleVenta = 18;
UPDATE detalle_venta SET Precio_Unitario = 7587.09, Subtotal = 37935.45 WHERE ID_DetalleVenta = 19;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 21;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 5087.99 WHERE ID_DetalleVenta = 22;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 11630.64 WHERE ID_DetalleVenta = 24;
UPDATE detalle_venta SET Precio_Unitario = 3430.95, Subtotal = 3430.95 WHERE ID_DetalleVenta = 25;
UPDATE detalle_venta SET Precio_Unitario = 3620.10, Subtotal = 3620.10 WHERE ID_DetalleVenta = 27;
UPDATE detalle_venta SET Precio_Unitario = 7587.09, Subtotal = 22761.27 WHERE ID_DetalleVenta = 28;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 366712.50 WHERE ID_DetalleVenta = 29;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 6282.44 WHERE ID_DetalleVenta = 32;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 27261.60 WHERE ID_DetalleVenta = 33;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 34;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 4960.70 WHERE ID_DetalleVenta = 35;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 17362.45 WHERE ID_DetalleVenta = 36;
UPDATE detalle_venta SET Precio_Unitario = 12267.87, Subtotal = 12267.87 WHERE ID_DetalleVenta = 37;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 25414.97 WHERE ID_DetalleVenta = 40;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 6815.40 WHERE ID_DetalleVenta = 41;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 82152.58 WHERE ID_DetalleVenta = 42;
UPDATE detalle_venta SET Precio_Unitario = 16830.16, Subtotal = 33660.32 WHERE ID_DetalleVenta = 44;
UPDATE detalle_venta SET Precio_Unitario = 10832.53, Subtotal = 10832.53 WHERE ID_DetalleVenta = 45;
UPDATE detalle_venta SET Precio_Unitario = 3430.95, Subtotal = 3430.95 WHERE ID_DetalleVenta = 47;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 3876.88 WHERE ID_DetalleVenta = 48;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 6815.40 WHERE ID_DetalleVenta = 49;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 12401.75 WHERE ID_DetalleVenta = 51;
UPDATE detalle_venta SET Precio_Unitario = 16830.16, Subtotal = 84150.80 WHERE ID_DetalleVenta = 52;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 6282.44 WHERE ID_DetalleVenta = 58;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 9002.76 WHERE ID_DetalleVenta = 59;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 342265.00 WHERE ID_DetalleVenta = 60;
UPDATE detalle_venta SET Precio_Unitario = 10832.53, Subtotal = 173320.48 WHERE ID_DetalleVenta = 62;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 5087.99 WHERE ID_DetalleVenta = 63;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 64;
UPDATE detalle_venta SET Precio_Unitario = 3373.39, Subtotal = 3373.39 WHERE ID_DetalleVenta = 65;
UPDATE detalle_venta SET Precio_Unitario = 6331.15, Subtotal = 12662.30 WHERE ID_DetalleVenta = 67;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 6815.40 WHERE ID_DetalleVenta = 68;
UPDATE detalle_venta SET Precio_Unitario = 10832.53, Subtotal = 21665.06 WHERE ID_DetalleVenta = 70;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 47126.65 WHERE ID_DetalleVenta = 72;
UPDATE detalle_venta SET Precio_Unitario = 3620.10, Subtotal = 10860.30 WHERE ID_DetalleVenta = 73;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 415607.50 WHERE ID_DetalleVenta = 77;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 18847.32 WHERE ID_DetalleVenta = 80;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 4323.82 WHERE ID_DetalleVenta = 81;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 82;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 391160.00 WHERE ID_DetalleVenta = 84;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 18005.52 WHERE ID_DetalleVenta = 87;
UPDATE detalle_venta SET Precio_Unitario = 3620.10, Subtotal = 3620.10 WHERE ID_DetalleVenta = 88;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 3630.71 WHERE ID_DetalleVenta = 89;
UPDATE detalle_venta SET Precio_Unitario = 10832.53, Subtotal = 10832.53 WHERE ID_DetalleVenta = 90;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 77537.60 WHERE ID_DetalleVenta = 91;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 5087.99 WHERE ID_DetalleVenta = 92;
UPDATE detalle_venta SET Precio_Unitario = 7334.27, Subtotal = 7334.27 WHERE ID_DetalleVenta = 93;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 6282.44 WHERE ID_DetalleVenta = 94;
UPDATE detalle_venta SET Precio_Unitario = 7334.27, Subtotal = 7334.27 WHERE ID_DetalleVenta = 95;
UPDATE detalle_venta SET Precio_Unitario = 12267.87, Subtotal = 159482.31 WHERE ID_DetalleVenta = 97;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 24447.50 WHERE ID_DetalleVenta = 98;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 17295.28 WHERE ID_DetalleVenta = 99;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 5087.99 WHERE ID_DetalleVenta = 100;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 6815.40 WHERE ID_DetalleVenta = 101;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 9002.76 WHERE ID_DetalleVenta = 102;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 12564.88 WHERE ID_DetalleVenta = 103;
UPDATE detalle_venta SET Precio_Unitario = 7334.27, Subtotal = 7334.27 WHERE ID_DetalleVenta = 104;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 122237.50 WHERE ID_DetalleVenta = 105;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 4323.82 WHERE ID_DetalleVenta = 106;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 24447.50 WHERE ID_DetalleVenta = 108;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 6815.40 WHERE ID_DetalleVenta = 109;
UPDATE detalle_venta SET Precio_Unitario = 7334.27, Subtotal = 7334.27 WHERE ID_DetalleVenta = 111;
UPDATE detalle_venta SET Precio_Unitario = 5373.08, Subtotal = 21492.32 WHERE ID_DetalleVenta = 112;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 3630.71 WHERE ID_DetalleVenta = 117;
UPDATE detalle_venta SET Precio_Unitario = 3620.10, Subtotal = 3620.10 WHERE ID_DetalleVenta = 120;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 4570.59 WHERE ID_DetalleVenta = 121;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 125;
UPDATE detalle_venta SET Precio_Unitario = 16830.16, Subtotal = 16830.16 WHERE ID_DetalleVenta = 126;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 14522.84 WHERE ID_DetalleVenta = 127;
UPDATE detalle_venta SET Precio_Unitario = 3430.95, Subtotal = 3430.95 WHERE ID_DetalleVenta = 128;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 24447.50 WHERE ID_DetalleVenta = 129;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 10175.98 WHERE ID_DetalleVenta = 130;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 12564.88 WHERE ID_DetalleVenta = 131;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 220027.50 WHERE ID_DetalleVenta = 134;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 3630.71 WHERE ID_DetalleVenta = 136;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 2480.35 WHERE ID_DetalleVenta = 137;
UPDATE detalle_venta SET Precio_Unitario = 6331.15, Subtotal = 37986.90 WHERE ID_DetalleVenta = 139;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 6282.44 WHERE ID_DetalleVenta = 140;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 10175.98 WHERE ID_DetalleVenta = 142;
UPDATE detalle_venta SET Precio_Unitario = 3373.39, Subtotal = 3373.39 WHERE ID_DetalleVenta = 143;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 144;
UPDATE detalle_venta SET Precio_Unitario = 6331.15, Subtotal = 12662.30 WHERE ID_DetalleVenta = 145;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 6815.40 WHERE ID_DetalleVenta = 148;
UPDATE detalle_venta SET Precio_Unitario = 3373.39, Subtotal = 3373.39 WHERE ID_DetalleVenta = 149;
UPDATE detalle_venta SET Precio_Unitario = 7587.09, Subtotal = 7587.09 WHERE ID_DetalleVenta = 150;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 3047.06 WHERE ID_DetalleVenta = 151;
UPDATE detalle_venta SET Precio_Unitario = 12267.87, Subtotal = 171750.18 WHERE ID_DetalleVenta = 152;
UPDATE detalle_venta SET Precio_Unitario = 7587.09, Subtotal = 7587.09 WHERE ID_DetalleVenta = 153;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 24447.50 WHERE ID_DetalleVenta = 154;
UPDATE detalle_venta SET Precio_Unitario = 5373.08, Subtotal = 5373.08 WHERE ID_DetalleVenta = 155;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 156;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 4960.70 WHERE ID_DetalleVenta = 159;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 3630.71 WHERE ID_DetalleVenta = 161;
UPDATE detalle_venta SET Precio_Unitario = 16830.16, Subtotal = 16830.16 WHERE ID_DetalleVenta = 165;
UPDATE detalle_venta SET Precio_Unitario = 7334.27, Subtotal = 7334.27 WHERE ID_DetalleVenta = 166;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 2480.35 WHERE ID_DetalleVenta = 167;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 9002.76 WHERE ID_DetalleVenta = 169;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 21784.26 WHERE ID_DetalleVenta = 170;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 5087.99 WHERE ID_DetalleVenta = 171;
UPDATE detalle_venta SET Precio_Unitario = 16830.16, Subtotal = 134641.28 WHERE ID_DetalleVenta = 172;
UPDATE detalle_venta SET Precio_Unitario = 3430.95, Subtotal = 3430.95 WHERE ID_DetalleVenta = 173;
UPDATE detalle_venta SET Precio_Unitario = 6331.15, Subtotal = 82304.95 WHERE ID_DetalleVenta = 174;
UPDATE detalle_venta SET Precio_Unitario = 7334.27, Subtotal = 7334.27 WHERE ID_DetalleVenta = 175;
UPDATE detalle_venta SET Precio_Unitario = 6331.15, Subtotal = 6331.15 WHERE ID_DetalleVenta = 177;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 8647.64 WHERE ID_DetalleVenta = 178;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 6282.44 WHERE ID_DetalleVenta = 179;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 6815.40 WHERE ID_DetalleVenta = 181;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 464502.50 WHERE ID_DetalleVenta = 182;
UPDATE detalle_venta SET Precio_Unitario = 3620.10, Subtotal = 3620.10 WHERE ID_DetalleVenta = 183;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 2480.35 WHERE ID_DetalleVenta = 184;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 6282.44 WHERE ID_DetalleVenta = 187;
UPDATE detalle_venta SET Precio_Unitario = 3430.95, Subtotal = 3430.95 WHERE ID_DetalleVenta = 189;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 25439.95 WHERE ID_DetalleVenta = 190;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 126038.64 WHERE ID_DetalleVenta = 191;
UPDATE detalle_venta SET Precio_Unitario = 10832.53, Subtotal = 43330.12 WHERE ID_DetalleVenta = 192;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 20446.20 WHERE ID_DetalleVenta = 193;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 9002.76 WHERE ID_DetalleVenta = 194;
UPDATE detalle_venta SET Precio_Unitario = 12267.87, Subtotal = 12267.87 WHERE ID_DetalleVenta = 196;
UPDATE detalle_venta SET Precio_Unitario = 7587.09, Subtotal = 7587.09 WHERE ID_DetalleVenta = 197;
UPDATE detalle_venta SET Precio_Unitario = 6331.15, Subtotal = 6331.15 WHERE ID_DetalleVenta = 199;
UPDATE detalle_venta SET Precio_Unitario = 16830.16, Subtotal = 16830.16 WHERE ID_DetalleVenta = 201;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 5087.99 WHERE ID_DetalleVenta = 202;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 5087.99 WHERE ID_DetalleVenta = 203;
UPDATE detalle_venta SET Precio_Unitario = 6815.40, Subtotal = 6815.40 WHERE ID_DetalleVenta = 205;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 6282.44 WHERE ID_DetalleVenta = 207;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 2480.35 WHERE ID_DetalleVenta = 208;
UPDATE detalle_venta SET Precio_Unitario = 5373.08, Subtotal = 26865.40 WHERE ID_DetalleVenta = 211;
UPDATE detalle_venta SET Precio_Unitario = 7587.09, Subtotal = 7587.09 WHERE ID_DetalleVenta = 212;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 29045.68 WHERE ID_DetalleVenta = 213;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 9002.76 WHERE ID_DetalleVenta = 215;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 3876.88 WHERE ID_DetalleVenta = 216;
UPDATE detalle_venta SET Precio_Unitario = 3620.10, Subtotal = 3620.10 WHERE ID_DetalleVenta = 219;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 3876.88 WHERE ID_DetalleVenta = 220;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 3876.88 WHERE ID_DetalleVenta = 221;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 17295.28 WHERE ID_DetalleVenta = 222;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 24447.50 WHERE ID_DetalleVenta = 224;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 27138.16 WHERE ID_DetalleVenta = 226;
UPDATE detalle_venta SET Precio_Unitario = 10832.53, Subtotal = 21665.06 WHERE ID_DetalleVenta = 228;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 18847.32 WHERE ID_DetalleVenta = 229;
UPDATE detalle_venta SET Precio_Unitario = 6331.15, Subtotal = 12662.30 WHERE ID_DetalleVenta = 232;
UPDATE detalle_venta SET Precio_Unitario = 10832.53, Subtotal = 10832.53 WHERE ID_DetalleVenta = 234;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 6094.12 WHERE ID_DetalleVenta = 236;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 50399.44 WHERE ID_DetalleVenta = 237;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 9002.76 WHERE ID_DetalleVenta = 239;
UPDATE detalle_venta SET Precio_Unitario = 3620.10, Subtotal = 36201.00 WHERE ID_DetalleVenta = 240;
UPDATE detalle_venta SET Precio_Unitario = 12267.87, Subtotal = 12267.87 WHERE ID_DetalleVenta = 241;
UPDATE detalle_venta SET Precio_Unitario = 3430.95, Subtotal = 6861.90 WHERE ID_DetalleVenta = 242;
UPDATE detalle_venta SET Precio_Unitario = 7334.27, Subtotal = 14668.54 WHERE ID_DetalleVenta = 243;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 9002.76 WHERE ID_DetalleVenta = 244;
UPDATE detalle_venta SET Precio_Unitario = 7334.27, Subtotal = 22002.81 WHERE ID_DetalleVenta = 245;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 3876.88 WHERE ID_DetalleVenta = 247;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 61055.88 WHERE ID_DetalleVenta = 248;
UPDATE detalle_venta SET Precio_Unitario = 16830.16, Subtotal = 50490.48 WHERE ID_DetalleVenta = 249;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 10175.98 WHERE ID_DetalleVenta = 250;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 10175.98 WHERE ID_DetalleVenta = 251;
UPDATE detalle_venta SET Precio_Unitario = 3373.39, Subtotal = 6746.78 WHERE ID_DetalleVenta = 252;
UPDATE detalle_venta SET Precio_Unitario = 7587.09, Subtotal = 37935.45 WHERE ID_DetalleVenta = 253;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 54276.32 WHERE ID_DetalleVenta = 254;
UPDATE detalle_venta SET Precio_Unitario = 3373.39, Subtotal = 37107.29 WHERE ID_DetalleVenta = 257;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 7441.05 WHERE ID_DetalleVenta = 258;
UPDATE detalle_venta SET Precio_Unitario = 12267.87, Subtotal = 134946.57 WHERE ID_DetalleVenta = 261;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 3876.88 WHERE ID_DetalleVenta = 262;
UPDATE detalle_venta SET Precio_Unitario = 7334.27, Subtotal = 22002.81 WHERE ID_DetalleVenta = 265;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 3630.71 WHERE ID_DetalleVenta = 269;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 14522.84 WHERE ID_DetalleVenta = 270;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 2480.35 WHERE ID_DetalleVenta = 271;
UPDATE detalle_venta SET Precio_Unitario = 7587.09, Subtotal = 22761.27 WHERE ID_DetalleVenta = 273;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 3876.88 WHERE ID_DetalleVenta = 274;
UPDATE detalle_venta SET Precio_Unitario = 3430.95, Subtotal = 6861.90 WHERE ID_DetalleVenta = 275;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 8647.64 WHERE ID_DetalleVenta = 276;
UPDATE detalle_venta SET Precio_Unitario = 6331.15, Subtotal = 6331.15 WHERE ID_DetalleVenta = 277;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 5087.99 WHERE ID_DetalleVenta = 279;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 4323.82 WHERE ID_DetalleVenta = 281;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 34724.90 WHERE ID_DetalleVenta = 284;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 73342.50 WHERE ID_DetalleVenta = 285;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 24447.50 WHERE ID_DetalleVenta = 287;
UPDATE detalle_venta SET Precio_Unitario = 2480.35, Subtotal = 12401.75 WHERE ID_DetalleVenta = 289;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 9002.76 WHERE ID_DetalleVenta = 290;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 43238.20 WHERE ID_DetalleVenta = 291;
UPDATE detalle_venta SET Precio_Unitario = 10832.53, Subtotal = 10832.53 WHERE ID_DetalleVenta = 292;
UPDATE detalle_venta SET Precio_Unitario = 24447.50, Subtotal = 122237.50 WHERE ID_DetalleVenta = 293;
UPDATE detalle_venta SET Precio_Unitario = 7587.09, Subtotal = 7587.09 WHERE ID_DetalleVenta = 294;
UPDATE detalle_venta SET Precio_Unitario = 9002.76, Subtotal = 18005.52 WHERE ID_DetalleVenta = 296;
UPDATE detalle_venta SET Precio_Unitario = 16830.16, Subtotal = 16830.16 WHERE ID_DetalleVenta = 298;
UPDATE detalle_venta SET Precio_Unitario = 3430.95, Subtotal = 3430.95 WHERE ID_DetalleVenta = 300;
UPDATE detalle_venta SET Precio_Unitario = 4323.82, Subtotal = 4323.82 WHERE ID_DetalleVenta = 301;
UPDATE detalle_venta SET Precio_Unitario = 6282.44, Subtotal = 12564.88 WHERE ID_DetalleVenta = 302;
UPDATE detalle_venta SET Precio_Unitario = 3876.88, Subtotal = 3876.88 WHERE ID_DetalleVenta = 303;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 21784.26 WHERE ID_DetalleVenta = 305;
UPDATE detalle_venta SET Precio_Unitario = 3373.39, Subtotal = 3373.39 WHERE ID_DetalleVenta = 306;
UPDATE detalle_venta SET Precio_Unitario = 5087.99, Subtotal = 35615.93 WHERE ID_DetalleVenta = 307;
UPDATE detalle_venta SET Precio_Unitario = 3630.71, Subtotal = 3630.71 WHERE ID_DetalleVenta = 308;
UPDATE detalle_venta SET Precio_Unitario = 1523.53, Subtotal = 1523.53 WHERE ID_DetalleVenta = 309;


-- 6. Total_Venta recalculado como suma de sus detalles de venta
UPDATE venta v
JOIN (
    SELECT ID_Venta, SUM(Subtotal) AS total_detalle
    FROM detalle_venta
    GROUP BY ID_Venta
) d ON d.ID_Venta = v.ID_Venta
SET v.Total_Venta = d.total_detalle;


-- 7. Eliminacion de venta huérfana sin detalle (ID_Venta 201)
DELETE FROM venta WHERE ID_Venta = 201;

SET FOREIGN_KEY_CHECKS = 1;
-- Fin de correcciones