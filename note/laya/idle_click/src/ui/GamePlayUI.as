/**Created by the LayaAirIDE,do not modify.*/
package ui {
	import laya.ui.*;
	import laya.display.*; 
	import laya.display.Text;
	import ui.bottom.BottomUI;

	public class GamePlayUI extends View {
		public var btn_pause:Button;
		public var gold_title_txt:Text;
		public var gold_txt:Text;
		public var adp_txt:Text;
		public var bottom_ui:BottomUI;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":750,"height":1334},"child":[{"type":"Image","props":{"y":20,"x":0,"width":750,"skin":"gameUI/blank.png","height":45}},{"type":"Button","props":{"y":21,"x":641,"var":"btn_pause","stateNum":1,"skin":"gameUI/btn_pause.png"}},{"type":"Text","props":{"y":24,"x":228,"width":150,"var":"gold_title_txt","text":"资源 ：","height":40,"fontSize":30,"font":"SimHei","bold":true,"align":"left"}},{"type":"Text","props":{"y":24,"x":330,"width":276,"var":"gold_txt","text":"9999","height":40,"fontSize":30,"font":"SimHei","bold":true,"align":"left"}},{"type":"Text","props":{"y":27,"x":13,"width":150,"text":"adp：","height":40,"fontSize":30,"font":"SimHei","bold":true,"align":"left"}},{"type":"Text","props":{"y":27,"x":112,"width":104,"var":"adp_txt","text":"9999","height":40,"fontSize":30,"font":"SimHei","bold":true,"align":"left"}},{"type":"Bottom","props":{"y":432,"x":0,"var":"bottom_ui","runtime":"ui.bottom.BottomUI"}}]};
		override protected function createChildren():void {
			View.regComponent("Text",Text);
			View.regComponent("ui.bottom.BottomUI",BottomUI);
			super.createChildren();
			createView(uiView);

		}

	}
}