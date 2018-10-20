/**Created by the LayaAirIDE,do not modify.*/
package ui.bottom {
	import laya.ui.*;
	import laya.display.*; 

	public class HeroViewUI extends View {

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":750,"height":550}};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}