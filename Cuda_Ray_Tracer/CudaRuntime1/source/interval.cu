#include "include/interval.cuh"

const interval interval::empty = interval(+constants::infinity, -constants::infinity);
const interval interval::universe = interval(-constants::infinity, +constants::infinity);