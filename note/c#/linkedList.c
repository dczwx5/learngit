static void Main(string[] args)
{
	// ����
	LinkedList<int> list = new LinkedList<int>();

	list.AddLast(1);
	list.AddLast(2);
	list.AddLast(3);
	list.AddLast(40);
	list.AddLast(25);

	// ����
	foreach (int value in list)
	{
		Console.WriteLine("value : {0}  ", value);
	}
	Console.WriteLine();

	// ���� 2
	// Node
	LinkedListNode<int> node = list.First;
	while (true)
	{
		if (null == node)
		{
			break;
		}
		Console.WriteLine("value : {0} ", node.Value);

		node = node.Next;
	}
	Console.ReadLine();
}