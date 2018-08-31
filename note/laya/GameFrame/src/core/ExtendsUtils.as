package core
{

	import core.ExtendsUtils;
	import laya.debug.tools.ClassTool;

	/**
	 * ...
	 * @author
	 */
	public class ExtendsUtils{
		public static function getQualifiedClassName(obj:Object) : String {
			return ClassTool.getClassName(obj);
		}
	}

}