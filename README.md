# Asistente Elden Ring

Una aplicación móvil desarrollada en Flutter que sirve como asistente completo para el juego Elden Ring, proporcionando información detallada sobre jefes, armas, zonas y misiones.

## 🎮 Características

- **Base de Datos de Jefes**: Información detallada sobre todos los jefes del juego
- **Catálogo de Armas**: Estadísticas y detalles de armas disponibles
- **Mapa de Zonas**: Información sobre las diferentes áreas del juego
- **Sistema de Misiones**: Seguimiento de misiones y objetivos
- **Progreso del Jugador**: Sistema para registrar avances personales
- **Autenticación**: Sistema de login seguro para usuarios

## 🚀 Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma
- **Dart**: Lenguaje de programación
- **Firebase**: Backend y autenticación
- **Firestore**: Base de datos en la nube

## 📱 Plataformas Soportadas

- Android
- iOS
- Web (en desarrollo)
- Desktop (en desarrollo)

## 🛠️ Requisitos del Sistema

- Flutter SDK 3.0 o superior
- Dart SDK 3.0 o superior
- Android Studio / VS Code
- Dispositivo Android/iOS o emulador

## 📦 Instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/asistente_elden.git
   cd asistente_elden
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Configura Firebase** (opcional)
   - Crea un proyecto en Firebase Console
   - Descarga los archivos de configuración
   - Colócalos en las carpetas correspondientes

4. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 🔧 Configuración

### Variables de Entorno
Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:
```
FIREBASE_API_KEY=tu_api_key
FIREBASE_PROJECT_ID=tu_project_id
```

### Firebase
Para usar la funcionalidad completa de la aplicación, necesitarás configurar Firebase:
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto
3. Habilita Authentication y Firestore
4. Descarga los archivos de configuración

## 📁 Estructura del Proyecto

```
lib/
├── assets/          # Recursos estáticos (imágenes, datos)
├── models/          # Modelos de datos
├── screens/         # Pantallas de la aplicación
├── services/        # Servicios (Firebase, autenticación)
├── utils/           # Utilidades y temas
└── widgets/         # Widgets reutilizables
```

## 🤝 Contribuir

1. Haz un Fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- **FromSoftware** por crear Elden Ring
- **Flutter Team** por el framework de desarrollo
- **Firebase** por los servicios de backend

## 📞 Contacto

- **Desarrollador**: [Tu Nombre]
- **Email**: [tu-email@ejemplo.com]
- **GitHub**: [@tu-usuario]

---

⭐ Si te gusta este proyecto, ¡dale una estrella en GitHub!
