#include "include/GPU_variables.cuh"

GPU_variables* GPU_variables::instance = nullptr;

GPU_variables::GPU_variables()
{
    // poki co sie ustawia to recznie, ale moze kiedys wpadne na pomysl jak to rozwiazac
    image_width = 400;
    image_height = static_cast<int>(image_width / (16.0f / 9.0f));
    image_height = (image_height < 1) ? 1 : image_height;
    int worldObjCount = 2;
    int picSize = image_width * image_height;

    // tymczasowa struktura na cpu
    render_params host_params;

    // alokacja wskaznikow w tymczasowej strukturze
    checkCudaErrors(cudaMalloc((void**)&host_params.d_rand_state, sizeof(curandState) * picSize));
    checkCudaErrors(cudaMalloc((void**)&host_params.d_list, sizeof(hittable*) * worldObjCount));
    checkCudaErrors(cudaMalloc((void**)&host_params.d_world, sizeof(hittable*)));
    checkCudaErrors(cudaMalloc((void**)&host_params.d_fb, sizeof(vec3) * picSize));
    checkCudaErrors(cudaMalloc((void**)&host_params.d_camera, sizeof(camera*)));

    // Zarezerowanie pamiêci na GPU dla d_render_params
    checkCudaErrors(cudaMalloc((void**)&d_render_params, sizeof(render_params)));

    // Skopiowanie wskaŸników z tymczasowej struktury do GPU
    checkCudaErrors(cudaMemcpy(d_render_params, &host_params, sizeof(render_params), cudaMemcpyHostToDevice));
}

GPU_variables::~GPU_variables()
{
    render_params host_params;
    checkCudaErrors(cudaMemcpy(&host_params, d_render_params, sizeof(render_params), cudaMemcpyDeviceToHost));

    checkCudaErrors(cudaFree(host_params.d_rand_state));
    checkCudaErrors(cudaFree(host_params.d_list));
    checkCudaErrors(cudaFree(host_params.d_world));
    checkCudaErrors(cudaFree(host_params.d_fb));
    checkCudaErrors(cudaFree(host_params.d_camera));
    checkCudaErrors(cudaFree(d_render_params));
    delete instance;
}

void GPU_variables::init()
{
    if (!instance)
    {
        instance = new GPU_variables();
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