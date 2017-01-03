---
title: Vector234
grammar_cjkRuby: true
grammar_flow: true
---

## Vector2, Vector3, Vector4
* 静态变量
	* down : Vector3(0, -1, 0)
	* left : Vector3(-1, 0, 0)
	* right : Vector3(1, 0, 0)
	* up : Vector3(0, 1, 0)
	* one : Vector3(1, 1, 1)
	* zero : Vector3(0, 0, 0)
	* back : Vector3(0, 0, -1)
	* forward : Vector3(0, 0, 1)
```csharp
Vector3 v3 = Vector3.right * 2;
```
* 成员变量
	* magnitude : 向量长度
	* normalized : 单位向量, 用来表示向量方向(x*x+y*y+z*z)
	* sqrMagnitude : 向量长度的平方
	* x, y, z, w
