0.Name
	.primitives : ͼԪ (��άģ���еĵ㡢�ߡ���ȵ�) 
			1.���ζ��㱻���ΪͼԪ���㣬�߶λ����Σ�
			2.Ȼ��ͼԪ���ϳ�ƬԪ�����ƬԪ��ת��Ϊ֡�����е��������ݡ�
	.Fragment : ƬԪ (���ص㣬�������ض�һЩλ�ð��������������ԡ�)
		1.��άͼ����ÿ���㶼��������ɫ����Ⱥ��������ݡ����õ�������Ϣ����һ��ƬԪ
		2.��դ��������ӳ��֮��ͼԪ��Ϣת��Ϊ������
	.Fragments : Ƭ��(������ͬ���Ե�һС������������)
	.HDD : Ӳ��
	.RAM : �ڴ�
	.VRAM : �Դ�
	.rendering primitives : ��ȾͼԪ
	.culling : �޳�
	.Vertex Shader : ������ɫ��
	.Geometry Shader : ������ɫ��
	.Tessellation Shader : ����ϸ����ɫ��
	.Fragment Shader : ƬԪ��ɫ��
	.Per-Primitive : ��ͼԪ
	.Per-Fragment : ��ƬԪ
	.Clipping : �ü�
	.NDC : Normalized Device Coordiates ��һ�����豸����(��������ת����βü�����ϵ��, ��͸�ӳ����õ�)
	.Screen Coordinates : ��Ļ����ϵ
	.Screen Mapping ��Ļӳ��
	.Raster : ��դ
	.Rasterization : ��դ��

1.��Ⱦ����
	0.��Ⱦ��ˮ�� :
		(start)�������� ->  
		(���ν׶�)������ɫ��(�������)(ͼԪ) -> ����ϸ����ɫ�� -> ������ɫ�� -> �ü� -> ��Ļӳ��(��Ļ����,z����,����,�ӽ�) ->
		(��դ�׶�)���������� -> �����α���(ƬԪ) -> ƬԪ��ɫ�� -> ��ƬԪ���� -> 
		(end) ��Ļͼ��
	1.Ӧ�ý׶�(Application Stage)(cpu)
		1.����
			1.����
				1.����.�����.��׵��.ģ��.��Դ.etc����
			2.������Ⱦ����, �����Ⱦ����
				1.�������޳�
			3.������Ⱦ״̬(ÿ��ģ��)
				1.����(��������ɫ,�߹ⷴ����ɫ)
				2.����
				3.shader...etc
		2.���
			1.��ȾͼԪ(rendering primitives)
				1.��, ��, ��� 
		3.ʵ�ֽ׶�
			1.���ݼ��ص��Դ�
			2.������Ⱦ״̬
				1.û�и�����Ⱦ״̬ǰ, ��������ʹ��ͬһ�� ��Ⱦ״̬
			3.����Draw Call
	2.���ν׶�(gpu)
		0.������ȾͼԪ, �����𶥵�, �����β���
		1.����
			1.��ȾͼԪ
		2.����
			1.��������任����Ļ����
		3.���
			1.��Ļ�ռ�Ķ�ά������Ϣ
				1.����
				2.���ֵ
				3.��ɫ...etc
		4.��ˮ��
			1.������ɫ��
				������λ : vertex
				ÿ��vertex�������һ�ζ�����ɫ��
				������ɫ�������Դ������������κζ���
				Ҳ�����Եõ�����Ͷ���֮��Ĺ�ϵ
				�����ٶȺܿ�
				�����������ģ�Ϳռ�ת������βü��ռ�(-1,-1,-1)(1,1,1)
				1.��ȫ�ɱ��
				2.����ռ�ת��
				3.������ɫ
				4.����ʵ�ֶ��㶯��
				5.��������-1, 1֮��, ���ж��㶼��һ����������, ��Χ��-1-1-1, 111֮��
			2.����ϸ����ɫ��
				1.��ѡ
				2.ϸ��ͼԪ
			3.������ɫ��
				1.ִ����ͼԪ����ɫ����
				2.���ڲ��������ͼԪ
			4.�ü�
				1.������
				
				2.�ü���the vertex that not inside camera, ���޳�ĳЩ����ͼԪ����Ƭ
					1.ʹ�òü�ƽ������ �ü�����
					2.���Ʋü�����ͼԪ�����滹�Ǳ���
			5.��Ļӳ��
				1.�������úͱ��
				2.��ͼԪ������(�������)ת������Ļ����ϵ
	3.��դ�׶�
		1.����
			1.��Ļ�ռ䶥����Ϣ
		2.���� 
			1.����ÿ��ͼԪ��������Щ����
			2.����������ɫ
			1.������Ķ�����Ϣ���в�ֵ(3�������3����ɫֵ����ֵ�õ�������ɫֵ)
			2.�����ش���
		3.���
			1.����ͼ��
		4.��ˮ��
			1.����������
				1.����3���α߽�����
			2.�����α���
				1.�ҳ��������θ��ǵ�����
				2.����3����������ֵ
				3.���ƬԪ����
			3.ƬԪ��ɫ��
				0.��ȫ�ɱ��
				1.Per-Fragment ��ɫ����
			4.��ƬԪ����
				0.���ɱ��, ������
				1.����
					1.�޸���ɫ
					2.��Ȼ���
					3.���etc
			
			
			