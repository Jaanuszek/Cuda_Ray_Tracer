#include "include/sphere.cuh"

__device__ sphere::sphere(const point3& center, float radius)
    : m_center(center), m_radius(radius) {
}

__device__ bool sphere::hit(const ray& r, interval ray_t, hit_record& rec, void* mat, MaterialType mat_type){
    //printf("========= sphere0\n");
    if (mat == nullptr)
    {
        //printf("====== nullptr in sphere\n");
        return false;
    }
    //printf("========= sphere1\n");
    vec3 oc = m_center - r.get_origin();
    //printf("========= sphere2\n");
    float a = r.get_direction().length_squared(); // == dot(r.get_direction(), r.get_direction());
    //printf("========= sphere3\n");
    float h = dot(r.get_direction(), oc); //auto b = 2.0f * dot(oc, r.get_direction());
    //printf("========= sphere4\n");
    float c = oc.length_squared() - m_radius * m_radius; // oc.lengtj_squared() == dot(oc, oc);
    //printf("========= sphere5\n");
    float delta = h * h - a * c; //auto delta = b * b - 4 * a * c;
    if (delta < 0)
    {
        return false;
    }
    //printf("========= sphere6\n");
    float sqrtDelta = sqrt(delta);
    //printf("========= sphere7\n");
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
    //printf("========= sphere8\n");
    //printf("========= sphere ptrr %p\n", mat);
    rec.mat_ptr = mat;
    rec.mat_type = mat_type;
    //printf("========= sphere9\n");
    //printf("=======10 ptr %p\n", rec.mat_ptr);

    return true;
}

__device__ void sphere::tempFunc()
{
    //printf("sphere\n");
}