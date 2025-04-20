#include "include/sphere.cuh"

sphere::sphere(const point3& center, float radius)
	: m_center(center), m_radius(std::fmax(0,radius)) {
}

bool sphere::hit(const ray& r, float ray_tmin, float ray_tmax, hit_record& rec) const {
	vec3 oc = m_center - r.get_origin();
	auto a = r.get_direction().length_squared(); // == dot(r.get_direction(), r.get_direction());
	auto h = dot(r.get_direction(), oc); //auto b = 2.0f * dot(oc, r.get_direction());
	auto c = oc.length_squared() - m_radius * m_radius; // oc.lengtj_squared() == dot(oc, oc);
	//delta
	auto delta = h * h - a * c; //auto delta = b * b - 4 * a * c;
	if (delta < 0)
	{
		return false;
	}
	
	auto sqrtDelta = std::sqrt(delta);

	// if root is not in acceptable renage, return false
	auto root = (h - sqrtDelta) / a;
	if (root <= ray_tmin || root >= ray_tmax) {
		root = (h + sqrtDelta) / a;
		if (root <= ray_tmin || root >= ray_tmax)
			return false;
	}

	rec.t = root;
	rec.p = r.at(rec.t);
	rec.normal = (rec.p - m_center) / m_radius;
	vec3 outward_normal = (rec.p - m_center) / m_radius;
	rec.set_face_normal(r, outward_normal);

	return true;
}