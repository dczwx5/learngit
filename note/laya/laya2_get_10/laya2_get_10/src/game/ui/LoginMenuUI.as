/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package game.ui {
	import laya.ui.*;import laya.display.*; 

	public class LoginMenuUI extends Scene {
		public var start_btn:Button;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"Scene","props":{"width":750,"height":1334},"compId":1,"child":[{"type":"Image","props":{"top":0,"skin":"comp/img_bg.png","right":0,"left":0,"bottom":0,"sizeGrid":"29,6,7,5"},"compId":2},{"type":"Button","props":{"y":742,"x":157.5,"width":435,"var":"start_btn","skin":"comp/button.png","label":"开始游戏","height":339},"compId":3}],"loadList":["comp/img_bg.png","comp/button.png"],"loadList3D":[],"components":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}