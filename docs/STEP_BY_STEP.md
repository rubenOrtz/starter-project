# Diario de Desarrollo: Proceso Creativo y Arquitectura

# **Preámbulo**

En este documento detallo mi proceso creativo, mi forma de pensar y la justificación detrás de cada decisión técnica tomada durante el desarrollo del proyecto.

# **Generalidades: La Metáfora de la Construcción**

Una vez leído varias veces y asimilado el proyecto a la perfección, el camino a seguir es claro. Voy a construir una gran casa y, como en toda construcción sólida, no debemos empezar por el tejado, sino por los cimientos. Observando la "casa" desde lejos, identifico tres pilares fundamentales:

- **Los Datos (Backend):** Son los cimientos, las paredes, la electricidad y el agua. La infraestructura vital.

- **El Diseño (Frontend):** La decoración y la fachada. Lo que hace que quieras vivir en esta casa y no en otra.

- **La Comunicación:** El director de orquesta que coordina a los proveedores de suministros y hace que todo funcione armónicamente.


Definido esto, es necesario comenzar por lo básico: levantar las paredes que nos protegerán del frío. Ese primer paso es la **Capa de Datos (Backend)**. Aquí surge nuestro primer dilema.

### **¿Qué tecnología deberíamos usar?**

El proyecto base propone el uso de una tecnología BaaS (_Backend as a Service_) llamada Firebase, que provee una API REST. La alternativa es desarrollar mi propia API. He realizado la siguiente comparativa:

| **Característica** | **API PROPIA**                                                                                                    | **BaaS**                                                                                           |
| ------------------ | ----------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| **Tecnologías**    | Node.js, Python, Rust, C++, Zig, Carbon (Libertad total)                                                          | Firebase (Ecosistema Google)                                                                       |
| **Ventajas**       | Escalabilidad extrema, control total, maniobrabilidad, todo se debe testear.                                      | Curva de aprendizaje baja, Serverless, almacenamiento de imágenes incluido, documentación extensa. |
| **Desventajas**    | Alto coste de tiempo/desarrollo, configuración manual de endpoints, gestión de imágenes y serialización compleja. | Escalabilidad limitada a largo plazo, menor libertad arquitectónica.                               |

Basándome en la naturaleza de este proyecto (pocos usuarios, plazos ajustados), la decisión sensata es usar FIREBASE.

Nota: Si este fuera un proyecto para producción a gran escala con requisitos de alto rendimiento, optaría por una API propia utilizando lenguajes como Zig o Elixir en servidores dedicados.

> ***¿Sabías que?** Elixir es usado por **Discord** para su REST API, siendo capaz de gestionar (con mucha optimización) más de 259 millones de usuarios activos mensuales y más de 4.000 millones de mensajes al día. **¿Cuantas lecturas y escrituras de disco serán por sgeundo?*** 

---

## **Estructura de Datos**

Definida la tecnología, el siguiente reto es esquematizar la base de datos. He diseñado la siguiente estructura para la colección principal.

### Colección: `articles`

Esta colección almacena el contenido principal de la aplicación.

| **Nombre**     | **Tipo de Dato** | **Obligatorio?** | **Descripción**                                  |
| -------------- | ---------------- | ---------------- | ------------------------------------------------ |
| `id`           | `String`         | **Required**     | Identificador único del artículo.                |
| `title`        | `String`         | **Required**     | Título de la noticia.                            |
| `content`      | `String`         | **Required**     | Contenido del artículo en formato **Markdown**.  |
| `category`     | `String`         | **Required**     | Categoría para filtrado y organización.          |
| `authorName`   | `String`         | **Required**     | Nombre del periodista/autor.                     |
| `publishedAt`  | `Timestamp`      | **Required**     | Fecha y hora de publicación.                     |
| `thumbnailURL` | `String`         | **Required**     | Referencia URL de la imagen en `media/articles`. |
| `views`        | `Integer`        | _Optional_       | Contador de vistas (Default: 0).                 |
| `likes`        | `Integer`        | _Optional_       | Contador de "Me gusta" (Default: 0).             |

_Nota: `views` y `likes` son opcionales en la creación, ya que se actualizan posteriormente mediante llamadas específicas a la API._

### Ejemplo de JSON

JSON

```
{
  "id": "87f89d7s89f7s8",
  "title": "La caída del Imperio Romano",
  "content": "Hace **muchísimo** tiempo... (contenido markdown)",
  "category": "Historia",
  "authorName": "Marco Aurelio",
  "publishedAt": "2025-12-27T10:00:00Z",
  "thumbnailURL": "gs://bucket-name/media/articles/ROMA.jpg",
  "views": 30,
  "likes": 31
}
```

