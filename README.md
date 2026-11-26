# ReUIKit

A compact Qt Quick UI kit built from pure QML primitives — no Qt Quick Controls, no dependencies beyond Qt Quick.

ReUIKit provides a set of everyday controls (buttons, inputs, comboboxes, switches, sliders, progress indicators) and a single global theme object that restyles the whole application from one place: palettes, light/dark modes, corner shapes, sizes. Everything is plain `Item` / `Rectangle` / `Text` / `MouseArea` QML, which keeps the kit lightweight, easy to read and easy to embed.

## Tech stack

| | |
|---|---|
| Language | QML (+ a thin C++ bootstrap in `main.cpp`) |
| Qt | 6.10 or newer, Qt Quick only — no Qt Quick Controls |
| Build | CMake ≥ 3.16, `qt_add_qml_module` |
| Platforms | Desktop (Windows) and Android; phone-friendly layout — safe area margins, vertical-only scrolling, wrapping rows |

## Components

| Component | Description |
|---|---|
| `ReBtn` | Push button, `Accent` / `Simple` styles |
| `ReRoundBtn` | Round button for short actions (`+`, `✕`, single glyphs) |
| `ReInput` | Text field with placeholder, password echo and error state |
| `ReComboBox` | Dropdown with a floating popup, keyboard navigation and its own scrollbar |
| `ReCheckBox` | Checkbox with an animated canvas checkmark |
| `ReRadio`, `ReRadioGroup` | Radio buttons; groups register children automatically |
| `ReSwitch` | Toggle switch |
| `ReSlider` | Slider with optional step, click-to-jump and dragging |
| `ReProgressBar` | Progress bar, determinate and indeterminate modes |
| `ReSpinner` | Circular loading indicator |
| `UiTheme`, `UiPresets` | Theme singletons — see below |

## Theming

All components read their defaults from the `UiTheme` singleton:

```qml
import "./Styles"

UiTheme.preset = "firefly"          // palette
UiTheme.mode = UiTheme.Dark         // light / dark mode
UiTheme.shape = UiTheme.ShapeSoft   // Sharp / Soft / Round corners
```

**Built-in palettes** — solid (`blue`, `green`, `violet`) and duotone (`firefly`, `ocean`, `orchid`, `sage`, `bronze`). Duotone palettes carry two matching accents: buttons, checked controls (switches, checkboxes, radios) and meters (sliders, progress, spinner) split the accents automatically, so two-color themes never look monotonous.

**Custom palettes** — add one line to `UiPresets.qml`:

```qml
"mytheme": makeTheme("#123456", "#ff8000", "#ABCDEF", "#FEDCBA")
// or a two-accent (duotone) theme:
"myduo":   makeDuoTheme("#123456", "#ff8000", "#ABCDEF", "#FEDCBA")
```

**Runtime overrides** — replace any value globally; derived colors and contrast text recalculate automatically:

```qml
UiTheme.primary = "#6750A4"
UiTheme.apply({ controlHeight: 36, fontSize: 15 })
```

**Per-component customization** — every visual property (colors, radii, sizes) is declared on the component and can be overridden in place:

```qml
ReBtn {
    text: "Custom"
    bgColor: "#7C3AED"
    btnRadius: 16
}
```

Controls with accents also accept `accent: "auto" | "primary" | "secondary"`: `"auto"` follows the theme role (checked controls take the second accent in duotone themes), the other two force a specific accent on a single instance.

**Contrast-safe text** — text on colored surfaces (buttons, selected items, checkmarks) is picked automatically using the WCAG relative luminance of the background, in both light and dark modes.

## Getting started

Requires Qt 6.10+ and CMake.

```bash
cmake -B build
cmake --build build
```

Or open the project folder in Qt Creator — it picks up `CMakeLists.txt` and configures a kit automatically. Run the app to browse the demo page (`Main.qml`) with live theme switching.

## Project layout

```
Main.qml               demo page with live theme controls
Components/            Re* controls
Styles/UiTheme.qml     global theme singleton
Styles/UiPresets.qml   palette library
```
