# Mithren

Mithren es una libreria UI para Roblox/Luau pensada para executors.

## Estructura

- `main.lua`: libreria principal.
- `example.lua`: UI de ejemplo/test para probar componentes.
- `README.md`: documentacion rapida.

## Cargar

```lua
local Mithren = loadstring(game:HttpGet("<URL_RAW>"))()
-- o, si ya fue cargado:
local Mithren = _G.MithrenLibrary
```

## Crear Ventana

```lua
local UI = Mithren:Window({
    Title = "Mi Script",
    ConfigFolder = "MiScript",
    Version = "v1.0.0",
})
```

`Version` muestra un tag al lado del titulo. Tambien se puede cambiar en vivo:

```lua
UI:SetVersionTag("v1.0.1")
```

Mithren crea siempre una seccion interna `Ajustes` con tres tabs estandar:

- `Ajustes`: idioma y tecla para abrir/cerrar UI.
- `Tema`: preset, colores, transparencias, fondo y reset.
- `Guardados`: saves, autosave, importar/exportar.

Puedes acceder a esos tabs desde `UI.systemTabs`.

## Sections Y Tabs

```lua
local Main = UI:Section("Principal")
local Tab = Main:Tab("Main", "home")
```

El segundo argumento del tab es un icono Lucide.

## API Simple

Todos los helpers aceptan tambien forma tabla, por ejemplo `Tab:Toggle({ Name = "...", Default = false, Callback = fn })`.

```lua
Tab:Button("Run", function()
    print("clicked")
end)

Tab:Toggle("Auto Farm", false, function(value)
    print(value)
end)

Tab:Slider("Speed", 0, 100, 50, function(value)
    print(value)
end)

Tab:Dropdown("Mode", { "A", "B", "C" }, "A", function(value)
    print(value)
end)

Tab:MultiDropdown("Items", { "Rojo", "Azul", "Verde" }, { "Rojo" }, function(values)
    print(table.concat(values, ", "))
end)

Tab:TextBox("Name", "placeholder", "", function(text)
    print(text)
end)

Tab:NumberBox("Amount", "0", "0", function(text)
    print(text)
end)

Tab:Keybind("Open", Enum.KeyCode.F, function(key)
    print(key)
end)

Tab:ColorPicker("Accent", Color3.fromRGB(100, 180, 255), function(color)
    UI:SetAccentColor(color)
end)

Tab:Paragraph("Titulo", "Texto informativo")
Tab:Section("Separador")
```

## Idioma

El selector de idioma es opcional. Si necesitas varios idiomas para un script publico, evita meter todos los textos en el script principal: usa `Localization` para cargar solo el pack del usuario y cachearlo.

```lua
local UI = Mithren:Window({
    Title = "Mi Script",
    ConfigFolder = "MiScript",
    LanguageSelector = {
        Default = "es",
        Options = {
            { Label = "Español", Value = "es" },
            { Label = "English", Value = "en" },
        },
        Callback = function(language)
            print(language)
        end,
    },
    Localization = {
        AutoDetect = true,
        Fallback = "en",
        BaseUrl = "https://raw.githubusercontent.com/usuario/repo/main/lang",
        Cache = true,
        Restart = {
            Url = "https://raw.githubusercontent.com/usuario/repo/main/main.lua",
        },
        Messages = {
            es = {
                RestartTitle = "Reinicio necesario",
                RestartDescription = "El idioma cambio. Reinicia el script para aplicar todos los textos.",
                RestartLater = "Luego",
                RestartNow = "Reiniciar",
            },
        },
    },
})

Tab:Button(UI:T("farm.start", "Iniciar farm"), function()
    print(UI:T("farm.started", "Farm iniciado"))
end)
```

Los packs remotos deben ser JSON simples:

```json
{
  "farm.start": "Start farm",
  "farm.started": "Farm started"
}
```

## Example

`example.lua` contiene la UI de prueba que antes vivia dentro de la libreria principal.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryshub/Mithren/main/example.lua"))()
```

## Saves / Config

Agrega `Flag` a los elementos que quieras guardar y despues crea una seccion de config.

```lua
Tab:Toggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "auto_farm",
    Callback = function(value) end,
})

Tab:ConfigSection({
    Title = "Saves",
    ShowAdvanced = true,
    ShowAutoSave = true,
})
```

## Tema

Los temas son por instancia.

```lua
UI:SetAccentColor(Color3.fromRGB(0, 170, 255))

UI:SetTheme({
    AccentColor = Color3.fromRGB(0, 170, 255),
    BackgroundColor = Color3.fromRGB(10, 10, 11),
    SecondaryColor = Color3.fromRGB(25, 25, 27),
    ElementTransparency = 0.18,
})

UI:ResetTheme()
```

## API Clasica

La API clasica sigue disponible:

```lua
local UI = Mithren.new("Mi Script", "MiScript")
local Section = UI:CreateSection("Principal")
local Tab = Section:CreateTab("Main", "home")

Tab:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(value) end,
})
```
