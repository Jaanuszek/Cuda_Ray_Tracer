#ifndef JSONPARSER_CUH
#define JSONPARSER_CUH

#include <vector>
#include <fstream>
#include <cuda/std/variant>
#include "json.hpp"
#include "GPU_factory.cuh"

namespace jsonParserStructs {
    struct parsed_image_params
    {
        int image_width;
        int samples_per_pixel;
    };

    struct parsed_camera_params
    {
        float fov;
        vec3 camera_pos;
        vec3 look_at;
        vec3 vector_up;
    };

    struct LambertianValues
    {
        vec3 Albedo;
    };

    struct MetalValues
    {
        vec3 Albedo;
        float fuzz;
    };

    struct DielectircValues
    {
        float reflaction_index;
    };

    struct Sphere
    {
        vec3 center;
        float radius;
    };

    struct Cube
    {
        vec3 min_vertex;
        vec3 max_vertex;
    };

    struct CylinderAndCone
    {
        vec3 center;
        float radius;
        float height;
    };
}

using mat_data_variant = cuda::std::variant<jsonParserStructs::LambertianValues, jsonParserStructs::MetalValues, jsonParserStructs::DielectircValues>;
using obj_data_variant = cuda::std::variant<jsonParserStructs::Sphere, jsonParserStructs::Cube, jsonParserStructs::CylinderAndCone>;

struct ShapeWrapper
{
    MaterialType mat_type;
    mat_data_variant mat_data;
    ObjectType obj_type;
    obj_data_variant obj_data;
};

class JsonParser
{
private:
    nlohmann::json serializedJson;
    std::vector<ShapeWrapper> shapesVector;
    jsonParserStructs::LambertianValues getLambertianValues(nlohmann::json_abi_v3_12_0::json keyValue);
    jsonParserStructs::MetalValues getMetalValues(nlohmann::json_abi_v3_12_0::json keyValue);
    jsonParserStructs::DielectircValues getDielectircValues(nlohmann::json_abi_v3_12_0::json keyValue);
    jsonParserStructs::Sphere getSphereValues(nlohmann::json_abi_v3_12_0::json keyValue);
    jsonParserStructs::Cube getCubeValues(nlohmann::json_abi_v3_12_0::json keyValue);
    jsonParserStructs::CylinderAndCone getCylinderAndConeValues(nlohmann::json_abi_v3_12_0::json keyValue);
    void parseJson();
public:
    JsonParser(const std::string& pathToFile, std::vector<GenericType>& scene);
    const std::vector<ShapeWrapper>& getShapesVector() { return shapesVector; }
};

#endif
