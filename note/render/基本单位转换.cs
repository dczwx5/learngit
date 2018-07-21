public float PI = 3.1415926;
public float PI_OVER2 = PI*0.5;
public float RADIAN_PER_DEGREE = 180/PI; // 1�Ƕȶ��ٻ��� 57.29578
public float DEGREE_PER_RADIAN = PI/180; // 1���ȶ��ٽǶ� 0.017453292
public float EPSILON = 0.00001;

// 360�� == 2�� �� == 3.1415926(����)
// �Ƕ�ת����
public float DegreeToRadian(float degree) {
	return degree * DEGREE_PER_RADIAN; // ��/180 == 0.017453292
}

// ����ת�Ƕ�
public float RadianToDegree(float radian) {
	return radian * RADIAN_PER_DEGREE; // 180/�� == 57.29578
}

public float abs(float v) { return v >= 0 ? v : -v; }
public float max(float v1, float v2) { return v1 > v2 ? v1 : v2; }
public float min(float v1, float v2) { return v1 < v2 ? v1 : v2; }

// value�Ƿ�Ϊ0
public bool IsZero(float v) { return abs(v) < EPSILON; }
// v1�Ƿ����v2
public bool IsNear(float v1, float v2) {abs(v1-v2) < EPSILON; }

// sin cos tan �� ���յ���radian, �������ǽǶ�, ��Ҫ��תΪ����
public float SinDegree(degree) {
	float randian = DegreeToRadian(degree);
	float ret = sin(radian);
	return ret;
}

// ������ɵ�����
public Vector3 GetVectorByPoint(Point p1, Point p2) {
	Vector3 v = new Vector3();
	v.x = p2.x - p1.x;
	v.y = p2.y - p1.y;
	v.z = p2.z - p1.z;
	return v;
}