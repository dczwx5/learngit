package QFLib.Graphics.RenderCore.starling.utils
{

	public class MemoryTrace
	{
		public var stackTrace:String;
		private var refObj:WeakRef;
		
		public function MemoryTrace(_stackTrace:String, obj:*)
		{
			stackTrace = _stackTrace;
			refObj = new WeakRef(obj);
		}
		
		public function getObj():*
		{
			return refObj.get();
		}
	}
}