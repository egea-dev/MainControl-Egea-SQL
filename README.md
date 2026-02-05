# Egea Control - PostgreSQL Migration

Backend de base de datos para **Egea MainControl**, migrado desde Supabase a PostgreSQL auto-alojado.

## 📂 Estructura

```
├── docker/
│   ├── Dockerfile          # Imagen PostgreSQL personalizada
│   └── docker-compose.yml  # Orquestación para Coolify
├── migrations/
│   ├── 001_schema.sql      # Esquema consolidado (MAIN + PRODUCTIVITY)
│   └── 002_seed.sql        # Datos iniciales (opcional)
├── scripts/
│   ├── backup.sh           # Script de backup automático
│   └── restore.sh          # Script de restauración
└── README.md
```

## 🚀 Despliegue Rápido (Coolify)

1. Conecta este repositorio en Coolify.
2. Selecciona el archivo `docker/docker-compose.yml`.
3. Configura las variables de entorno:
   - `POSTGRES_USER`: Usuario admin (ej: `egea_admin`)
   - `POSTGRES_PASSWORD`: Contraseña segura
   - `POSTGRES_DB`: `egea_control`

## 🔧 Instalación Manual (VPS)

```bash
# Instalar PostgreSQL
sudo apt update && sudo apt install postgresql postgresql-contrib -y

# Crear base de datos
sudo -u postgres psql -c "CREATE DATABASE egea_control;"
sudo -u postgres psql -c "CREATE USER egea_admin WITH PASSWORD 'TU_CONTRASEÑA';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE egea_control TO egea_admin;"

# Ejecutar migraciones
sudo -u postgres psql egea_control < migrations/001_schema.sql
```

## 📊 Esquemas

La base de datos está organizada en esquemas lógicos:

| Esquema        | Contenido                                      |
|----------------|------------------------------------------------|
| `main`         | Usuarios, pantallas, tareas, vehículos         |
| `productivity` | Pedidos comerciales, producción, inventario    |

## 🔒 Seguridad

- Las contraseñas nunca se guardan en el repositorio.
- Usa variables de entorno o secretos de Coolify.
- No expongas el puerto 5432 públicamente sin firewall.

## 📝 Licencia

Uso interno - Egea Dev © 2026
