#include "include/cylinder.cuh"

__device__ bool cylinder::hit(const ray& r, interval ray_t, hit_record& rec, void* mat, MaterialType mat_type)
{
    vec3 oc = r.get_origin() - center; // presyniecie poczatku ukladu wspolrzednych do srodka cylindra
    // chce zrobic tak zeby ten walec sta³ wzd³u¿ osi y, czyli zeby sobie byl w gorze zwrocony.
    // rownanie to bedzie t^2(vx^2+vz^2) + 2t(px*vx + py*vz) +px^2 + pz^2 = r^2;
    float a = (r.get_direction().x() * r.get_direction().x()) + (r.get_direction().z() * r.get_direction().z());
    if (fabs(a) < 1e-8) return false;
    float b = 2 * (r.get_direction().x()*oc.x() + oc.z()*r.get_direction().z());
    float c = oc.x() * oc.x() + oc.z() * oc.z() - radius * radius;

    float delta = b * b - 4 * a * c;
    if (delta < 0.0f)
        return false;
    float root = (-b - sqrt(delta)) / (2.0f * a);

    float y0 = center.y() - height / 2;
    float y1 = center.y() + height / 2;

    float y = r.get_origin().y() + root * r.get_direction().y();
    if (!ray_t.surrounds(root) || y < y0 || y > y1)
    {
        root = (-b + sqrt(delta)) / (2.0f * a);
        y = r.get_origin().y() + root * r.get_direction().y();
        if (!ray_t.surrounds(root) || y < y0 || y > y1)
        {
            return false;
        }
    }

    rec.t = root;
    rec.p = r.at(rec.t);
    vec3 outward_normal = vec3(rec.p.x() - center.x(), 0.0f, rec.p.z() - center.z());
    rec.set_face_normal(r, outward_normal / outward_normal.length());
    rec.mat_ptr = mat;
    rec.mat_type = mat_type;

    return true;
}