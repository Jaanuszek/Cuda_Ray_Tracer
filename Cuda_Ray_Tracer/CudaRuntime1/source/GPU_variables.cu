#include "include/GPU_variables.cuh"

GPU_variables* GPU_variables::instance = nullptr;

hittable_list* GPU_variables::create_world(hittable** list, int sphereWidth, int sphereHeight)
{
    std::random_device dev;
    std::mt19937 rng(dev());
    std::uniform_real_distribution<> dis(0.0f, 1.0f);

    int objCount = 5 + sphereWidth * sphereHeight;

    //std::vector<hittable*> resultVector;
    //resultVector.resize(objCount);

    // a gdyby ta liste zrobic jako vector po prostu?
    //hittable** h_list = h_render_params->list;
    //hittable** h_list = list;

    int listIndex = 0;

    for (int i = 0; i < sphereHeight; i++)
    {
        for (int j = 0; j < sphereWidth; j++)
        {
            float chose_material = dis(rng);
            float x = -5.0f + j + 0.7f * dis(rng);
            float y = 0.2f;
            float z = -1.0f - i - 0.7f * dis(rng);
            vec3 centerOfSphere(x, y, z);
            material* mat_ptr = nullptr;
            if (chose_material < 0.4f)
            {
                float albedo = dis(rng) * dis(rng);
                vec3 albedoVec(
                    dis(rng) * dis(rng),
                    dis(rng) * dis(rng),
                    dis(rng) * dis(rng)
                );
                mat_ptr = new lambertian(albedoVec);
                //list[listIndex++] = new sphere(centerOfSphere, 0.2f, mat_ptr);
                list[listIndex++] = new sphere(centerOfSphere, 0.2f, mat_ptr);
            }
            else if (chose_material < 0.8f && chose_material > 0.4f)
            {
                float albedo = (dis(rng) + 1.0f) * 0.5f;
                vec3 albedoVec(
                    (dis(rng) + 1.0f) * 0.5f,
                    (dis(rng) + 1.0f) * 0.5f,
                    (dis(rng) + 1.0f) * 0.5f
                );
                float fuzz = dis(rng);
                mat_ptr = new metal(albedoVec, fuzz);
                //list[listIndex++] = new sphere(centerOfSphere, 0.2f, mat_ptr);
                list[listIndex++] = new sphere(centerOfSphere, 0.2f, mat_ptr);
            }
            else
            {
                mat_ptr = new dielectric(1.50f);
                //list[listIndex++] = new sphere(centerOfSphere, 0.2f, mat_ptr);
                list[listIndex++] = new sphere(centerOfSphere, 0.2f, mat_ptr);
            }
        }
    }

    lambertian* material_ground = new lambertian(vec3(0.5f, 0.5f, 0.5f));
    lambertian* material_center = new lambertian(vec3(0.1f, 0.2f, 0.5f));
    dielectric* material_left = new dielectric(1.50f);
    dielectric* material_bubble = new dielectric(1.00f / 1.50f);
    metal* material_right = new metal(vec3(0.8f, 0.6f, 0.2f), 0.0f);
    //list[listIndex++] = new sphere(point3(0.0f, -1000.0f, 0.0f), 1000.0f, material_ground);
    //list[listIndex++] = new sphere(point3(0.0f, 0.5f, -1.2f), 0.5f, material_center);
    //list[listIndex++] = new sphere(point3(-1.0f, 0.5f, -1.0f), 0.5f, material_left);
    //list[listIndex++] = new sphere(point3(-1.0f, 0.4f, -1.0f), 0.4f, material_bubble);
    //list[listIndex++] = new sphere(point3(1.0f, 0.5f, -1.0f), 0.5f, material_right);
    list[listIndex++] = new sphere(point3(0.0f, -1000.0f, 0.0f), 1000.0f, material_ground);
    list[listIndex++] = new sphere(point3(0.0f, 0.5f, -1.2f), 0.5f, material_center);
    list[listIndex++] = new sphere(point3(-1.0f, 0.5f, -1.0f), 0.5f, material_left);
    list[listIndex++] = new sphere(point3(-1.0f, 0.4f, -1.0f), 0.4f, material_bubble);
    list[listIndex++] = new sphere(point3(1.0f, 0.5f, -1.0f), 0.5f, material_right);

    return new hittable_list(list, listIndex);
    //return resultVector;
    //return std::make_shared<hittable_list>(list.data(), objCount);
}

