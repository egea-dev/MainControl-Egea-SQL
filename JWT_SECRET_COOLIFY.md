# Variables de Entorno para Coolify

## JWT_SECRET (CRÍTICO - ACTUALIZAR EN COOLIFY)

Añade esta variable en Coolify → Environment Variables:

```
JWT_SECRET=RlYlfG+to+ANgMc8iu6eAS/Oj7weTf9c7Zo4BNrv80w=
```

## DATABASE_URL (Ya configurada)

```
DATABASE_URL=postgresql://postgres:[PASSWORD]@[HOST]:5432/[DATABASE]
```

---

## ⚠️ IMPORTANTE

El `JWT_SECRET` **DEBE** ser el mismo valor en:
- Coolify Environment Variables
- PostgREST (`PGRST_JWT_SECRET`)
- GoTrue (`GOTRUE_JWT_SECRET`)
- Frontend build args (`VITE_SUPABASE_ANON_KEY`)

**Este secreto es el que generamos con OpenSSL y es válido para autenticación.**
