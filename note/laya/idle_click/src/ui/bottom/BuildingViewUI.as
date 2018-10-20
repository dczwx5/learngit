/**Created by the LayaAirIDE,do not modify.*/
package ui.bottom {
	import laya.ui.*;
	import laya.display.*; 
	import ui.bottom.BuildingItemUI;

	public class BuildingViewUI extends View {
		public var list:List;
		public var buy_count_btn:Button;
		public var buy_count_txt:Label;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":750,"height":550},"child":[{"type":"List","props":{"y":64,"x":12,"width":720,"var":"list","spaceY":2,"repeatY":6,"repeatX":1,"height":479},"child":[{"type":"BuildingItem","props":{"renderType":"render","runtime":"ui.bottom.BuildingItemUI"}}]},{"type":"Button","props":{"y":8,"x":612,"var":"buy_count_btn","stateNum":2,"skin":"gameUI/btn_bg.png","sizeGrid":"9,8,9,10","labelSize":24}},{"type":"Label","props":{"y":18,"x":637,"width":75,"text":"购买x","strokeColor":"#000000","height":27,"fontSize":24,"color":"#ffffff"}},{"type":"Label","props":{"y":19,"x":699,"width":43,"var":"buy_count_txt","text":"1","strokeColor":"#000000","height":27,"fontSize":24,"color":"#ffffff"}}]};
		override protected function createChildren():void {
			View.regComponent("ui.bottom.BuildingItemUI",BuildingItemUI);
			super.createChildren();
			createView(uiView);

		}

	}
}