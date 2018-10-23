package a_core
{
	import laya.debug.tools.ClassTool;
	import laya.display.Stage;

	/**
	 * ...
	 * @author auto
	 	剥离laya特性
	 */
	public class CCommon{
		public static function get screenWidth() : int {
			return GameConfig.width;
		}
		public static function get screenHeight() : int {
			return GameConfig.height;
		}
		public static function getQualifiedClassName(obj:Object) : String {
			return ClassTool.getClassName(obj);
		}

		public static function get stage() : Stage {
			return Laya.stage;
		}

		public static function getTimer() : Number {
			return Laya.timer.currTimer;
		}

		public static function assertFalse(expressionResult:Boolean, msg:String = null) : void {
			if (false !== expressionResult) {
				_throwError(msg ? msg : "assertFalse Failed.");
			}
		}
		private static function _throwError(msg:String):void {
        	throw new Error(msg);
		}
    }
	}
