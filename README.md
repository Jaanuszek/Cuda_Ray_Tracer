# Cuda_Ray_Tracer
As the project name suggests, this is a ray tracer (path tracer, to be more specific) written from the beggining in C++, [CUDA](https://developer.nvidia.com/cuda-toolkit). Cuda was used to parallelize the calculations of pixel colors and perform them on the GPU.

## Prequirements

- Visual Studio Enterprise 2022 with MSVC compiler,
- Nvidia GPU graphics card, with [Compute Capability 7.5](https://developer.nvidia.com/cuda-gpus) support,
- [Cuda Toolkit](https://developer.nvidia.com/cuda-downloads) (Project was written using version 12.8)
- (Optional) [CMake](https://cmake.org/) (>3.25)

## Build

### Visual Studio

In order to build an executable, open project solution and hit f5 button.

### CMake

1. Go to the folder where `CMakeLists.txt` is placed,
2. Execute in your terminal:

```CMake
cmake -B <path to build dir> -S .
```
3. Go to build folder and execute:

```CMake
cmake --build .
```

## How To output Image

To get rendered image, localize builded binary (If you still do not have a binary, follow this [instruction](#build)). Open your favourite terminal and run this command:

- For Linux 
    ```bash
    ./cuda_ray_tracer.exe > <fileName>.ppm
    ```
- For Windows (PowerShell)

    ```powershell
    .\cuda_ray_tracer > <fileName>.ppm
    ```

It will pass standard output directly to file with `.ppm` extension (For now this ray tracer only suport creating [PPM P3](https://netpbm.sourceforge.net/doc/ppm.html) file format). Great, you just got your rendered image! The easiest way to view the image, is to use the [online PPM viewer](https://www.cs.rhodes.edu/welshc/COMP141_F16/ppmReader.html). If no errors occured during compilation and rendering, you will see your image!

To make this application more interesting, I've created a JSON config and JSON parser, so the user can change camera position, resolution of the resulting image, interpolation details and what's most interesting, it possible to add/delete/move objects on scene.