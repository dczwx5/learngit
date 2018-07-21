public float PI = 3.1415926;
public float PI_OVER2 = PI*0.5;
public float RADIAN_PER_DEGREE = 180/PI; // 1角度多少弧度 57.29578
public float DEGREE_PER_RADIAN = PI/180; // 1弧度多少角度 0.017453292
public float EPSILON = 0.00001;

// 360度 == 2π π == 3.1415926(弧度)
// 角度转弧度
public float DegreeToRadian(float degree) {
	return degree * DEGREE_PER_RADIAN; // π/180 == 0.017453292
}

// 弧度转角度
public float RadianToDegree(float radian) {
	return radian * RADIAN_PER_DEGREE; // 180/π == 57.29578
}

public float abs(float v) { return v >= 0 ? v : -v; }
public float max(float v1, float v2) { return v1 > v2 ? v1 : v2; }
public float min(float v1, float v2) { return v1 < v2 ? v1 : v2; }

// value是否为0
public bool IsZero(float v) { return abs(v) < EPSILON; }
// v1是否等于v2
public bool IsNear(float v1, float v2) {abs(v1-v2) < EPSILON; }

// sin cos tan 等 接收的是radian, 因此如果是角度, 需要先转为弧度
public float SinDegree(degree) {
	float randian = DegreeToRadian(degree);
	float ret = sin(radian);
	return ret;
}

// 两点组成的向量
public Vector3 GetVectorByPoint(Point p1, Point p2) {
	Vector3 v = new Vector3();
	v.x = p2.x - p1.x;
	v.y = p2.y - p1.y;
	v.z = p2.z - p1.z;
	return v;
}