---
title: 基本数据结构
grammar_cjkRuby: true
---

[TOC]
## 序
- 数据结构
	- Array : (无装箱)
	- ArrayList : (存无装箱, 插入, 读取有装拆箱)
	- List<T> : (说无装箱)
	- LinkedList<T>
	- Stack
	- Queue
	- HashTable
	- Dictionary<T>
	- HashSet<T>
	- SortedSet<T>
## 数组
* 读快
* 插入,删除引起重新申请内存空间, 与移动数据
* 查找慢
* 连续内存
### Array
* 特性
	* 连续存储内存
	* 元素是相同类型
	* 索引访问
	* 存于托管堆中
	* 插入,删除低效
	* 必须指定长度
	* 不会引起装箱
```csharp
// define
int[] arr = new int[5];
```
### ArrayList
* 特性
	* 由于元素类型为Object, 因此在存值类型时会导致装箱
	* 不必指定长度
	* 长度动态增长,缩减
	* 元素可以不同类型
	* 不安全类型
	* 存值类型时不产生装箱操作?
	* 插入值类型会发生装箱操作(频繁读写导致性能下降)
	* 索引取值时发生拆箱操作(频繁读写导致性能下降)
```csharp
ArrayList list = new ArrayList();
list.Add(12); // 装箱
list.Add("abc");
```
### List<T>
* 特性
	* 泛型无需运行时类型检查(高性能)
	* 泛型数组
	* 长度可变
	* 安全类型
	* 内存使用Array实现
	* 无装箱拆箱操作
	* 快速访问
```csharp
List<int> list = new List<int>();
list.Add(1);
list[0] = 2;
list.RemoveAt(0);
```
## 链表
* 查找慢
* 插入,删除快, 不会引起元素移动与重新申请整块内存
* 空间不连续
* 适用于元素数量不固定, 且需要经常增删元素
### LinkedList<T>
```csharp
LinkedList<int> link = new LinkList<int>();
link.AddFirst(100); // 添加到第一个节点
LinkedListNode<int> node = link.First; // 获得第一个节点, 并存于node
Link.RemoveFirst(); // 删除第一个节点
Link.AddLast(1000); // 添加到最后节点
Link.RemoveLast(); // 删除最后一个节点
Link.AddLast(200); // 添加到最后
node = link.FindLast(200); // 从最后开始查找
link.AddAfter(node, 300); // 在node结节后添加一个新元素
node = link.Find(200); // 找到节点
link.AddBefore(node, 400); // 在node结节前添加新节点
```

### LinkedListNode<T>
```csharp
LinkedList<int> list;
... // 假设list已有数据
node = list.Last; // 应该有这个属性(Last)
node = node.Previous; // Node的前一个节点
node = node.Next; // node的下一个节点
link == node.List; // node.List即节点所在的链表
int v = node.Value;
```

## Stack
## Queue
## HashTable
## Dictionary<T>
## HashSet<T>
## SortedSet<T>

