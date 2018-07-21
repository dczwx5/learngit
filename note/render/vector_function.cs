public static Vector3 ZERO = new Vector3(0.0, 0.0, 0.0);
public static Vector3 ONE = new Vector3(1.0, 1.0, 1.0);
public static Vector3 X_AXIS = new Vector3(1.0, 0.0, 0.0);
public static Vector3 Y_AXIS = new Vector3(0.0, 1.0, 0.0);
public static Vector3 Z_AXIS = new Vector3(0.0, 0.0, 1.0);

// 求模平方
public float Length2(Vector3 v) {
	return v.x*v.x + v.y*v.y + v.z*v.z;
}

public float Length(Vector3 v) {
	return Math.sqrt(length2(v));
}
// 归一化
public Vector3 Normalize(Vector3 v) {
	float len = length(v);
	if (len > Math.EPSILON) {
		v.x /= len; v.y /= len; v.z /= len;
	}
	return v;
}

// 叉乘
public Vector3 Cross(Vector3 v1, Vector3 v2) {
	float fx = v1.y * v2.z - v1.z * v2.y;
	float fy = v1.z * v2.x - v1.x * v2.z;
	float fz = v1.x * v2.y - v1.y * v2.x;
	return new Vector3(fx, fy, fz);
}

// 点积
public float Dot(Vector3 v1, Vector3 v2) {
	float ret = v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
}

//======================================应用=============================================
// 点是否在立方体
public bool IsVertexIntersectAABB(float x, float y, float z, float minRectX, float minRectY, float minRectZ, float maxRectX, float maxRectY, float maxRectZ) {
	if (x < minRectX || x > maxRectX) return false;
	if (y < minRectY || y > maxRectY) return false;
	if (z < minRectZ || z > maxRectZ) return false;
	return true;
}
// 线段是否在立方体内
public bool IsLineInstersectAABB(float x1, float y1, float z1, float x2, float y2, float z2, 
								float minRectX, float minRectY, float minRectZ, float maxRectX, float maxRectY, float maxRectZ) {
	// 如果线段两端在立方体内， 则ok
	if (IsVertexIntersectAABB(x1, y1, z1, minRectX, minRectY, minRectZ, maxRectX, maxRectY, maxRectZ)) return true;
	if (IsVertexIntersectAABB(x2, y2, z2, minRectX, minRectY, minRectZ, maxRectX, maxRectY, maxRectZ)) return true;
	
	// XY Plane 线段与两个XY面判断相交
	if (IsLineInterectAARectXY(x1, y1, z1, x2, y2, z2, minRectX, minRectY, maxRectX, maxRectY, minRectZ)) return true;
	if (IsLineInterectAARectXY(x1, y1, z1, x2, y2, z2, minRectX, minRectY, maxRectX, maxRectY, maxRectZ)) return true;
	
	// YZ Plane
	if (IsLineIntersectAARectYZ(x1, y1, z1, x2, y2, z2, minRectY, minRectZ, maxRectY, maxRectZ, minRectX)) return true;
	if (IsLineIntersectAARectYZ(x1, y1, z1, x2, y2, z2, minRectY, minRectZ, maxRectY, maxRectZ, maxRectX)) return true;
	
	// XZ Plane
	if (IsLineIntersectAARectXZ(x1, y1, z1, x2, y2, z2, minRectX, minRectZ, maxRectx, maxRectZ, minRectY)) return true; 
	if (IsLineIntersectAARectXZ(x1, y1, z1, x2, y2, z2, minRectX, minRectZ, maxRectx, maxRectZ, maxRectY)) return true; 

	return false;
}
public bool IsLineInterectAARectXY(float x1, float y1, float z1, float x2, float y2, float z2, 
								float minRectX, float minRectY, float maxRectX, float maxRectY, float rectZ) {
	float dz = z2 - z1;
	if (abs(dz) < EPSILON) {
		// 线段与XY面平行
		dz = z1 - rectZ;
		if (abs(dz) < EPSILON) {
			// 线段与XY平行相同Z, 线段与XY平面于相同的面上(但不一定相交)
			if (D2_IsLineIntersectAABB(x1, y1, x2, y2, minRectX, minRectY, maxRectX, maxRectY)) return true;
		}
		return false;
	}
	
	// z1,z2同时大于或小于rectZ, 说明线段不会与平面 有交点
	if (z1 < rectZ) {
		if (z2 < rectZ) return false;
	} else if (z1 > rectZ) {
		if (z2 > rectZ) return false;
	}
	
	// 能到这里, 说明绑段与XY所在的无限平面上肯定会有交点。但是交点不一定在XY面上
	// 求交点, 使用线性比 (交点(x, y, rectZ))
	float t = (rectZ - z1) / dz; // (rectZ - z1)/(z2 - z1)
	float x = x1 + (x2 - x1) * t; // (x-x1)/(x2-x1) = t
	float y = y1 + (y2 - y1) * t; // (y-y1)/(y2-y1) = t
	
	// 得出的交点是否在XY面上
	if (x < minRectX || x > maxRectX) return false;
	if (y < minRectY || y > maxRectY) return false;
	
	return true;
}

