0.name : 
	.normalized vector : ��һ������, ��λ����
	.normalized : ��һ��
	.���/�ڻ� : dot product/inner product
	.���/��� : cross product/outer product
0.������������λ��
	vp0p1 = p1 - p0
0.��
	1.�������ı�ʾ��ʽһ��, ���岻ͬ
	2.��0�����, ָ���a, ���Ա�ʾһ������
0.����
1.����a -> ���Ϊβ�����, �ұ�Ϊͷ���յ�
2.�����ӷ�
	1.v1+v2 = v1�����ָ��v2���յ������v3
	Vector3 v1, v2, v3;
	v3 = v1+v2 = (v1.x+v2.x, v1.y+v2.y, v1.z+v1.z);
2.��������
	2.v1-v2 = v2�����ָ��v1����������v3
	Vector3 v1, v2, v3;
	v3 = v1-v2 = (v1.x-v2.x, v1.y-v2.y, v1.z-v1.z);
2.�����˱���
	1.v1*3 = �Ŵ�3��
	2.v1*-3 = �Ŵ�3��, ������
	Vector3 v1;
	v1*3 = (v1.x*3, v1.y*3, v1.z*3);
3.��a����ڵ�b��λ��
	1.a-b = v = b��ָ��a�������
	2.˭��˭�Ǹ�����
	*.�������, ���Եõ���֮���������ϵ
4.����ģ
	1.��������
	2.v = (x, y), len*len = x*x + y*y
5.��λ����
	1.ģΪ1������
	2.�ܶ����, �������������ĳ���, ��˶���ת��Ϊ��λ����
	3.Ҳ�ƹ�һ������ : normalized vector
	Vector3 v1, vNormal;
	vNormal = v1/v1.length = v1/Math.sqrt(v1.x*v1.x + v1.y*v1.y + v1.z*v1.z);
6.���
	0.���������һ��ͶӰ����
		�����յ�һ����������һ��������ͶӰ(Ӱ��)
		���
			���� : �нǴ���90��
			0 : 90��
			���� : �н�С��90��(����?)
	0.�ص�
		v1.v2 = cos (v1,v2�� λ����)
		�Ƕ� = arcos(v1.v2)
	1.��ʽ : 
		1.v1.v2 = (v1.x, v1.y, v1.z).(v2.x, v2.y, v2.z) = v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
		2.v1.v2 = v1.len*v2.len*cos(v1��v2�ļн�) 
		3.���v1,v2�ǵ�λ����
			* v1.v2 = cos;
	2.����˷�������
	3.����ͶӰ
	4.���ֵ
		1.С��90�� ,cos>0
		2.����90��, cos=0
		3.����90��, cos<0;
	5.�Ƕ�
		�Ƕ� = arcos(v1.v2);(v1,v2�ǵ�λ����) // arcos ������
		���Եõ�����֮��ļн�
		�Ƕ� = dot(v1.v2)
		// ���ݵ����Ƕ�
		public float getAngleBy2Vecotr(Vector3 v1, Vector3 v2) {
			float fDotValue = dot(v1, v2);
			float fAngleValue = arcos(fDotValue);
			return fAngleValue;
		}
		
	6.����
		1.�ɽ�ϱ����˷�
			(k*v1).v2 = v1.(v2*k)=k*(v1.v2)
		2.�ɽ�������Ӽ���
			v1.(v2+vc) = v1.v2 + v1.vc;
		3.�����뱾������ �����Ϊģ��ƽ��
			v1.v1 = v1.len*v1.len
	7.�����ķ���
		1.ȡС��180�ȵĽ�
		2.����������ͬ�ĵ����(������ʵ���Բ���ͬһ�������������Ҫ���Էŵ�һ�����ϣ�Ȼ����������)
	8.�����������������
		// Vector3 pCamera; // �������
		// Vector3 pP0, pP1, pP2; // p0->p1->p2 ��������ʱ��
		public bool IsTriangleInSide(Vector3 pP0, Vector3 pP1, Vector3 pP2, Vector3 pCamera) {
			Vector3 vU, vV, vN; // 
			vU = pP1 - pP0; // ��������͵��˳����ͬ, ��������ʱ��
			vV = pP2 - pP1;
			vN = Cross(vU, vV); // ������, ���
			Vector3 vCamera; // ������p0p1p2������㵽�����������
			vCamera = pCamera - pP0; // 
			float fDot = dot(vCamera, vN);
			bool isBack = fDot < 0; // ����
			return !isBack;
		} 
		
		
7.���
	0.���
		1.v1 X v2 = v3 = ��ֱ��v1,v2(��ɵ���)������
		2.(v1 X v2).length = v1.len*v2.len*sin; // v1��v2��ɵ�ƽ���ı��ε����
	1.�����ж� (v1xv2�ĳ���)
		1.��������ϵ
			1.���ְ��գ���Ĵָ��ֱ���ϣ���ָ������a����b����Ĵָ�ķ�����ǲ���ķ���
		2.������ϵ
		
			1.���ְ��գ���Ĵָ��ֱ���ϣ���ָ������a����b����Ĵָ�ķ�����ǲ���ķ���
		3.����
			1��ͨ������������ж���ʸ��֮���˳��ʱ���ϵ
				�� a x b > 0��ʾa��b��˳ʱ�뷽���� ->a��b���ұ� > 0
				�� a x b < 0��ʾa��b����ʱ�뷽���� ->a��b����� < 0
				�� a x b == 0��ʾa��b���ߣ�����ȷ�������Ƿ���ͬ
	2.Ӧ�� 
		1.�ж�a��b���ĸ�������
		2.�ж�һ������һ��ֱ�ߵ���һ��
		3.�жϵ��Ƿ����߶���(���ж��Ƿ���, ���ж��Ƿ�������)
		4.�ж���ֱ���Ƿ��ཻ(������)
		5.�жϵ��Ƿ�����������
			// ���������εı߰�˳ʱ�뷽���ߣ��жϸõ��Ƿ���ÿ���ߵ��ұߣ������ͨ������жϣ���
			// ����õ���ÿ���ߵ��ұߣ������������ڣ��������������⡣
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
			// v1 �Ƿ��� v2 ���
			public bool isLeft(Vector3 v1, Vector3 v2) {
				float fAngle = arcos(dot(v1, v2));
				float fSin = sin(fAngle); // v1.len * v2.len * sin // ����ֻҪ�ж����������Բ��ó���
				return fSin < 0;
			}
			
	x.����
		1.�������ɣ�a��b= -b��a
		2.�ӷ��ķ����ɣ�a�� (b+c) =a��b+a��c
		3.������˷����ݣ�(ra) ��b=a�� (rb) = r(a��b)
		4.���������ɣ��������ſɱȺ��ʽ��a�� (b��c) +b�� (c��a) +c�� (a��b) =0
		6.������������a��bƽ�У����ҽ���a��b=0
		7.��������㽻���� axb != bxa
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
