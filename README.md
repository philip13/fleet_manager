# Fleet Manager

Fleet Manager es una aplicación web construida con Ruby on Rails que permite gestionar una flota de vehículos y sus servicios de mantenimiento. Proporciona una API RESTful para operaciones CRUD en vehículos y servicios de mantenimiento, así como reportes resumidos en formato JSON y CSV.

## Características

- **Gestión de Vehículos**: Crear, leer, actualizar y eliminar vehículos con información como VIN, placa, año y estado.
- **Servicios de Mantenimiento**: Gestionar servicios de mantenimiento asociados a vehículos, incluyendo estado, prioridad, costo y fechas.
- **Autenticación JWT**: Sistema de autenticación basado en tokens JWT para usuarios con roles (admin/user).
- **Reportes**: Generar resúmenes de mantenimiento con totales, desgloses por estado y vehículo, y top 3 vehículos por costo.
- **Exportación CSV**: Exportar reportes de mantenimiento en formato CSV.
- **API RESTful**: Endpoints para integración con otras aplicaciones.

## Requisitos del Sistema

- Ruby 3.3.6
- Rails 7.2.3
- PostgreSQL
- Bundler

## Instalación y Configuración

### Opción 1: Instalación Local

1. **Clona el repositorio**:
   ```bash
   git clone git@github.com:philip13/fleet_manager.git
   cd fleet_manager
   ```

2. **Instala las dependencias**:
   ```bash
   bundle install
   ```

3. **Configura la base de datos**:
   - Asegúrate de tener PostgreSQL instalado y ejecutándose.
   - Crea la base de datos:
     ```bash
     createdb fleet_manager_development
     ```
   - Ejecuta las migraciones:
     ```bash
     rails db:migrate
     ```
   - (Opcional) Carga datos de prueba:
     ```bash
     rails db:seed
     ```

4. **Ejecuta la aplicación**:
   ```bash
   rails server
   ```
   La aplicación estará disponible en `http://localhost:3000`.

### Opción 2: Usando Docker

El proyecto incluye un Dockerfile para despliegue en producción. Para desarrollo local con Docker:

1. Construye la imagen:
   ```bash
   docker build -t fleet-manager .
   ```

2. Ejecuta el contenedor:
   ```bash
   docker run -p 3000:3000 fleet-manager
   ```

Nota: El Dockerfile está optimizado para producción. Para desarrollo, considera usar docker-compose si está disponible.

## Uso

### Interfaz Web

- Accede a `http://localhost:3000` para la interfaz web.
- Navega a la lista de vehículos y gestiona servicios de mantenimiento.

### API

La API está disponible bajo `/api/v1/`. Todos los endpoints requieren autenticación JWT.

#### Autenticación

Para obtener un token JWT, inicia sesión:

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'
```

Respuesta:
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

Incluye el token en el header `Authorization: Bearer <token>` para requests autenticados.

#### Endpoints Principales

##### Vehículos

- **GET /api/v1/vehicles**: Lista todos los vehículos.
- **POST /api/v1/vehicles**: Crea un nuevo vehículo.
- **GET /api/v1/vehicles/:id**: Muestra un vehículo específico.
- **PUT /api/v1/vehicles/:id**: Actualiza un vehículo.
- **DELETE /api/v1/vehicles/:id**: Elimina un vehículo.

Ejemplo de creación de vehículo:
```bash
curl -X POST http://localhost:3000/api/v1/vehicles \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle": {
      "vin": "1HGCM82633A123456",
      "plate": "ABC-123",
      "year": 2020,
      "status": "active"
    }
  }'
```

##### Servicios de Mantenimiento

- **GET /api/v1/vehicles/:vehicle_id/maintenance_services**: Lista servicios de un vehículo.
- **POST /api/v1/vehicles/:vehicle_id/maintenance_services**: Crea un servicio para un vehículo.
- **PUT /api/v1/maintenance_services/:id**: Actualiza un servicio.

Ejemplo de creación de servicio:
```bash
curl -X POST http://localhost:3000/api/v1/vehicles/1/maintenance_services \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "maintenance_service": {
      "description": "Cambio de aceite",
      "status": "pending",
      "date": "2024-03-16",
      "cost_cents": 50000,
      "priority": "medium"
    }
  }'
```

##### Reportes

- **GET /api/v1/reports/maintenance_summary**: Obtiene resumen de mantenimiento en JSON.
- **GET /api/v1/reports/maintenance_summary.csv**: Exporta resumen en CSV.

Parámetros opcionales para filtros de fecha:
- `from`: Fecha de inicio (YYYY-MM-DD)
- `to`: Fecha de fin (YYYY-MM-DD)

Ejemplo de reporte JSON:
```bash
curl -H "Authorization: Bearer <token>" \
  http://localhost:3000/api/v1/reports/maintenance_summary?from=2024-01-01&to=2024-12-31
```

Respuesta de ejemplo:
```json
{
  "data": {
    "total_orders": 6,
    "total_cost_cents": 65000,
    "by_status": [
      {
        "status": "completed",
        "total_orders": 3,
        "total_cost_cents": 30000
      }
    ],
    "by_vehicle": [...],
    "top_3_vehicles": [...]
  }
}
```

## Ejecutar Pruebas

El proyecto utiliza RSpec para pruebas. Ejecuta las pruebas con:

```bash
bundle exec rspec
```

Para ejecutar un spec específico:
```bash
bundle exec rspec spec/requests/api/v1/reports_maintenance_summary_spec.rb
```

## Estructura del Proyecto

- `app/models/`: Modelos de datos (Vehicle, MaintenanceService, User)
- `app/controllers/`: Controladores API y web
- `app/serializers/`: Serializers para respuestas JSON
- `config/routes.rb`: Definición de rutas
- `db/migrate/`: Migraciones de base de datos
- `spec/`: Pruebas RSpec

## Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia


