# 📰 Applicant Showcase App - Journalist Edition

> **Solución al Desafío Técnico de Symmetry**
>
> *Implementada por [Rubén Ortiz]*

Bienvenido a la versión extendida de la **Applicant Showcase App**. Este proyecto ha evolucionado de un simple lector de noticias a una **Plataforma de Periodismo**, permitiendo a los usuarios no solo consumir contenido de APIs globales, sino también actuar como periodistas creando, gestionando y publicando sus propias noticias en la nube.

---

## 🚀 Quick Start (Cómo ejecutar la App)

Sigue estos pasos para poner en marcha el proyecto en tu entorno local:
### 1. Prerrequisitos
* **Flutter SDK:** `>=3.0.0`
* **Dart SDK:** `>=3.0.0`
* **Dispositivo/Emulador:** Android (Recomendado) o iOS.

### 2. Instalación
Clona el repositorio y navega a la carpeta del frontend:

```bash
cd frontend
flutter pub get
````

Este proyecto utiliza `Retrofit`, `Floor` (SQLite) y `Freezed`/`JsonSerializable`. Es **obligatorio** ejecutar el generador de código para que la app compile:

Bash
```
dart run build_runner build --delete-conflicting-outputs
```

### 4. Configuración de Firebase

El proyecto está conectado a un proyecto de Firebase (Producción).

- Asegúrate de que el archivo `google-services.json` se encuentra en `frontend/android/app/`.

- _Nota para revisores:_ Las reglas de seguridad de Firestore y Storage ya están desplegadas y permiten la lectura/escritura para la funcionalidad de la demo.


### 5. Ejecutar

Bash
```
flutter run
```

---

## Funcionalidades

Esta solución va más allá de los requisitos básicos, implementando un ciclo de vida completo de gestión de contenidos:

- Fusiona noticias de **NewsAPI** (Externas) con noticias de **Firebase** (Propias) en una lista unica. Si una fuente falla, la app sigue funcionando.

- **✍️ Rol de Periodista:**
    - Creación de artículos con soporte **Markdown**.
    - **Vista Previa (Preview Mode)** antes de publicar.
    - Subida de imágenes de portada a **Firebase Storage**.

- **🗑️ Gestión de Contenido:**
    - Eliminación de noticias propias mediante gesto **Swipe-to-Delete**.
    - Lógica de seguridad: _No se permite borrar noticias de la API externa._

- **💾 Persistencia Local (Offline-First):**
    - Sistema de "Favoritos" usando **SQLite (Floor)**.
    - Sincronización automática: Al borrar una noticia de la nube, se limpia de la base de datos local.

- **🎨 UX Reactiva:** Feedback visual inmediato, Botones de estado reactivos y manejo de errores robusto.


---

## 🏗️ Arquitectura y Tecnologías

El proyecto sigue estrictamente los principios de **Clean Architecture** separados en capas:

- **Presentation:** `Flutter BLoC` (Gestión de estado reactivo).
- **Domain:** Entidades puras y Casos de Uso mínimos (`DeleteArticle`, `CreateArticle`, etc.).
- **Data:** Repositorio (`ArticleRepositoryImpl`) que orquesta múltiples fuentes de datos.

### Tech Stack

- **Backend:** Firebase (Firestore + Storage).
- **Local DB:** Floor (SQLite wrapper).
- **Network:** Dio + Retrofit.
- **Utils:** Flutter Hooks, GetIt (DI), Equatable.

---

## 📚 Documentación Detallada

Para una comprensión profunda de las decisiones técnicas, los desafíos enfrentados y la justificación de la arquitectura, por favor consulta el reporte técnico completo:

👉 **[LEER REPORTE TÉCNICO (docs/REPORT.md)](/docs/REPORT.md)**
👉 **[LEER PROCESO CREATIVO (docs/STEP_BY_STEP.md)](/docs/STEP_BY_STEP.md)**

---

## 📂 Estructura del Proyecto

```
lib/
├── config/              # Rutas y Temas
├── core/                # Constantes, Recursos y Clases Base
├── features/
│   └── daily_news/      # Principal
│       ├── data/        # Modelos, Data Sources (API/Firebase/Local) y Repositorios
│       ├── domain/      # Interfaces de Repositorio y UseCases
│       └── presentation/# BLoCs, Páginas (Screens) y Widgets
└── injection_container.dart # Inyección de Dependencias
```

---

> _"Truth is King. Maximally Overdeliver."_
