# Egea Productivity App

Sistema de gestión integral para instalaciones, producción comercial y logística.

---

## 🚀 Inicio Rápido

```bash
# Instalar dependencias
npm install

# Iniciar servidor de desarrollo
npm run dev

# Abrir en navegador
https://localhost:8083
```

---

Este proyecto utiliza una **arquitectura modular basada en dominios (Feature-driven)** y una **arquitectura dual de bases de datos**:

- **📁 Features (`src/features`)**: Organización por módulos de negocio (Comercial, Producción, Logística). Cada módulo encapsula sus propios servicios, componentes y utilidades.
- **⚙️ Capa de Servicios**: Toda la lógica de negocio pesada, validaciones y sincronizaciones entre DBs reside en servicios puros (`orderService.ts`, `workOrderService.ts`), desacoplando la UI de las reglas de negocio.
- **🔵 DB MAIN**: Core (autenticación, usuarios, permisos, instalaciones).
- **🟢 DB PRODUCTIVITY**: Módulos de negocio (comercial, producción, logística).

Ambas bases de datos comparten la misma sesión de autenticación mediante un interceptor de fetch o sesiones paralelas persistentes.

### Documentación Completa

- 📖 [ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md) - Arquitectura del sistema

---

## 🗂️ Estructura del Proyecto

```
egea-Main-control/
├── src/
│   ├── features/            # 🚀 Módulos de Negocio (Clean Architecture)
│   │   ├── commercial/      # Servicios y componentes de pedidos
│   │   ├── production/      # Servicios y gestión de taller
│   │   └── shipping/        # Logística y expediciones
│   ├── components/          # Componentes compartidos y UI base
│   │   ├── layout/          # Estructura visual global
│   │   └── ui/              # Primitivos (shadcn/ui)
│   ├── hooks/               # Orquestadores de consultas (TanStack Query)
│   ├── integrations/
│   │   └── supabase/        # Clientes y tipos generados
│   ├── pages/               # Vistas principales (Varios módulos)
│   └── lib/                 # Utilidades globales unificadas
├── supabase/
│   └── rls_hardening/       # Scripts de seguridad recomendada
└── ...
```

---

## 💻 Uso de Clientes Supabase

### Regla Simple

```typescript
// Para tablas de MAIN (usuarios, instalaciones, permisos)
import { supabaseMain } from '@/integrations/supabase/client';

// Para tablas de PRODUCTIVITY (comercial, producción, logística)
import { supabaseProductivity } from '@/integrations/supabase/client';
```

### Tabla de Mapeo Rápido

| Tabla | Cliente | Módulo |
|-------|---------|--------|
| `profiles`, `vehicles`, `screen_data` | `supabaseMain` | Core |
| `comercial_orders`, `produccion_work_orders` | `supabaseProductivity` | Negocio |

**Ver tabla completa**: [SUPABASE_CLIENTS_GUIDE.md](./SUPABASE_CLIENTS_GUIDE.md)

---

## 🔐 Autenticación

La autenticación es manejada por `supabaseMain` y compartida automáticamente con `supabaseProductivity` mediante un interceptor de fetch.

```typescript
// Login (solo usar supabaseMain)
const { data, error } = await supabaseMain.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password'
});

// Logout
await supabaseMain.auth.signOut();
```

---

## 📦 Módulos Principales

### 1. **Dashboard Admin**
- Vista general de instalaciones y pedidos
- Calendario con drag & drop
- Estadísticas en tiempo real

### 2. **Instalaciones**
- Gestión de tareas de instalación
- Asignación de operarios y vehículos
- Calendario semanal

### 3. **Comercial**
- Gestión de pedidos
- Seguimiento de estados
- Documentación (presupuestos, pedidos)

### 4. **Producción**
- Órdenes de trabajo
- Control de calidad
- Etiquetado QR

### 5. **Logística**
- Gestión de envíos
- Almacén
- Tracking

---

## ⚙️ Variables de Entorno

Crear archivo `.env` en la raíz:

```env
# MAIN Database
VITE_SUPABASE_URL=https://your-main-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-main-anon-key

# PRODUCTIVITY Database
VITE_SUPABASE_PRODUCTIVITY_URL=https://your-productivity-project.supabase.co
VITE_SUPABASE_PRODUCTIVITY_ANON_KEY=your-productivity-anon-key
```

---

## 🛠️ Scripts Disponibles

```bash
# Desarrollo
npm run dev              # Iniciar servidor de desarrollo

# Build
npm run build            # Compilar para producción
npm run preview          # Preview de build

# Linting
npm run lint             # Ejecutar ESLint
```

---

## ⚠️ Notas Importantes

### Warning "Multiple GoTrueClient instances"

Este warning es **esperado y benigno**. Aparece porque usamos dos bases de datos Supabase, pero es seguro porque:
- Solo MAIN maneja autenticación
- PRODUCTIVITY usa interceptor de fetch
- No hay conflicto de datos

**Más info**: Ver comentarios en `src/integrations/supabase/client.ts`

### RLS (Row Level Security)

Ambas bases de datos implementan RLS. Asegúrate de estar autenticado para acceder a los datos.

---

## 📚 Documentación Adicional

- [ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md) - Arquitectura completa del sistema

---

## 🤝 Contribuir

### Añadir Nueva Tabla

1. **Decidir base de datos**: ¿MAIN (core) o PRODUCTIVITY (negocio)?
2. **Crear migración**: En el proyecto Supabase correspondiente
3. **Regenerar tipos**: `supabase gen types typescript`
4. **Usar cliente correcto**: `supabaseMain` o `supabaseProductivity`
5. **Actualizar documentación**: Añadir a tabla de mapeo

**Ver guía completa**: [SUPABASE_CLIENTS_GUIDE.md#añadir-nueva-tabla](./SUPABASE_CLIENTS_GUIDE.md#-añadir-nueva-tabla)

---

## 🐛 Solución de Problemas

### Error: "relation does not exist"

**Causa**: Usar el cliente incorrecto para una tabla.

**Solución**: Verificar la tabla de mapeo rápido en la sección de Arquitectura.

### Error: "table does not exist"

**Causa**: Mismo problema, cliente incorrecto.

**Solución**: Consultar tabla de mapeo.

---

## 📞 Soporte

- **Documentación**: Ver archivos `.md` en la raíz del proyecto
- **Issues**: [GitHub Issues](https://github.com/NeuralStories/egea-Main-control/issues)

---

## 📄 Licencia

Propietario: Egea Productivity  
Todos los derechos reservados.

---

**Última actualización**: 9 de enero de 2026  
**Versión**: 2.0