public bool IsLineInterectAARectXZ(float x1, float y1, float z1, float x2, float y2, float z2, 
								float minRectX, float minRectZ, float maxRectX, float maxRectZ, float rectY) {
	float dy = y2 - y1;
	if (abs(dy) < EPSILON) {
		dy = y1 - rectY;
		if (abs(dy) < EPSILON) {
			if (D2_IsLineIntersectAABB(x1, y1, x2, y2, minRectX, minRectZ, maxRectX, maxRectZ)) return true;
		}
		return false;
	}
	
	if (y1 < rectY) {
		if (y2 < rectY) return false;
	} else if (y1 > rectY) {
		if (y2 > rectY) return false;
	}
	
	float t = (rectY - y1) / dy; 
	float x = x1 + (x2 - x1) * t;
	float Z = z1 + (z2 - z1) * t;
	
	if (x < minRectX || x > maxRectX) return false;
	if (z < minRectZ || z > maxRectZ) return false;
	
	return true;
}

public bool IsLineInterectAARectYZ(float x1, float y1, float z1, float x2, float y2, float z2, 
								float minRectY, float minRectZ, float maxRectY, float maxRectZ, float rectX) {
	float dx = x2 - x1;
	if (abs(dx) < EPSILON) {
		dx = x1 - rectX;
		if (abs(dx) < EPSILON) {
			if (D2_IsLineIntersectAABB(x1, y1, x2, y2, minRectY, minRectZ, maxRectY, maxRectZ)) return true;
		}
		return false;
	}
	
	if (x1 < rectX) {
		if (x2 < rectX) return false;
	} else if (x1 > rectX) {
		if (x2 > rectX) return false;
	}
	
	float t = (rectX - x1) / dx; 
	float y = y1 + (y2 - y1) * t; 
	float Z = z1 + (z2 - z1) * t;
	
	if (y < minRectY || y > maxRectY) return false;
	if (z < minRectZ || z > maxRectZ) return false;
	
	return true;
}
// ================================================================================2D================================================================================
// 叉乘求两向量叉乘积
// v1 = (x2 - x1, y2 - y1)
// v2 = (x3 - x1, y3 - y1);
// 检查三角形顶点顺序
public int CheckTriangleClockDirection(float x1, float y1, float x2, float y2, float x3, float y3) {
	float fValue = (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1); // v1x * v2y - v2x * v1y;
	if (fValue > 0) return -1; // counter clockwise;
	else if (fValue < 0.0) return 1; // clockwise;
	else return 0; // line
}
// 两线段是否相交 line1, line2(l1, l2)
// l1(x2-x1, y2-y1) 与 从l1一个顶点指向 l2(x4-x3, y4-y3) 两个顶点组成的向量做叉乘, 如果两个向量都在同边, 说明不相交
// 反过来, 用l2 和 l1做上面想同的操作
public D2_IsLineIntersectLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
	// x1,y1 为起点, 两条向量 : (x2-x1, y2-y1), (x3-x1, y3-y1)
	int test1 = CheckTriangleClockDirection(x1, y1, x2, y2, x3, y3);
	int test2 = CheckTriangleClockDirection(x1, y1, x2, y2, x4, y4);
	if (test1 != test2) {
		// 反过来再检测一次
		test1 = CheckTriangleClockDirection(x3, y3, x4, y4, x1, y1);
		test2 = CheckTriangleClockDirection(x3, y3, x4, y4, x2, y2);
		if (test1 != test2) return true;
	}
	return false;
}
// 点是否在矩形内
public bool D2_IsVertexIntersectAARect(float x, float y, float minRectX, float minRectY, float maxRectX, float maxRectY) {
	if (x1x< minRectX || x > maxRectX) return false;
	if (y < minRectY || y > maxRectY) return false;
	return true;
}
// 线段是否在矩形内
public bool D2_IsLineIntersectAABB(float x1, float y1, float x2, float y2, float minRectX, float minRectY, float maxRectX, float maxRectY) {
	// 线段两端是否在矩形内
	if (D2_IsVertexIntersectAARect(x1, y1, minRectX, minRectY, maxRectX, maxRectY)) return true;
	if (D2_IsVertexIntersectAARect(x2, y2, minRectX, minRectY, maxRectX, maxRectY)) return true;
	// 线段与矩形两条对角线有没有交点
	if (D2_IsLineIntersectLine(x1, y1, x2, y2, minRectX, minRectY, maxRectX, maxRectY)) return true;
	if (D2_IsLineIntersectLine(x1, y1, x2, y2, minRectX, maxRectY, maxRectX, minRectY)) return true;
	return false;
}









