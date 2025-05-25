#include "include/JsonParser.cuh"

JsonParser::JsonParser(const std::string& pathToFile)
{
    try {
        std::ifstream jsonFile(pathToFile);
        if (!jsonFile.is_open())
        {
            std::cerr << "[JSONPARSER ERROR] Cannot open a file\n";
            return;
        }
        serializedJson = nlohmann::json::parse(jsonFile);
        parseJson();
    }
    catch (const nlohmann::json::parse_error& e)
    {
        std::cerr << "[JSONPARSER EXCEPTION] e.what() " << e.what() << "\n";
    }
}

jsonParserStructs::LambertianValues JsonParser::getLambertianValues(const nlohmann::json& keyValue)
{
    jsonParserStructs::LambertianValues val;
    if (keyValue.contains("Albedo")) {
        const auto& albedoArray = keyValue["Albedo"];
        if (albedoArray.is_array() && albedoArray.size() == 3)
        {
            float x = albedoArray[0].get<float>();
            float y = albedoArray[1].get<float>();
            float z = albedoArray[2].get<float>();
            val.Albedo = vec3(x, y, z);
        }
        else
        {
            std::cerr << "Albedo must be an array of 3 floats\n";
            return jsonParserStructs::LambertianValues{};
        }
    }
    else
    {
        std::cerr << "Missing albedo in lambertian\n";
        return jsonParserStructs::LambertianValues{};
    }
    return val;
}
jsonParserStructs::MetalValues JsonParser::getMetalValues(const nlohmann::json& keyValue)
{
    jsonParserStructs::MetalValues val;
    if (keyValue.contains("Albedo")) {
        const auto& albedoArray = keyValue["Albedo"];
        if (albedoArray.is_array() && albedoArray.size() == 3)
        {
            float x = albedoArray[0].get<float>();
            float y = albedoArray[1].get<float>();
            float z = albedoArray[2].get<float>();
            val.Albedo = vec3(x, y, z);
        }
        else
        {
            std::cerr << "Albedo must be an array of 3 floats\n";
            return jsonParserStructs::MetalValues{};
        }
    }
    if (keyValue.contains("fuzz")) {
        val.fuzz = keyValue["fuzz"].get<float>();
    }
    else {
        std::cerr << "Missing fuzz in metal\n";
        return jsonParserStructs::MetalValues{};
    }
    return val;
}
jsonParserStructs::DielectircValues JsonParser::getDielectircValues(const nlohmann::json& keyValue)
{
    jsonParserStructs::DielectircValues val;
    if (keyValue.contains("reflaction_index")) {
        val.reflaction_index = keyValue["reflaction_index"].get<float>();
    }
    else
    {
        std::cerr << "Missing reflaction_index in dielectirc\n";
        return jsonParserStructs::DielectircValues{};
    }
    return val;
}

jsonParserStructs::Sphere JsonParser::getSphereValues(const nlohmann::json& keyValue)
{
    jsonParserStructs::Sphere val;
    if (keyValue.contains("center"))
    {
        const auto& centerArray = keyValue["center"];
        if (centerArray.is_array() && centerArray.size() == 3)
        {
            float x = centerArray[0].get<float>();
            float y = centerArray[1].get<float>();
            float z = centerArray[2].get<float>();
            val.center = vec3(x, y, z);
        }
        else
        {
            std::cerr << "Center must be an array of 3 floats\n";
            return jsonParserStructs::Sphere{};
        }
    }
    else 
    {
        std::cerr << "missing center in sphere\n";
        return jsonParserStructs::Sphere{};
    }
    if (keyValue.contains("radius")) {
        val.radius = keyValue["radius"].get<float>();
    }
    else {
        std::cerr << "Missing radius in sphere\n";
        return jsonParserStructs::Sphere{};
    }
    return val;
}
jsonParserStructs::Cube JsonParser::getCubeValues(const nlohmann::json& keyValue)
{
    jsonParserStructs::Cube val;
    if (keyValue.contains("min_vertex")) {
        const auto& min_vertex_array = keyValue["min_vertex"];
        if (min_vertex_array.is_array() && min_vertex_array.size() == 3)
        {
            float x = min_vertex_array[0].get<float>();
            float y = min_vertex_array[1].get<float>();
            float z = min_vertex_array[2].get<float>();
            val.min_vertex = vec3(x, y, z);
        }
        else
        {
            std::cerr << "min_vertex must be an array of 3 floats\n";
            return jsonParserStructs::Cube{};
        }
    }
    else {
        std::cerr << "Missing min_vertex in Cube\n";
        return jsonParserStructs::Cube{};
    }

    if (keyValue.contains("max_vertex")) {
        const auto& max_vertex_array = keyValue["max_vertex"];
        if (max_vertex_array.is_array() && max_vertex_array.size() == 3)
        {
            float x = max_vertex_array[0].get<float>();
            float y = max_vertex_array[1].get<float>();
            float z = max_vertex_array[2].get<float>();
            val.max_vertex = vec3(x, y, z);
        }
        else
        {
            std::cerr << "max_vertex must be an array of 3 floats\n";
            return jsonParserStructs::Cube{};
        }
    }
    else {
        std::cerr << "Missing max_vertex in Cube\n";
        return jsonParserStructs::Cube{};
    }
    return val;
}
jsonParserStructs::Cylinder JsonParser::getCylinderValues(const nlohmann::json& keyValue)
{
    jsonParserStructs::Cylinder val;
    if (keyValue.contains("center"))
    {
        const auto& centerArray = keyValue["center"];
        if (centerArray.is_array() && centerArray.size() == 3)
        {
            float x = centerArray[0].get<float>();
            float y = centerArray[1].get<float>();
            float z = centerArray[2].get<float>();
            val.center = vec3(x, y, z);
        }
        else
        {
            std::cerr << "Center must be an array of 3 floats\n";
            return jsonParserStructs::Cylinder{};
        }
    }
    else {
        std::cerr << "missing center in cylinder\n";
        return jsonParserStructs::Cylinder{};
    }
    if (keyValue.contains("radius"))
    {
        val.radius = keyValue["radius"].get<float>();
    }
    else {
        std::cerr << "Missing radius in cylinder\n";
        return jsonParserStructs::Cylinder{};
    }
    if (keyValue.contains("height")) {
        val.height = keyValue["height"].get<float>();
    }
    else {
        std::cerr << "Missing height in cylinder \n";
        return jsonParserStructs::Cylinder{};
    }
    return val;
}

