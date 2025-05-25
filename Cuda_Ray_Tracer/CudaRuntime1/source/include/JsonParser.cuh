#ifndef JSONPARSER_CUH
#define JSONPARSER_CUH

#include <vector>
#include <fstream>
#include <windows.h>
#include "json.hpp"
#include "GPU_factory.cuh"

struct ParsedData
{
    jsonParserStructs::parsed_image_params img_params;
    jsonParserStructs::parsed_camera_params cam_params;
    std::vector<ShapeWrapper> shapesVector;
};


class JsonParser
{
private:
    nlohmann::json serializedJson;
    ParsedData parsedData;
    jsonParserStructs::LambertianValues getLambertianValues(const nlohmann::json& keyValue);
    jsonParserStructs::MetalValues getMetalValues(const nlohmann::json& keyValue);
    jsonParserStructs::DielectircValues getDielectircValues(const nlohmann::json& keyValue);
    jsonParserStructs::Sphere getSphereValues(const nlohmann::json& keyValue);
    jsonParserStructs::Cube getCubeValues(const nlohmann::json& keyValue);
    jsonParserStructs::Cylinder getCylinderValues(const nlohmann::json& keyValue);
    jsonParserStructs::Cone getConeValues(const nlohmann::json& keyValue);
    void parseJson();
public:
    JsonParser(const std::string& pathToFile);
    const ParsedData& getParsedData() { return parsedData; }

};

#endif
