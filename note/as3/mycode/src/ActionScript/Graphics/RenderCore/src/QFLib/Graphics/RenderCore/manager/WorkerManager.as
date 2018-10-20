package QFLib.Graphics.RenderCore.manager
{
	import flash.utils.getDefinitionByName;

	/**
	 * @author traimen
	 * @data 2015-11-14
	 **/
	public class WorkerManager
	{
		public function WorkerManager()
		{
		}
		
		private static var _workerController:Object;
		
		//是否使用多线程预加载
		public static var useLazyLoad:Boolean = false;
		//是否使用多线程解码图片
		public static var useBitmapDecode:Boolean = false;
		//是否使用ogg
		public static var useOgg:Boolean = false;
		
		public static function get instance():Object{
			if(!_workerController){
				var WorkersClass:Object = getDefinitionByName("WorkerDll");
				_workerController = new WorkersClass();
				_workerController.setup();
			}
			return _workerController;
		}
	}
}