/**Created by the LayaAirIDE,do not modify.*/
package ui.bottom {
	import laya.ui.*;
	import laya.display.*; 
	import ui.bottom.BottomDescUI;

	public class BottomUI extends View {
		public var desc_ui:BottomDescUI;
		public var hero_btn:Button;
		public var building_btn:Button;
		public var equip_btn:Button;
		public var shop_btn:Button;
		public var goods_btn:Button;
		public var activity_btn:Button;
		public var hero_img:Image;
		public var building_img:Image;
		public var equip_img:Image;
		public var goods_img:Image;
		public var shop_img:Image;
		public var activity_img:Image;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":750,"height":600,"bottom":0},"child":[{"type":"Image","props":{"y":39,"x":164,"width":435,"staticCache":false,"skin":"gameUI/1.png","height":442,"cacheAsBitmap":true}},{"type":"BottomDesc","props":{"y":0,"x":0,"var":"desc_ui","runtime":"ui.bottom.BottomDescUI"}},{"type":"Box","props":{"y":543,"x":2,"width":749,"height":54},"child":[{"type":"Button","props":{"y":550,"x":0,"var":"hero_btn","stateNum":2,"skin":"gameUI/btn_bg.png","labelStrokeColor":"#0f0f0f","labelStroke":2,"labelSize":24,"labelColors":"#ffffff","label":"人物","bottom":0}},{"type":"Button","props":{"y":550,"x":125,"var":"building_btn","stateNum":2,"skin":"gameUI/btn_bg.png","labelStrokeColor":"#0f0f0f","labelStroke":2,"labelSize":24,"labelColors":"#ffffff","label":"建筑","bottom":0}},{"type":"Button","props":{"y":550,"x":250,"var":"equip_btn","stateNum":2,"skin":"gameUI/btn_bg.png","labelStrokeColor":"#0f0f0f","labelStroke":2,"labelSize":24,"labelColors":"#ffffff","label":"装备","bottom":0}},{"type":"Button","props":{"y":550,"x":500,"var":"shop_btn","stateNum":2,"skin":"gameUI/btn_bg.png","labelStrokeColor":"#0f0f0f","labelStroke":2,"labelSize":24,"labelColors":"#ffffff","label":"商城","bottom":0}},{"type":"Button","props":{"y":550,"x":375,"var":"goods_btn","stateNum":2,"skin":"gameUI/btn_bg.png","labelStrokeColor":"#0f0f0f","labelStroke":2,"labelSize":24,"labelColors":"#ffffff","label":"圣物","bottom":0}},{"type":"Button","props":{"y":550,"x":625,"var":"activity_btn","stateNum":2,"skin":"gameUI/btn_bg.png","labelStrokeColor":"#0f0f0f","labelStroke":2,"labelSize":24,"labelColors":"#ffffff","label":"活动","bottom":0}},{"type":"Image","props":{"x":13,"var":"hero_img","skin":"gameUI/bb.png","bottom":-2}},{"type":"Image","props":{"x":139,"var":"building_img","skin":"gameUI/reward.png","bottom":-3}},{"type":"Image","props":{"x":269,"var":"equip_img","skin":"gameUI/shop.png","bottom":1}},{"type":"Image","props":{"x":389,"var":"goods_img","skin":"gameUI/bb.png","bottom":-1}},{"type":"Image","props":{"x":516,"var":"shop_img","skin":"gameUI/reward.png","bottom":-3}},{"type":"Image","props":{"x":642,"var":"activity_img","skin":"gameUI/shop.png","bottom":1}}]}]};
		override protected function createChildren():void {
			View.regComponent("ui.bottom.BottomDescUI",BottomDescUI);
			super.createChildren();
			createView(uiView);

		}

	}
}