# Cuda_Ray_Tracer
As the project name suggests, this is a ray tracer (path tracer, to be more specific) written from the beggining in C++, [CUDA](https://developer.nvidia.com/cuda-toolkit). Cuda was used to parallelize the calculations of pixel colors and perform them on the GPU.

## Prequirements

- Visual Studio Enterprise 2022 with MSVC compiler,
- Nvidia GPU graphics card, with [Compute Capability 7.5](https://developer.nvidia.com/cuda-gpus) support,
- [Cuda Toolkit](https://developer.nvidia.com/cuda-downloads) (Project was written using version 12.8)
- (Optional) [CMake](https://cmake.org/) (>3.25)

## Build

### Visual Studio

In order to build an executable, open project solution and hit `F5` button.

### CMake

1. Go to the folder where `CMakeLists.txt` is placed,
2. Execute in your terminal:

```cmake
cmake -B <path to build dir> -S .
```
3. Go to build folder and execute:

```cmake
cmake --build .
```

## JSON Config file

To make this application more interesting, the JSON config file parser was created. Using it, the user is able to change image resolution, camera position or even add/move/delete objects on scene. Example JSON config file can be found [here](./Cuda_Ray_Tracer/CudaRuntime1/JSON_config/cuda_ray_tracer_JSON.json).

### Changing image settings

```json
    "image" : 
    {
        "image_width" : 1200,
        "samples_per_pixels" : 50
    }
```

- `image_width` is a image width in pixel. Image height is calculated using 16:9 aspect ratio,
- `samples_per_pixel` indicates how many recursive function calls must be executed in order to interpolate a pixel color.

### Camera position

```json
    "camera" : 
    {
        "fov" : 90.0,
        "camera_pos" : [-2.0, 2.0, 2.0],
        "look_at" : [0.0, 0.0, -2.0],
        "vector_up" : [0.0, 1.0, 0.0]
    }
```

- `fov` - Field of View angle,
- `camera_pos` - Position of camera on scene,
- `look_at` - The point on the scene to which the camera is directed,
- `vector_up` - Up vector.

### Objects

- Sphere
    ```json
        "object_type" : 
        {
            "type" : "Sphere",
            "center" : [-1.0, 0.5, -1.0],
            "radius" : 0.5
        }
    ```
- Cube
    ```json
        "object_type" : 
        {
            "type" : "Cube",
            "min_vertex" : [-3.0, 0.5, 0.0],
            "max_vertex" : [-2.0, 1.5, -1.0]
        }
    ```
    - `min_vertex` - Position of left bottom vertex of a cube,
    - `max_vertex` - Position of right upper vertex of a cube.
- Cylinder
    ```json
        "object_type" : 
        {
            "type" : "Cylinder",
            "center" : [0.0, 1.0, -3.2],
            "radius" : 1.0,
            "height" : 2.0
        }
    ```
- Cone
    ```json
        "object_type" : 
        {
            "type": "Cone",
            "center": [ 2.0, 0.5, -1.5 ],
            "radius": 0.5,
            "height": 1.5
        }
    ```
    The rest of the parameters are rather logical and self explanatory.

### Materials

- Lambertian (Diffuse)
    ```json
        "material": 
        {
            "type": "Lambertian",
            "Albedo": [ 1.0, 0.0, 0.0 ]
        }
    ```
    - `Albedo` is a default color of an object (R,G,B)[0-1].
- Metal
    ```json
        "material": 
        {
            "type": "Metal",
            "Albedo": [ 0.1, 1.0, 0.1 ],
            "fuzz": 0.2
        },
    ```
    - `fuzz` - Fuzzines of the material, the lower the fuzz value, the more mirror-like the object is [0-1].
- Dielectric
    ```json
      "material": 
      {
            "type": "Dielectric",
            "reflaction_index": 1.5
      },
    ```
    - `reflaction_index` - [Refractive index](https://en.wikipedia.org/wiki/Refractive_index) of [Snell's law](https://en.wikipedia.org/wiki/Snell%27s_law).

## How To output Image

To get rendered image, localize builded binary (If you still do not have a binary, follow this [instruction](#build)). Open your favourite terminal and run this command:

- For Linux 
    ```bash
    ./cuda_ray_tracer.exe > `fileName`.ppm
    ```
- For Windows (PowerShell)

    ```powershell
    .\cuda_ray_tracer > `fileName`.ppm
    ```

It will pass standard output directly to file with `.ppm` extension (For now this ray tracer only suport creating [PPM P3](https://netpbm.sourceforge.net/doc/ppm.html) file format). Great, you just got your rendered image! The easiest way to view the image, is to use the [online PPM viewer](https://www.cs.rhodes.edu/welshc/COMP141_F16/ppmReader.html). If no errors occured during compilation and rendering, you will be able to see your image(s)!

## Screenshots

![FirstSS](/README_JPG/FIRST.png)

![SecondSS](/README_JPG/SECOND.png)

![ThirdSS](/README_JPG/THIRD.png)