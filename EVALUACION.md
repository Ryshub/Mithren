# Evaluación de Mithren (vs WindUI)

> Documento técnico de revisión. Objetivo: decidir si Mithren vale la pena
> continuar, qué hace bien de verdad, qué problemas de arquitectura/UX tiene
> y qué arreglar antes de seguir agregando features.
>
> Referencia de comparación: **WindUI** (`WindUI/src/`).
> Versión revisada de Mithren: `v2.0.5` (`Mithren/main.lua`, ~6.8k líneas).

---

## 1. Resumen breve

Mithren es una librería UI propia para Roblox/Luau orientada a executors,
empaquetada en un solo archivo (`Mithren/main.lua`). Está claramente avanzada:
tiene theming por instancia, sistema de saves, notificaciones, iconos con
fallback, soporte responsive y localización remota.

La conclusión corta es **continuar, pero con una pausa de consolidación**. La
base es real y no es un prototipo desechable, pero hay una decisión de diseño
en la localización que arrastra el peor problema de UX (cambiar idioma exige
reiniciar) y el color picker está roto en mobile. Ambos son arreglables sin
reescribir la librería, y conviene resolverlos antes de seguir sumando
componentes.

Comparada con WindUI, Mithren pierde sobre todo en **organización del código**
(monolito vs módulos) y en **localización viva** (WindUI re-traduce en caliente;
Mithren no). No pierde en lo visual ni en la ergonomía de la API.

---

## 2. Qué hace bien Mithren

Esto no es relleno: son fortalezas comprobables en el código.

- **Portabilidad de un solo archivo.** Todo vive en `main.lua` y se carga con un
  `loadstring(HttpGet(...))`. Para el caso de uso (executors) esto es una
  ventaja concreta: cero dependencias que resolver en runtime.
- **Manejo robusto del parenting de la GUI.** `ParentScreenGui`
  (`main.lua:1293`) prueba `gethui`, `syn.protect_gui`, `protect_gui`, `CoreGui`
  y cae a `PlayerGui` como último recurso. Cubre bien la fragmentación de
  executors.
- **Theming por instancia.** El palette se clona por ventana (`ClonePalette`,
  `main.lua:110`) en vez de mutar un estado global, así que dos UIs no se pisan
  el tema. Hay `SetTheme` / `SetAccentColor` / `ResetTheme` en vivo.
- **Sistema de config/saves con criterio.** Hay versionado de esquema
  (`CONFIG_SCHEMA_VERSION`, `main.lua:12`), sanitización de nombres de archivo
  (`SanitizeConfigName`, `main.lua:944`), autosave de sesión y carga diferida.
  No es un `writefile` ingenuo.
- **Tracking de conexiones por dueño.** `Track`/`DisconnectAll`
  (`main.lua:176`, `main.lua:934`) asocian las `RBXScriptConnection` a cada
  instancia. Esto evita leaks al destruir una ventana — un error muy común en
  librerías de este tipo.
- **Iconos Lucide con fallback vectorial.** Si el pack remoto de iconos no carga,
  Mithren **dibuja el icono a mano** con frames/strokes (`CreateLucideFallback`,
  `main.lua:515`). Es resiliente: la UI no queda con cuadrados rotos cuando falla
  la red. Detalle de calidad poco común.
- **API dual y ergonómica.** Conviven la API clásica (`CreateToggle`, etc.) y la
  fluida (`Tab:Toggle(...)`), y casi todos los helpers aceptan forma posicional
  *o* tabla. Baja la fricción para quien la consume.
- **Ventana responsive.** `GetResponsiveWindowMetrics` (`main.lua:855`) adapta el
  tamaño al viewport en mobile, y `MakeDraggable` (`main.lua:881`) **sí** maneja
  `Touch`. La base mobile existe (lo cual hace más llamativo que el picker la
  ignore — ver §4).

---

## 3. Qué hace peor que WindUI

- **Organización del código.** WindUI está modularizado (`src/elements/`,
  `src/components/`, `src/modules/`, `src/themes/`): cada elemento es un archivo.
  Mithren concentra todo en un `main.lua` de ~6.8k líneas. Funciona, pero
  encontrar y modificar cosas cuesta más y el riesgo de regresión al tocar es
  mayor.
- **Localización viva vs estática.** WindUI tiene un módulo `Localization`
  dedicado que puede re-traducir la UI existente. Mithren resuelve cada texto
  **una sola vez** al crear el elemento (`T`, `main.lua:1814`) y no guarda
  referencia a las labels para volver a traducirlas. Resultado: no puede cambiar
  idioma en caliente y termina **forzando un reinicio** (ver §4). Esta es la
  diferencia funcional más importante a favor de WindUI.
- **Legibilidad / naming.** Mithren usa abreviaturas crípticas a nivel de módulo:
  `c`, `s`, `f`, `n`, `ts`, `ui`, y nombres como `v0rtexd` / `Minv0rtexd` /
  `Maxv0rtexd` para las métricas de ventana (`main.lua:136-148`). Para una
  librería que quieres mantener en el tiempo, esto encarece cada lectura.
- **Madurez del color picker.** El `Colorpicker` de WindUI
  (`WindUI/src/elements/Colorpicker.lua`) está pensado como elemento de primera
  clase; el de Mithren mezcla la lógica de input, el posicionamiento absoluto y
  el ciclo de vida en un bloque, y no soporta táctil.

---

## 4. Problemas críticos actuales

Separados por tipo, como pediste.

### 4.1 Arquitectura

