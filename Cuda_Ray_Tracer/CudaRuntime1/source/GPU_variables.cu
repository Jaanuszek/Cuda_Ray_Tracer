#include "include/GPU_variables.cuh"

GPU_variables* GPU_variables::instance = nullptr;

GPU_variables::GPU_variables(int width, int height, int objCount)
{
    int picSize = width * height;

    h_render_params = new render_params;
    // memset zeby wyzerowaæ wszystkie pola struktury, bo render_params nie ma konstruktora
    memset(h_render_params, 0, sizeof(render_params));

    // alokacja wskaznikow w tymczasowej strukturze
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_rand_state, sizeof(curandState) * picSize));
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_list, sizeof(hittable*) * objCount));
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_world, sizeof(hittable*)));
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_fb, sizeof(vec3) * picSize));
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_camera, sizeof(camera*)));
}

GPU_variables::~GPU_variables()
{
    if (h_render_params) {
        checkCudaErrors(cudaFree(h_render_params->d_rand_state));
        h_render_params->d_rand_state = nullptr;
        checkCudaErrors(cudaFree(h_render_params->d_list));
        h_render_params->d_list = nullptr;
        checkCudaErrors(cudaFree(h_render_params->d_world));
        h_render_params->d_world = nullptr;
        checkCudaErrors(cudaFree(h_render_params->d_fb));
        h_render_params->d_fb = nullptr;
        checkCudaErrors(cudaFree(h_render_params->d_camera));
        h_render_params->d_camera = nullptr;
        delete h_render_params;
        h_render_params = nullptr;
    }
    instance = nullptr;
}

void GPU_variables::init(int width, int height, int objCount)
{
    if (!instance)
    {
        instance = new GPU_variables(width, height, objCount);
    }
}

GPU_variables& GPU_variables::getInstance()
{
    if (!instance)
    {
        throw std::runtime_error("GPU_variables not initialized. Call init() first.");
    }
    return *instance;
}

void GPU_variables::destroy()
{
    if (instance)
    {
        delete instance;
        instance = nullptr;
    }
}