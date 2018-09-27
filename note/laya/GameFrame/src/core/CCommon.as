package core
{
	import laya.debug.tools.ClassTool;
	import laya.display.Stage;

	/**
	 * ...
	 * @author auto
	 	剥离laya特性
	 */
	public class CCommon{
		public static function getQualifiedClassName(obj:Object) : String {
			return ClassTool.getClassName(obj);
		}

		public static function get stage() : Stage {
			return Laya.stage;
		}
	}

}