### **Reglas de Seguridad (`backend/firestore.rules`)**

Para garantizar la integridad de los datos, he implementado reglas de validación en el servidor. Esto asegura que solo se acepten datos con el formato y longitud correctos.

JavaScript

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isValidArticle() {
      let incoming = request.resource.data;
      return incoming.keys().hasAll(['title', 'content', 'category', 'authorName', 'publishedAt', 'thumbnailURL'])
             && incoming.title is string
             && incoming.content is string
             && incoming.category is string
             && incoming.authorName is string
             && incoming.thumbnailURL is string
             // Validación de longitud mínima
             && incoming.title.size() > 0
             && incoming.content.size() > 0;
    }

    match /articles/{articleId} {
      // Todos pueden leer noticias
      allow read: if true;
      
      // Crear solo si cumple los criterios de validación
      allow create: if isValidArticle();
      
      // Editar solo si cumple los criterios
      allow update: if isValidArticle();
      
      // Borrado deshabilitado inicialmente por seguridad
      allow delete: if false;
    }
  }
}
```

---

## **Estrategia KISS**

Al iniciar el proyecto base, actualicé todas las dependencias (Flutter, Kotlin, Java) a sus últimas versiones estables.

Al analizar la app base, observé funcionalidades de "Favoritos" y "Likes". Aquí apliqué el principio **KISS (Keep It Simple, Stupid)** para decidir dónde guardar estos datos:

- **Nube:** Datos globales como el total de _Likes_ y _Views_.

- **Local:** Datos privados del usuario (sus favoritos, sus likes personales), evitando la complejidad de un sistema de autenticación de usuarios completo por ahora.


---

## **Ampliación del Alcance: El "Porqué"**

Partiendo de una aplicación orientada al consumo de contenido (_Reader_), he elevado el alcance para integrar el rol de **Periodista**. Las funcionalidades base (`getNewsArticles`, `getSavedArticles`, `saveArticle`, `removeArticle`) cubrían las bases de lectura. **Para el nuevo rol, he definido dos nuevas operaciones importantes en la capa de Dominio**:

- `uploadImage`

- `createArticle`


Durante el diseño, surgió una distinción técnica necesaria entre `saveArticle` y `createArticle`. Aunque ambos "guardan" información, sus propósitos difieren:

- **`saveArticle`**: "Marcar como Favorito". Su objetivo es una base de datos local (**SQLite**) para acceso _offline_.

- **`createArticle`**: "Publicar". Su objetivo es la persistencia remota accesible globalmente (**Firebase Firestore**).


Fusionar ambos conceptos en un método genérico violaría el **Principio de Responsabilidad Única (SRP). Mantenerlos separados quita la lógica de caché de la lógica de backend, resultando en un código más limpio, escalable y testeable.

---

## **Implementación: De la Teoría a la Práctica**

Con la separación de responsabilidades definida, trasladé el desafío a la **Capa de Datos**, manteniendo la pureza de la arquitectura.

1. **Minimicé las Dependencias:** Evité librerías externas para generar IDs (como `uuid`), delegando esta tarea a la infraestructura de Firestore y al uso de `DateTime`.

2. El `ArticleRepositoryImpl` evolucionó a un orquestador inteligente. Ya no es un simple intermediario; coordina tres fuentes de datos (`NewsApi`, `AppDatabase` local y `FirebaseService`), encapsulando la complejidad. El resto de la app recibe un `DataState` independiente a la fuente.

3. **Gestión de Estado (BLoC):** No utilicé el `RemoteArticlesBloc` para la creación de noticias. Siguiendo _Clean Architecture_, hice un **`AddArticleBloc`** dedicado. Este maneja estados específicos como `AddArticleImageUploaded` (previsualización) o `AddArticleLoading` (bloqueo de UI), manteniendo el código de lectura limpio.


### **"Maximally Overdeliver"**

Analizando el diseño en Figma, identifiqué carencias en la experiencia de usuario:

- Implementé `BlocListener` para mostrar mensajes de éxito/error y navegación automática tras publicar.

- La UI valida la integridad de los datos antes de enviarlos, ahorrando peticiones al servidor.

- Integración de `image_picker` para la selección de portadas.


---

## **Infraestructura y Despliegue**

### **El Desafío de la Red**

Durante las pruebas con el Emulador de Firebase, las subidas de imágenes quedaban en un estado de carga infinita. Diagnostiqué dos problemas:

1. **Bloqueo Cleartext:** Android bloquea por defecto conexiones HTTP no seguras.

2. **Firewall:** Windows interceptaba las conexiones al puerto de Storage (9199).


### **Solución: "Truth is King"**

Aunque apliqué parches temporales en el Manifiesto de Android, tomé la decisión estratégica de validar contra el entorno de **producción real**. Migrar a la infraestructura real de Firebase eliminó la complejidad de la red local y garantizó permisos reales.

### **Gestión de Identidad y Billing (Error 404)**

Al desplegar, encontré un error `404 Object Not Found`. Se debía a un cambio reciente en las políticas de Google Cloud (finales de 2024) que exige el plan "Blaze" para nuevos buckets.

- Elevé el proyecto al plan Blaze (aprovechando la capa gratuita) y aprovisioné el bucket en la región `us-central1`.

Ahora todo funciona perfectamente.


---

## **Contenido Funcional: El Feed Híbrido**

El siguiente reto fue combinar fuentes de datos diferentes (REST API vs. Firestore) en el feed principal. El enfoque de usar `Future.wait` presentaba un riesgo: si la NewsAPI fallaba, bloqueaba la visualización de los artículos propios de Firebase.

¿Mi solución?

Rediseñé la lógica del repositorio para aislar los fallos:

Dart
```
Future<DataState<List<ArticleModel>>> getNewsArticles() async {  
  List<ArticleModel> apiArticles = [];  
  List<ArticleModel> firebaseArticles = [];  
  DioException? lastError;  
  
  // Ejecución paralela con manejo de errores aislado
  await Future.wait([  
    _newsApiService.getNewsArticles(...).then((httpResponse) {  
      if (httpResponse.response.statusCode == HttpStatus.ok) {  
        apiArticles = httpResponse.data;  
      }  
    }).catchError((e) { 
        // Captura silenciosa del error de API
        if (e is DioException) lastError = e; 
    }),  
  
    _firebaseService.getArticles().then((articles) {  
      firebaseArticles = articles;  
    }).catchError((e) { 
        // Captura silenciosa del error de Firebase
        if (e is DioException) lastError = e; 
    }),  
  ]);  
  
  // Solo fallamos si AMBAS fuentes fallan
  if (apiArticles.isEmpty && firebaseArticles.isEmpty) {  
    return DataFailed(...);  
  }  
  
  final allArticles = [...firebaseArticles, ...apiArticles];  
  
  return DataSuccess(allArticles);  
}
```

**Resultado:** El sistema es resiliente. Si una fuente cae, la otra sigue funcionando.

---

## **Persistencia Local (Favoritos)**

Al integrar favoritos, me enfrenté a un problema de integridad de datos: **El Conflicto de IDs**.

1. **Tipos Incompatibles:** La base de datos local (SQLite) esperaba IDs numéricos (`int`), pero Firebase usa UUIDs (`String`).

2. La API externa (`newsapi`) a menudo devuelve artículos con `id: null`.


**¿Como lo solucioné?**

- Estandaricé el campo `id` como `String` en todas las capas.

- Si un artículo no tiene ID, utilizo su `url` como identificador único.

- Actualicé el DAO a `OnConflictStrategy.replace` para manejar duplicados silenciosamente.

Implementé un botón de guardado **reactivo**. Al abrir una noticia, el icono cambia (`bookmark` vs `bookmark_outline`) consultando la base de datos local, indicando claramente si ya está guardada.

---

## **La Censura: Borrado de Noticias**

Para completar el ciclo, implementé la capacidad de borrar noticias propias.

1. Implementé un gesto "Deslizar para Borrar" (`Dismissible`).

2. Tuve un error, "A dismissed Dismissible widget is still part of the tree"_. La UI era más rápida que el servidor.
	**Solución:** El BLoC emite inmediatamente un nuevo estado con la lista filtrada (borrado visual instantáneo) antes de esperar la confirmación del servidor.

3. El repositorio ejecuta una transacción: primero elimina el recurso en Firestore y luego purga cualquier copia en la caché local (SQLite).


### **Refresco Automático**

Al volver de crear una noticia, el feed no se actualizaba. Implementé una idea basada en la navegación (`await Navigator.push...`) para disparar un evento `GetArticles` al retornar, asegurando que el feed siempre esté actualizado.

---

## **"Conclusión" y Futuro**

A fecha de 11/12/2025 (20:41), la funcionalidad básica y los requisitos extra están completos.

Y una pequeña reflexión final:

El modelo actual de actualización bajo demanda (polling) no es el más eficiente. La solución óptima a futuro sería implementar una arquitectura orientada a eventos mediante WebSockets o Streams, permitiendo que el servidor haga un push de datos al cliente en tiempo real, garantizando una sincronización inmediata similar a Discord o Slack.

Y con esto y un bizcocho, los cimientos, paredes y decoración de nuestra "casa" están terminados.

Un proyecto muy interesante para empezar a programar y que demuestra quienes saben de verdad hacer las cosas bien. Totalmente recomendado.


