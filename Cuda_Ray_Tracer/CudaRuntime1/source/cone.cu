#include "include/cone.cuh"

__device__ bool cone::hit(const ray& r, interval ray_t, hit_record& rec, void* mat, MaterialType mat_type)
{
    vec3 oc = r.get_origin() - center;

    float A = r.get_origin().x() - center.x();
    float B = r.get_origin().z() - center.z();
    float D = height - r.get_origin().y() - center.y();


    float dirx = r.get_direction().x();
    float dirx2 = dirx * dirx;
    float diry = r.get_direction().y();
    float diry2 = diry * diry;
    float dirz = r.get_direction().z();
    float dirz2 = dirz * dirz;

    float tan = radius / height;
    float tan2 = tan * tan;
    vec3 tip = center + vec3(0, height, 0);
    vec3 oc_tip = r.get_origin() - tip;

    float a = dirx2 + dirz2 - tan2 * diry2;
    float b = 2 * (oc_tip.x() * dirx + oc_tip.z() * dirz - tan2 * oc_tip.y() * diry);
    float c = oc_tip.x() * oc_tip.x() + oc_tip.z() * oc_tip.z() - tan2 * oc_tip.y() * oc_tip.y();

    float delta = b * b - 4 * a * c;
    if (delta < 0)
        return false;
    float sqrtDelta = sqrt(delta);

    float root = (-b - sqrtDelta) / (2.0f * a);
    if (!ray_t.surrounds(root)) {
        root = (-b + sqrtDelta) / (2.0f * a);
        if (!ray_t.surrounds(root))
            return false;
    }

    rec.t = root;
    rec.p = r.at(rec.t);

    if (rec.p.y() < center.y() || rec.p.y() > center.y() + height)
        return false;

    // normalna do powierzchni w punkcie jest prostopad³a do stycznej.
    // Styczna to gradient fukncji
    // wzor na stozek to x^2 + z ^2 - tan^2 * y^2. Oczywiscie zakladajac ze stozek jest skierowany w strone osi Y
    // Gradient z tego to (2x, -2tan^2y, 2z), ale ze normalizujemy ten wektor, to bedzie
    // (x, -tan^2y, z)
    // Ale my bedziemy obliczac bez podnoszenia tan^2, bo tak
    // https://github.com/iceman201/RayTracing/tree/master
    vec3 hit_point_local = rec.p - center;
    // tan * sqrt (x^2 + z ^2) to jest odleglosc punktu od osi Y. Im wyzej tym mniejsza odleglosc, mniejszy promieñ.
    vec3 normal = vec3(hit_point_local.x(), tan * sqrt(hit_point_local.x() * hit_point_local.x() + hit_point_local.z() * hit_point_local.z()), hit_point_local.z());
    rec.set_face_normal(r, unit_vector(normal));

    rec.mat_ptr = mat;
    rec.mat_type = mat_type;

    return true;
}