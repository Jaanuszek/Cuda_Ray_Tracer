#include "include/GPU_factory.cuh"

GPU_factory::~GPU_factory()
{
    for (auto ptr : GPU_allocations)
    {
        checkCudaErrors(cudaFree(ptr));
    }
}

void* GPU_factory::createLambertian(const vec3& albedo)
{
    lambertian* host_mat_ptr = new lambertian(albedo);
    lambertian* device_mat_ptr = uploadToGPU(*host_mat_ptr);
    delete host_mat_ptr;
    return (void*)device_mat_ptr;
}

void* GPU_factory::createMetal(const vec3& albedo, float fuzz)
{
    metal* host_mat_ptr = new metal(albedo, fuzz);
    metal* device_mat_ptr = uploadToGPU(*host_mat_ptr);
    delete host_mat_ptr;
    return (void*)device_mat_ptr;
}

void* GPU_factory::createDielectric(float reflectation_index)
{
    dielectric* host_mat_ptr = new dielectric(reflectation_index);
    dielectric* device_mat_ptr = uploadToGPU(*host_mat_ptr);
    delete host_mat_ptr;
    return (void*)device_mat_ptr;
}

sphere* GPU_factory::createSphere(const vec3 & center, float radius)
{
    sphere host_sphere = sphere(center, radius);
    sphere* device_sphere_ptr = uploadToGPU(host_sphere);
    return device_sphere_ptr;
}
box* GPU_factory::createBox(const vec3& min, const vec3& max)
{
    box host_sphere = box(min, max);
    box* device_sphere_ptr = uploadToGPU(host_sphere);
    return device_sphere_ptr;
}
cylinder* GPU_factory::createCylinder(const vec3& center, float radius, float height)
{
    cylinder host_sphere = cylinder(center, radius, height);
    cylinder* device_sphere_ptr = uploadToGPU(host_sphere);
    return device_sphere_ptr;
}
cone* GPU_factory::createCone(const vec3& center, float radius, float height)
{
    cone host_sphere = cone(center, radius, height);
    cone* device_sphere_ptr = uploadToGPU(host_sphere);
    return device_sphere_ptr;
}

void GPU_factory::CreateAndGetScene(const std::vector<ShapeWrapper>& shapeWrapper)
{
    using namespace jsonParserStructs;
    for (const auto& shape : shapeWrapper)
    {
        GenericType object;
        mat_data_variant mat_variant = shape.mat_data;
        void* mat_ptr = cuda::std::visit([this](auto&& arg)
        {
            using T = std::decay_t<decltype(arg)>;
            if constexpr (std::is_same_v<T, LambertianValues>)
            {
                vec3 albedo = arg.Albedo;
                return createLambertian(albedo);
            }
            else if constexpr (std::is_same_v<T, MetalValues>)
            {
                vec3 albedo = arg.Albedo;
                float fuzz = arg.fuzz;
                return createMetal(albedo, fuzz);
            }
            else if constexpr (std::is_same_v<T, DielectircValues>)
            {
                float reflaction_index = arg.reflaction_index;
                return createDielectric(reflaction_index);
            }
            else return nullptr;
        }, shape.mat_data);
        object.mat_ptr = mat_ptr;
        object.mat_type = shape.mat_type;

        void* obj_ptr = cuda::std::visit([this](auto&& arg)
        {
            using T = std::decay_t<decltype(arg)>;
            if constexpr (std::is_same_v<T, Sphere>)
            {
                vec3 center = arg.center;
                float radius = arg.radius;
                return (void*)createSphere(center, radius);
            }
            else if constexpr (std::is_same_v<T, Cube>)
            {
                vec3 min_vertex = arg.min_vertex;
                vec3 max_vertex = arg.max_vertex;
                return (void*)createBox(min_vertex, max_vertex);
            }
            else if constexpr (std::is_same_v<T, Cylinder>)
            {
                vec3 center = arg.center;
                float radius = arg.radius;
                float height = arg.height;
                return (void*)createCylinder(center, radius, height);
            }
            else if constexpr (std::is_same_v<T, Cone>)
            {
                vec3 center = arg.center;
                float radius = arg.radius;
                float height = arg.height;
                return (void*)createCone(center, radius, height);
            }
            else return nullptr;
        }, shape.obj_data);
        object.object_ptr = obj_ptr;
        object.obj_type = shape.obj_type;
        GPU_scene.push_back(object);
    }
}