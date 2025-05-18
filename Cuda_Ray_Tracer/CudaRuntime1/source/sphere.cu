#include "include/sphere.cuh"

__device__ sphere::sphere(const point3& center, float radius)
    : m_center(center), m_radius(radius) {
}

__device__ bool sphere::hit(const ray& r, interval ray_t, hit_record& rec, void* mat, MaterialType mat_type){
    if (mat == nullptr)
    {
        return false;
    }
    vec3 oc = m_center - r.get_origin();
    float a = r.get_direction().length_squared(); // == dot(r.get_direction(), r.get_direction());
    float h = dot(r.get_direction(), oc); //auto b = 2.0f * dot(oc, r.get_direction());
    float c = oc.length_squared() - m_radius * m_radius; // oc.lengtj_squared() == dot(oc, oc);
    float delta = h * h - a * c; //auto delta = b * b - 4 * a * c;
    if (delta < 0)
    {
        return false;
    }
    float sqrtDelta = sqrt(delta);
    // if root is not in acceptable ranage, return false
    float root = (h - sqrtDelta) / a;
    if (!ray_t.surrounds(root)) {
        root = (h + sqrtDelta) / a;
        if (!ray_t.surrounds(root))
            return false;
    }

    rec.t = root;
    rec.p = r.at(rec.t);
    rec.normal = (rec.p - m_center) / m_radius;
    vec3 outward_normal = (rec.p - m_center) / m_radius;
    rec.set_face_normal(r, outward_normal);
    rec.mat_ptr = mat;
    rec.mat_type = mat_type;

    return true;
}