GPU_variables::GPU_variables(int width, int height, int objCount) : image_width(width), image_height(height), objectCount(objCount)
{
    int picSize = width * height;

    // CPU
    h_render_params = new render_params;
    // memset zeby wyzerowaæ wszystkie pola struktury, bo render_params nie ma konstruktora
    memset(h_render_params, 0, sizeof(render_params));

    //h_list.resize(objCount);
    h_list = new hittable*[objCount];
    h_world = create_world(h_list,10, 10);
    //for (int i = 0; i < ((hittable_list*)h_world)->list_size; i++)
    //{
    //    printf("index: %d", i);
    //}

    curandState* d_rand_state;
    hittable** d_list;
    hittable_list* d_world;
    vec3* d_fb;

    //GPU
    checkCudaErrors(cudaMalloc((void**)&d_rand_state, sizeof(curandState) * picSize));

    //https://stackoverflow.com/questions/40682163/cuda-copy-inherited-class-object-to-device

    hittable** temp_d_list;
    temp_d_list = new hittable * [objCount];
    for (int i = 0; i < objCount; i++)
    {
        cudaMalloc(&temp_d_list[i], sizeof(hittable));
        cudaMemcpy(temp_d_list[i], h_list[i], sizeof(hittable), cudaMemcpyHostToHost);
    }
    checkCudaErrors(cudaMalloc((void**)&d_list, sizeof(hittable*) * objCount));
    checkCudaErrors(cudaMemcpy(d_list, temp_d_list, sizeof(hittable*) * objCount, cudaMemcpyHostToDevice));

    hittable_list h_world_temp = *h_world;
    h_world_temp.m_objects_ptr = d_list;
    h_world_temp.list_size = objCount;
    //check_ptr_type(h_world);
    //check_ptr_type(h_list);

    checkCudaErrors(cudaMalloc((void**)&d_world, sizeof(hittable_list)));
    checkCudaErrors(cudaMemcpy(d_world, &h_world_temp, sizeof(hittable_list), cudaMemcpyHostToDevice));
    //checkCudaErrors(cudaMemcpy(d_world->m_objects_ptr, h_list, sizeof(hittable*) * objCount, cudaMemcpyHostToDevice));
    //check_ptr_type(d_world);
    //check_ptr_type(d_world->m_objects_ptr);
    //checkCudaErrors(cudaMemcpy(d_world->m_objects_ptr, h_list.data(), sizeof(hittable*) * objCount, cudaMemcpyHostToDevice));
    checkCudaErrors(cudaMalloc((void**)&d_fb, sizeof(vec3) * picSize));

    h_render_params->rand_state = d_rand_state;
    h_render_params->list = d_list;
    h_render_params->world = d_world;
    h_render_params->fb = d_fb;
}

GPU_variables::~GPU_variables()
{
    if (h_render_params) {
        for (int obj = 0; obj < objectCount; obj++)
        {
            if (h_list[obj]) {
                delete h_list[obj];
                h_list[obj] = nullptr;
            }
        }
        //delete[] h_list; h_list = nullptr;
        if (h_world)
        {
            delete h_world;
            h_world = nullptr;
        }

        checkCudaErrors(cudaFree(h_render_params->rand_state));
        checkCudaErrors(cudaFree(h_render_params->list));
        checkCudaErrors(cudaFree(h_render_params->world));
        checkCudaErrors(cudaFree(h_render_params->fb));

        delete h_render_params; h_render_params = nullptr;
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