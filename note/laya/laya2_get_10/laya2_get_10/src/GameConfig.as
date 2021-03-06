/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package {
	import laya.utils.ClassUtils;
	import laya.ui.View;
	import laya.webgl.WebGL;
	import script.MyControl;
	import laya.display.Text;
	import laya.ui.WXOpenDataViewer;
	import script.CNumberView;
	/**
	 * 游戏初始化配置
	 */
	public class GameConfig {
		public static var width:int = 750;
		public static var height:int = 1334;
		public static var scaleMode:String = "exactfit";
		public static var screenMode:String = "none";
		public static var alignV:String = "top";
		public static var alignH:String = "left";
		public static var startScene:* = "GameScene.scene";
		public static var sceneRoot:String = "";
		public static var debug:Boolean = false;
		public static var stat:Boolean = false;
		public static var physicsDebug:Boolean = false;
		public static var exportSceneToJson:Boolean = true;
		
		public static function init():void {
			//注册Script或者Runtime引用
			var reg:Function = ClassUtils.regClass;
			reg("script.MyControl",MyControl);
			reg("laya.display.Text",Text);
			reg("laya.ui.WXOpenDataViewer",WXOpenDataViewer);
			reg("script.CNumberView",CNumberView);
		}
		GameConfig.init();
	}
}