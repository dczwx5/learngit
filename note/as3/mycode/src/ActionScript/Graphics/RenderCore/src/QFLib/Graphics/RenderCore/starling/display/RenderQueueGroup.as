package QFLib.Graphics.RenderCore.starling.display
{
	import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
	import QFLib.Graphics.RenderCore.starling.core.Starling;

	public final class RenderQueueGroup
	{
		private static var _increaseValue : int = 0;
		/** 背景层，地图背景用 */
		public static const BACK_GROUND:int = _increaseValue++;

		/** 默认层. 人物、场景物体等用  */
		public static const DEFAULT:int = _increaseValue++;
		
		/** 飘血数字等用途  */
		public static const OVERLAY:int = _increaseValue++;
		
		public static const MAX:int = _increaseValue;
		
		private static const sNeedSortGroups:Vector.<int> = new <int>[DEFAULT];
		
		private static var sSortBuffer:RenderQueue = null;
		
		public static var depthSortFunction:Function = null;
		
		private var _renderQueues:Vector.<RenderQueue> = new <RenderQueue>[];		
		
		public static function getNeedSortGroups():Vector.<int>
		{
			return sNeedSortGroups;
		}
		
		public function RenderQueueGroup()
		{
			for (var i:int = 0; i < RenderQueueGroup.MAX; ++i)
			{
				_renderQueues[i] = new RenderQueue();
			}
			
			if(sSortBuffer == null)
			{
				sSortBuffer = new RenderQueue();
			}
		}
		
		public function get length():int
		{
			return _renderQueues.length;
		}
		
		public function addNode(renderQueueID:int, node:ISceneNode):void
		{
			_renderQueues[renderQueueID].renderQueue.push(node);
		}
		
		public function push(renderQueueID : int, node:ISceneNode):void
		{
			_renderQueues[renderQueueID].renderQueue.push(node);
		}

		public function sort():void
		{
			if(depthSortFunction == null)
			{
				return;
			}
			
			var currentQueue:RenderQueue;
			var vec : Vector.<int> = getNeedSortGroups();
			for each(var i:int in vec)
			{
				currentQueue = _renderQueues[i];
				
				sSortBuffer.renderQueue.length = currentQueue.renderQueue.length;
				RenderQueue.mergeSort(currentQueue, depthSortFunction, 0, currentQueue.renderQueue.length, sSortBuffer);
			}
			sSortBuffer.renderQueue.length = 0;
		}
		
		public function render(support:RenderSupport):void
		{
			var renderQueuesLen:int = _renderQueues.length;
			if (renderQueuesLen > RenderQueueGroup.MAX)
			{
				throw new RangeError("_renderQueueGroups length bigger than RenderQueueGroup.MAX:" + renderQueuesLen.toString());
			}
			
			var currentQueue:RenderQueue;
			
			// render
			for (var i:int = 0, len:int = renderQueuesLen; i < len; i++)
			{
				currentQueue = _renderQueues[i];
				var queueGroupLength:int = currentQueue.renderQueue.length;
				for (var j:int = 0; j < queueGroupLength; ++j)
				{
					var sceneNode:ISceneNode = currentQueue.renderQueue[j];
					sceneNode.renderUnify(support);
				}
			}
		}
		
		public function clear():void
		{
			var renderQueuesLen:int = _renderQueues.length;
			
			if (renderQueuesLen > RenderQueueGroup.MAX)
			{
				throw new RangeError("_renderQueueGroups length bigger than RenderQueueGroup.MAX:" + renderQueuesLen.toString());
			}
			
			for (var i:int = 0; i < renderQueuesLen; ++i)
			{
				_renderQueues[i].renderQueue.length = 0;
			}
		}
		
		public function dispose():void
		{
			clear();
			_renderQueues.length = 0;
		}
	}
}

import QFLib.Graphics.RenderCore.starling.display.ISceneNode;

class RenderQueue
{
	public var renderQueue:Vector.<ISceneNode> = new <ISceneNode>[];
	
	public function RenderQueue()
	{
	}

	public static function mergeSort(input:RenderQueue, compareFunc:Function,
									  startIndex:int, length:int,
									  buffer:RenderQueue):void
	{
		// This is a port of the C++ merge sort algorithm shown here:
		// http://www.cprogramming.com/tutorial/computersciencetheory/mergesort.html
		
		if (length <= 1)
		{
			return;
		}
		else
		{
			var i:int = 0;
			var endIndex:int = startIndex + length;
			var halfLength:int = length / 2;
			var l:int = startIndex;              // current position in the left subvector
			var r:int = startIndex + halfLength; // current position in the right subvector
			
			// sort each subvector
			mergeSort(input, compareFunc, startIndex, halfLength, buffer);
			mergeSort(input, compareFunc, startIndex + halfLength, length - halfLength, buffer);
			
			// merge the vectors, using the buffer vector for temporary storage
			for (i = 0; i < length; i++)
			{
				// Check to see if any elements remain in the left vector; 
				// if so, we check if there are any elements left in the right vector;
				// if so, we compare them. Otherwise, we know that the merge must
				// take the element from the left vector. */
				var queue:Vector.<ISceneNode> = buffer.renderQueue;
				if (l < startIndex + halfLength &&
					(r == endIndex || compareFunc(input.renderQueue[l], input.renderQueue[r]) <= 0))
				{
					queue[i] = input.renderQueue[l];
					l++;
				}
				else
				{
					queue[i] = input.renderQueue[r];
					r++;
				}
			}
			
			// copy the sorted subvector back to the input
			for (i = startIndex; i < endIndex; i++)
			{
				input.renderQueue[i] = queue[int(i - startIndex)];
			}
		}
	}
}

