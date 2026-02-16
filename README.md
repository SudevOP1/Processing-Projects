# Processing-Projects

## How to run processing projects using VSCode:

### Prerequisites

Install [Java](https://www.java.com/en/download/) & [Processing IDE](https://processing.org/download)<br>
Verify installation using `processing-java --help`<br>
If the command fails, add Processing to your system PATH<br>

### Method 1: Run from Terminal

From the project root directory:

```bash
processing-java --force --sketch="." --output="out" --run
```

If you are outside the project folder:

```bash
processing-java --force --sketch="FULL_PATH_TO_PROJECT" --output="FULL_PATH_TO_PROJECT\out" --run
```

Notes:

- The sketch folder name must match the main `.pde` file name
- The `--run` flag must be the last argument
- Press `Esc` to exit the sketch window

### Method 2: Run Using VS Code Task

#### ✅ One-Time Setup:

- Open project directory in VSCode
- Install the [Processing Extension](https://marketplace.visualstudio.com/items?itemName=Luke-zhang-04.processing-vscode) for VSCode
- Press `Ctrl + Shift + P` to open the command palette
- Select `Processing: Create Task File`
- Select the `.pde` file you want to run

#### 🚀 Running The Project:

- Press `Ctrl + Shift + B`
  - This will compile and run the `.pde` file using the task created earlier
- Press `Escape` to quit the program

<br>

## 🎬 Outputs

### ElasticCollisions

![ElasticCollisions](https://raw.githubusercontent.com/SudevOP1/Processing-Projects/main/outputs/ElasticCollisions.gif)

### Gravity

![Gravity Output Video](https://raw.githubusercontent.com/SudevOP1/Processing-Projects/main/outputs/Gravity.mp4)

### JuliaSet

![JuliaSet Output Video](https://raw.githubusercontent.com/SudevOP1/Processing-Projects/main/outputs/JuliaSet.mp4)

### Mandelbrot

![Mandelbrot](https://raw.githubusercontent.com/SudevOP1/Processing-Projects/main/outputs/Mandelbrot.png)

### TerrainGeneration

![TerrainGeneration Output Video](https://raw.githubusercontent.com/SudevOP1/Processing-Projects/main/outputs/TerrainGeneration.mp4)

### Mandelbulb

![Mandelbulb Output Video](https://raw.githubusercontent.com/SudevOP1/Processing-Projects/main/outputs/Mandelbulb.gif)
