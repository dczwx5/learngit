0.name : 
	.normalized vector : 归一化向量, 单位向量
	.normalized : 归一化
	.点积/内积 : dot product/inner product
	.叉积/外积 : cross product/outer product
0.向量用于描述位移
	vp0p1 = p1 - p0
0.点
	1.和向量的表示方式一样, 意义不同
	2.从0点出发, 指向点a, 可以表示一个向量
0.标量
1.向量a -> 左边为尾，起点, 右边为头，终点
2.向量加法
	1.v1+v2 = v1的起点指向v2的终点的向量v3
	Vector3 v1, v2, v3;
	v3 = v1+v2 = (v1.x+v2.x, v1.y+v2.y, v1.z+v1.z);
2.向量减法
	2.v1-v2 = v2的起点指向v1的起点的向量v3
	Vector3 v1, v2, v3;
	v3 = v1-v2 = (v1.x-v2.x, v1.y-v2.y, v1.z-v1.z);
2.向量乘标量
	1.v1*3 = 放大3倍
	2.v1*-3 = 放大3倍, 反向量
	Vector3 v1;
	v1*3 = (v1.x*3, v1.y*3, v1.z*3);
3.点a相对于点b的位移
	1.a-b = v = b点指向a点的向量
	2.谁减谁是个问题
	*.两点相减, 可以得到点之间的向量关系
4.向量模
	1.向量长度
	2.v = (x, y), len*len = x*x + y*y
5.单位向量
	1.模为1的向量
	2.很多情况, 并不关心向量的长度, 因此都会转换为单位向量
	3.也称归一化向量 : normalized vector
	Vector3 v1, vNormal;
	vNormal = v1/v1.length = v1/Math.sqrt(v1.x*v1.x + v1.y*v1.y + v1.z*v1.z);
6.点积
	0.运算结算是一个投影长度
		光照照到一个向量到另一个向量的投影(影子)
		结果
			负数 : 夹角大于90度
			0 : 90度
			正数 : 夹角小于90度(正面?)
	0.重点
		v1.v2 = cos (v1,v2单 位向量)
		角度 = arcos(v1.v2)
	1.公式 : 
		1.v1.v2 = (v1.x, v1.y, v1.z).(v2.x, v2.y, v2.z) = v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
		2.v1.v2 = v1.len*v2.len*cos(v1和v2的夹角) 
		3.如果v1,v2是单位向量
			* v1.v2 = cos;
	2.满足乘法交换律
	3.用于投影
	4.点积值
		1.小于90度 ,cos>0
		2.等于90度, cos=0
		3.大于90度, cos<0;
	5.角度
		角度 = arcos(v1.v2);(v1,v2是单位向量) // arcos 反余弦
		可以得到向量之间的夹角
		角度 = dot(v1.v2)
		// 根据点积算角度
		public float getAngleBy2Vecotr(Vector3 v1, Vector3 v2) {
			float fDotValue = dot(v1, v2);
			float fAngleValue = arcos(fDotValue);
			return fAngleValue;
		}
		
	6.特性
		1.可结合标量乘法
			(k*v1).v2 = v1.(v2*k)=k*(v1.v2)
		2.可结合向量加减法
			v1.(v2+vc) = v1.v2 + v1.vc;
		3.向量与本身点积分 ，结果为模的平方
			v1.v1 = v1.len*v1.len
	7.向量的方向
		1.取小于180度的角
		2.或向量从相同的点出发(向量其实可以不从同一个点出发。但是要可以放到一个点上，然后是正常的)
	8.点在摄像机的正背面
		// Vector3 pCamera; // 摄像机点
		// Vector3 pP0, pP1, pP2; // p0->p1->p2 三角形逆时针
		public bool IsTriangleInSide(Vector3 pP0, Vector3 pP1, Vector3 pP2, Vector3 pCamera) {
			Vector3 vU, vV, vN; // 
			vU = pP1 - pP0; // 向量方向和点的顺序相同, 这里是逆时针
			vV = pP2 - pP1;
			vN = Cross(vU, vV); // 法向量, 叉乘
			Vector3 vCamera; // 三角形p0p1p2上任意点到摄像机的向量
			vCamera = pCamera - pP0; // 
			float fDot = dot(vCamera, vN);
			bool isBack = fDot < 0; // 背面
			return !isBack;
		} 
		
		
7.叉乘
	0.结果
		1.v1 X v2 = v3 = 垂直于v1,v2(组成的面)的向量
		2.(v1 X v2).length = v1.len*v2.len*sin; // v1和v2组成的平等四边形的面积
	1.方向判定 (v1xv2的长度)
		1.右手坐标系
			1.右手半握，大拇指垂直向上，四指右向量a握向b，大拇指的方向就是叉积的方向
		2.左手坐系
		
			1.左手半握，大拇指垂直向上，四指右向量a握向b，大拇指的方向就是叉积的方向
		3.方向
			1：通过结果的正负判断两矢量之间的顺逆时针关系
				若 a x b > 0表示a在b的顺时针方向上 ->a在b的右边 > 0
				若 a x b < 0表示a在b的逆时针方向上 ->a在b的左边 < 0
				若 a x b == 0表示a在b共线，但不确定方向是否相同
	2.应用 
		1.判断a在b的哪个方向上
		2.判断一个点在一条直线的哪一侧
		3.判断点是否在线段上(先判断是否共线, 再判断是否在其上)
		4.判断两直线是否相交(不共线)
		5.判断点是否在三角形内
			// 沿着三角形的边按顺时针方向走，判断该点是否在每条边的右边（这可以通过叉乘判断），
			// 如果该点在每条边的右边，则在三角形内，否则在三角形外。
			public bool isPointInTriangle(Vector3 t, Vector3 pP0, Vector3 pP1, Vector3 pP2) {
				Vector3 vp0t = t - pP0;
				Vector3 vp0p1 = pP1 - pP0;
				bool isT2Left = ifLeft(vtp2, vp0p1);
				
				Vector3 vp1t = t - pP1;
				Vector3 vp1p2 = pP2 - pP1;
				bool isT0Left(vtp0, vp1p2);
				
				Vector3 vp2t = t - pP2;
				Vector3 vp2p0 = pP0 - pP2;
				bool isT1Left(vtp1, vp2p0);
				if (isT2Left && isT1Left && isT0Left || (!isT0Left && !isT1Left && !isT2Left) {
					return true;
				} 
				return false; 
			}
			// v1 是否在 v2 左边
			public bool isLeft(Vector3 v1, Vector3 v2) {
				float fAngle = arcos(dot(v1, v2));
				float fSin = sin(fAngle); // v1.len * v2.len * sin // 这里只要判断正负。所以不用长度
				return fSin < 0;
			}
			
	x.法则
		1.反交换律：a×b= -b×a
		2.加法的分配律：a× (b+c) =a×b+a×c
		3.与标量乘法兼容：(ra) ×b=a× (rb) = r(a×b)
		4.不满足结合律，但满足雅可比恒等式：a× (b×c) +b× (c×a) +c× (a×b) =0
		6.两个非零向量a和b平行，当且仅当a×b=0
		7.叉积不满足交换律 axb != bxa
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
