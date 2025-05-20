#include "include/box.cuh"

__device__ vec3 box::calculateNormals(const vec3& p)
{
    const float epsilon = 1e-4f;
    vec3 hit_point = p;
    vec3 normal;
    if (fabs(hit_point.x() - bounds[0].x()) < epsilon)
        normal = vec3(-1, 0, 0);
    else if (fabs(hit_point.x() - bounds[1].x()) < epsilon)
        normal = vec3(1, 0, 0);
    else if (fabs(hit_point.y() - bounds[0].y()) < epsilon)
        normal = vec3(0, -1, 0);
    else if (fabs(hit_point.y() - bounds[1].y()) < epsilon)
        normal = vec3(0, 1, 0);
    else if (fabs(hit_point.z() - bounds[0].z()) < epsilon)
        normal = vec3(0, 0, -1);
    else
        normal = vec3(0, 0, 1);
    return normal;
}

__device__ bool box::hit(const ray& r, interval ray_t, hit_record& rec, void* mat, MaterialType mat_type)
{
    float tmin, tmax, tymin, tymax, tzmin, tzmax;

    tmin = (bounds[r.sign[0]].x() - r.get_origin().x()) * r.invdir.x();
    tmax = (bounds[1 - r.sign[0]].x() - r.get_origin().x()) * r.invdir.x();
    tymin = (bounds[r.sign[1]].y() - r.get_origin().y()) * r.invdir.y();
    tymax = (bounds[1 - r.sign[1]].y() - r.get_origin().y()) * r.invdir.y();
    tzmin = (bounds[r.sign[2]].z() - r.get_origin().z()) * r.invdir.z();
    tzmax = (bounds[1 - r.sign[2]].z() - r.get_origin().z()) * r.invdir.z();

    if ((tmin > tymax) || (tymin > tmax))
        return false;

    if (tymin > tmin)
        tmin = tymin;
    if (tymax < tmax)
        tmax = tymax;

    if ((tmin > tzmax) || (tzmin > tmax))
        return false;

    if (tzmin > tmin)
        tmin = tzmin;
    if (tzmax < tmax)
        tmax = tzmax;

    rec.t = tmin;
    if (!ray_t.contains(tmin))
        return false;

    rec.p = r.at(rec.t);

    rec.set_face_normal(r, calculateNormals(rec.p));
    rec.mat_ptr = mat;
    rec.mat_type = mat_type;

    return true;
}