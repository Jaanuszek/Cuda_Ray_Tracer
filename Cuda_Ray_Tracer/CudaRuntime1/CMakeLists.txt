cmake_minimum_required(VERSION 3.25)
project(cuda_ray_tracer LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)

set(CMAKE_CUDA_SEPARABLE_COMPILATION ON)
set(CMAKE_CUDA_RUNTIME_LIBRARY Shared)

file(GLOB SRC_FILES
    source/*.cu
)

include_directories(source/include)

add_executable(${CMAKE_PROJECT_NAME} 
    main.cu
    ${SRC_FILES}
)

set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES CUDA_ARCHITECTURES "native")