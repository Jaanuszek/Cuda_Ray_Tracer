#include "include/GPU_variables.cuh"

GPU_variables* GPU_variables::instance = nullptr;

GPU_variables::GPU_variables(int width, int height, int objCount)
{
    int picSize = width * height;

    d_render_params = nullptr;
    // tymczasowa struktura na cpu
    //render_params host_params;
    h_render_params = new render_params;
    memset(h_render_params, 0, sizeof(render_params));

    // alokacja wskaznikow w tymczasowej strukturze
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_rand_state, sizeof(curandState) * picSize));
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_list, sizeof(hittable*) * objCount));
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_world, sizeof(hittable*)));
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_fb, sizeof(vec3) * picSize));
    checkCudaErrors(cudaMalloc((void**)&h_render_params->d_camera, sizeof(camera*)));

    // Zarezerowanie pamiêci na GPU dla d_render_params
    checkCudaErrors(cudaMalloc((void**)&d_render_params, sizeof(render_params)));

    // Skopiowanie wskaŸników z tymczasowej struktury do GPU
    checkCudaErrors(cudaMemcpy(d_render_params, h_render_params, sizeof(render_params), cudaMemcpyHostToDevice));
}

GPU_variables::~GPU_variables()
{
    if (h_render_params) {
        checkCudaErrors(cudaFree(h_render_params->d_rand_state));
        checkCudaErrors(cudaFree(h_render_params->d_list));
        checkCudaErrors(cudaFree(h_render_params->d_world));
        checkCudaErrors(cudaFree(h_render_params->d_fb));
        checkCudaErrors(cudaFree(h_render_params->d_camera));
        delete h_render_params;
        h_render_params = nullptr;
    }
    if (d_render_params) {
        checkCudaErrors(cudaFree(d_render_params));
        d_render_params = nullptr;
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