- **[RAÍZ] Localización estática.** `T(key, fallback)` devuelve el texto en el
  momento en que se construye el elemento. No hay observers, ni registro de
  labels, ni re-render. Por eso `RestartOnChange` y `PromptRestart` vienen en
  `true` por defecto (`main.lua:1690-1691`) y al cambiar idioma se dispara
  `PromptRestart` (`main.lua:2069-2083`). El "reinicio" no es cosmético: `Restart`
  destruye la UI y **re-descarga + re-ejecuta** `main.lua` por HTTP
  (`main.lua:1969-2052`). Es la causa raíz del peor problema de UX. Mientras la
  localización no guarde referencias a los elementos traducibles, el reinicio es
  inevitable por diseño.
- **Monolito de un archivo.** ~6.8k líneas en `main.lua` con
  responsabilidades muy distintas mezcladas: UI, config, localización, blur
  acrílico (`AcrylicBlur`, `main.lua:1091`) y hasta presets de cielo que
  manipulan `Lighting` (`SKY_PRESETS`, `main.lua:36`). Esto es scope creep dentro
  de un mismo archivo y dificulta el mantenimiento.
- **Estado global vía `_G`.** El registro de instancias usa `_G["MithrenLib_"..title]`
  (`main.lua:1329`) y devuelve un objeto noop si ya existe. Asume efectivamente
  single-instance por título y es propenso a colisiones con otros scripts.
- **Naming críptico** (ver §3) — es deuda de arquitectura, no solo estética.

### 4.2 UX

- **Cambiar idioma exige reiniciar.** Desde la perspectiva del usuario final, el
  flujo es: elijo idioma → aparece un modal "Restart required" → al confirmar, la
  UI se cierra y el script se vuelve a bajar y ejecutar. Es brusco, depende de la
  red y de que la `Url` de reinicio siga viva, y puede perder estado en runtime.
  Es el problema número uno a nivel de experiencia.
- **Color picker inutilizable en mobile.** `svPicker.InputBegan` y
  `hueSlider.InputBegan` solo reaccionan a `MouseButton1`
  (`main.lua:6090-6102`), y el `InputChanged` global solo escucha
  `MouseMovement` (`main.lua:6106-6111`). En táctil (`UserInputType.Touch`) no se
  inicia ni se arrastra el cursor de saturación/valor ni el de hue. El picker
  simplemente no responde en mobile, pese a que el resto de la librería sí tiene
  soporte táctil (`MakeDraggable`).
- **El picker se cierra al hacer scroll fuera de vista.** `UpdatePickerPosition`
  llama a `ClosePicker()` si el botón sale del scrollframe
  (`main.lua:6135-6138`). Es defendible, pero combinado con el posicionamiento
  flotante puede sentirse como que el picker "se escapa".

### 4.3 Visual

- **Posicionamiento del picker con números mágicos.** `UpdatePickerPosition`
  coloca el panel con offsets fijos (`btnPos.X - 170`, `+115`, `-125`, `+50`;
  `main.lua:6140-6148`). En pantallas angostas (mobile) esto es frágil y puede
  quedar mal anclado, además del problema de input.
- **En lo demás, lo visual está bien.** Paleta coherente, corners/strokes
  consistentes, tipografía Gotham, animaciones con tiempos centralizados
  (`animationspeed`, `main.lua:162`). No hay un problema visual estructural; el
  punto débil visual concreto es el picker.

---

## 5. Qué arreglar primero

Priorizado. P0 = antes de cualquier feature nueva.

| Prioridad | Problema | Acción concreta | Esfuerzo |
|-----------|----------|-----------------|----------|
| **P0** | Picker roto en mobile | Aceptar `UserInputType.Touch` en `InputBegan` de `svPicker`/`hueSlider` y en `InputChanged` (junto a `MouseMovement`). Es el cambio de mayor impacto/menor costo. | Bajo |
| **P0** | Idioma exige reinicio | Hacer la localización viva: registrar las labels traducibles (key + objeto) y re-traducirlas en `SetLanguage`, en vez de forzar `PromptRestart`. Dejar el reinicio solo como fallback opcional. | Medio-Alto |
| **P1** | Posicionamiento frágil del picker | Reemplazar offsets mágicos por anclaje relativo al botón y clamping al viewport; verificar en resolución mobile. | Bajo-Medio |
| **P1** | Monolito difícil de mantener | No reescribir: extraer primero las piezas autocontenidas (`AcrylicBlur`, `SKY_PRESETS`, localización, config) a secciones/módulos claros. Bundle final puede seguir siendo un archivo. | Medio |
| **P2** | Naming críptico | Renombrar gradualmente lo peor (`v0rtexd`, `c`/`s`/`f`/`n`) a nombres descriptivos al tocar cada zona. | Bajo (incremental) |
| **P2** | Estado global `_G` | Documentar la asunción single-instance o moverla a un registro propio namespaced; evaluar si el noop silencioso debería avisar. | Bajo |

**Regla sugerida:** congelar features nuevas hasta cerrar los dos P0. Son los
que más afectan a usuarios reales (mobile + cambio de idioma).

---

## 6. Veredicto final

**Continuar — con una pausa de consolidación.**

Mithren no es un experimento que convenga descartar: tiene fortalezas reales
(theming por instancia, tracking de conexiones, fallback de iconos, config
versionada, base responsive) y un nivel de acabado que ya compite con WindUI en
lo visual y en ergonomía de API.

No conviene "seguir agregando features" en el estado actual, porque dos
problemas concretos golpean a usuarios reales: el color picker no sirve en
mobile y cambiar idioma fuerza un reinicio por una decisión de diseño de la
localización. El primero es un arreglo barato; el segundo es la única deuda
arquitectónica que justifica frenar antes de crecer.

Plan recomendado en una frase: **arreglar los dos P0, hacer la localización
viva, y solo entonces retomar features nuevas.** Pausar para consolidar, no
descartar.