jsonParserStructs::Cone JsonParser::getConeValues(const nlohmann::json& keyValue)
{
    jsonParserStructs::Cone val;
    if (keyValue.contains("center"))
    {
        const auto& centerArray = keyValue["center"];
        if (centerArray.is_array() && centerArray.size() == 3)
        {
            float x = centerArray[0].get<float>();
            float y = centerArray[1].get<float>();
            float z = centerArray[2].get<float>();
            val.center = vec3(x, y, z);
        }
        else
        {
            std::cerr << "Center must be an array of 3 floats\n";
            return jsonParserStructs::Cone{};
        }
    }
    else {
        std::cerr << "missing center in cone\n";
        return jsonParserStructs::Cone{};
    }
    if (keyValue.contains("radius"))
    {
        val.radius = keyValue["radius"].get<float>();
    }
    else {
        std::cerr << "Missing radius in cone\n";
        return jsonParserStructs::Cone{};
    }
    if (keyValue.contains("height")) {
        val.height = keyValue["height"].get<float>();
    }
    else {
        std::cerr << "Missing height in cone\n";
        return jsonParserStructs::Cone{};
    }
    return val;
}
void JsonParser::parseJson()
{
    if (serializedJson.contains("image"))
    {
        jsonParserStructs::parsed_image_params img_par;
        const auto& image = serializedJson["image"];
        if (image.contains("image_width") && image.contains("samples_per_pixels"))
        {
            img_par.image_width = image["image_width"].template get<int>();
            img_par.samples_per_pixel = image["samples_per_pixels"].template get<int>();
        }
        else
        {
            img_par.image_width = 400;
            img_par.samples_per_pixel = 50;
        }
        parsedData.img_params = img_par;
    }
    if (serializedJson.contains("camera"))
    {
        jsonParserStructs::parsed_camera_params cam_par;
        const auto& camera = serializedJson["camera"];
        if (camera.contains("fov"))
        {
            cam_par.fov = camera["fov"].get<float>();
        }
        if (camera.contains("camera_pos") && camera["camera_pos"].is_array() && camera["camera_pos"].size() == 3)
        {
            const auto& cam_pos = camera["camera_pos"];
            float x = cam_pos[0].get<float>();
            float y = cam_pos[1].get<float>();
            float z = cam_pos[2].get<float>();
            cam_par.camera_pos = vec3(x, y, z);
        }
        if (camera.contains("look_at") && camera["look_at"].is_array() && camera["look_at"].size() == 3)
        {
            const auto& lookAt = camera["look_at"];
            float x = lookAt[0].get<float>();
            float y = lookAt[1].get<float>();
            float z = lookAt[2].get<float>();
            cam_par.look_at = vec3(x, y, z);
        }
        if (camera.contains("vector_up") && camera["vector_up"].is_array() && camera["vector_up"].size() == 3)
        {
            const auto& vectorUp = camera["vector_up"];
            float x = vectorUp[0].get<float>();
            float y = vectorUp[1].get<float>();
            float z = vectorUp[2].get<float>();
            cam_par.vector_up = vec3(x, y, z);
        }
        parsedData.cam_params = cam_par;
    }
    if (serializedJson.contains("objects"))
    {
        auto objects = serializedJson["objects"];
        for (const auto& obj : objects)
        {
            ShapeWrapper shape;
            if (obj.contains("material"))
            {
                auto material = obj["material"];
                if (material.contains("type"))
                {
                    MaterialType type;
                    mat_data_variant material_data;
                    auto mat_type = material["type"];
                    if (mat_type == "Lambertian")
                    {
                        type = MaterialType::Lambertian;
                        material_data = getLambertianValues(material);
                    }
                    else if (mat_type == "Metal")
                    {
                        type = MaterialType::Metal;
                        material_data = getMetalValues(material);
                    }
                    else if (mat_type == "Dielectric")
                    {
                        type = MaterialType::Dielectric;
                        material_data = getDielectircValues(material);
                    }
                    else
                    {
                        type = MaterialType::NONE;
                    }
                    shape.mat_type = type;
                    shape.mat_data = material_data;
                }
            }
            if (obj.contains("object_type"))
            {
                ObjectType objType;
                obj_data_variant objData;
                auto obj_type = obj["object_type"];
                if (obj_type["type"] == "Sphere")
                {
                    objType = ObjectType::Sphere;
                    objData = getSphereValues(obj_type);
                }
                else if (obj_type["type"] == "Cube")
                {
                    objType = ObjectType::Cube;
                    objData = getCubeValues(obj_type);
                }
                else if (obj_type["type"] == "Cylinder")
                {
                    objType = ObjectType::Cylinder;
                    objData = getCylinderValues(obj_type);
                }
                else if (obj_type["type"] == "Cone")
                {
                    objType = ObjectType::Cone;
                    objData = getConeValues(obj_type);
                }
                else
                {
                    objType = ObjectType::NONE;
                }
                shape.obj_type = objType;
                shape.obj_data = objData;
            }
            parsedData.shapesVector.push_back(shape);
        }
    }
}
