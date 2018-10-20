/**Created by the LayaAirIDE,do not modify.*/
package ui.bottom {
	import laya.ui.*;
	import laya.display.*; 
	import ui.bottom.BuildingViewUI;

	public class BottomDescUI extends View {
		public var building_ui:BuildingViewUI;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":750,"height":550},"child":[{"type":"BuildingView","props":{"y":0,"x":0,"var":"building_ui","runtime":"ui.bottom.BuildingViewUI"}}]};
		override protected function createChildren():void {
			View.regComponent("ui.bottom.BuildingViewUI",BuildingViewUI);
			super.createChildren();
			createView(uiView);

		}

	}
}