/**Created by the LayaAirIDE,do not modify.*/
package ui.bottom {
	import laya.ui.*;
	import laya.display.*; 
	import laya.display.Text;

	public class BuildingItemUI extends View {
		public var lvup_btn:Button;
		public var cost_txt:Text;
		public var lvup_txt:Text;
		public var effect_txt:Text;
		public var name_txt:Text;
		public var lv_txt:Text;
		public var dps_txt:Text;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":720,"height":80,"cacheAsBitmap":false},"child":[{"type":"Image","props":{"top":0,"skin":"gameUI/bg2.jpg","right":0,"left":0,"bottom":0}},{"type":"Image","props":{"y":6,"x":11,"width":69,"skin":"gameUI/fire.png","height":69}},{"type":"Button","props":{"y":2,"x":594,"width":123,"var":"lvup_btn","stateNum":2,"skin":"gameUI/btn_bg.png","sizeGrid":"10,10,11,12","height":77}},{"type":"Text","props":{"y":6,"x":622,"width":33,"text":"花费：","strokeColor":"#000000","stroke":2,"mouseEnabled":false,"height":26,"color":"#ffffff"}},{"type":"Text","props":{"y":6,"x":653,"width":94,"var":"cost_txt","text":"9999","strokeColor":"#000000","stroke":2,"mouseEnabled":false,"height":26,"color":"#ffffff"}},{"type":"Text","props":{"y":27,"x":609,"width":93,"var":"lvup_txt","text":"升级","strokeColor":"#000000","stroke":2,"mouseEnabled":false,"height":18,"color":"#ffffff","align":"center"}},{"type":"Text","props":{"y":53,"x":595,"width":120,"var":"effect_txt","text":"+451.19K DPS","strokeColor":"#000000","stroke":2,"mouseEnabled":false,"height":18,"color":"#ffffff","align":"center"}},{"type":"Text","props":{"y":8,"x":84,"width":263,"var":"name_txt","text":"戴维*加农船长","strokeColor":"#000000","stroke":2,"mouseEnabled":false,"height":31,"fontSize":24,"color":"#ffffff","align":"left"}},{"type":"Text","props":{"y":38,"x":85,"width":22,"text":"Lv:","strokeColor":"#000000","stroke":2,"mouseEnabled":false,"height":17,"fontSize":12,"color":"#ffffff","align":"left"}},{"type":"Text","props":{"y":38,"x":109,"width":137,"var":"lv_txt","text":"9999","strokeColor":"#000000","stroke":2,"mouseEnabled":false,"height":17,"fontSize":12,"color":"#ffffff","align":"left"}},{"type":"Text","props":{"y":15,"x":518,"width":44,"text":"DPS:","strokeColor":"#000000","stroke":2,"mouseEnabled":false,"height":17,"fontSize":12,"color":"#ffffff","align":"left"}},{"type":"Text","props":{"y":15,"x":550,"width":50,"var":"dps_txt","text":"9999","strokeColor":"#000000","stroke":2,"mouseEnabled":false,"height":17,"fontSize":12,"color":"#ffffff","align":"left"}}]};
		override protected function createChildren():void {
			View.regComponent("Text",Text);
			super.createChildren();
			createView(uiView);

		}

	}
}