/**Created by the LayaAirIDE,do not modify.*/
package ui {
	import laya.ui.*;
	import laya.display.*; 
	import laya.display.Text;

	public class GameOverUI extends Dialog {
		public var ani_restart:FrameAnimation;
		public var txt_score:Text;
		public var btn_restart:Box;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"Dialog","props":{"width":720,"height":1280},"child":[{"type":"Image","props":{"y":0,"x":0,"width":720,"skin":"gameUI/bg.jpg","sizeGrid":"4,4,4,4","height":1280}},{"type":"Image","props":{"y":378,"x":229,"skin":"gameUI/gameOver.png"}},{"type":"Text","props":{"y":1200,"x":19,"width":681,"text":"LayaAir1.7.3引擎教学演示版","height":29,"fontSize":26,"font":"SimHei","color":"#7c7979","bold":true,"align":"center"}},{"type":"Text","props":{"y":575,"x":244,"width":144,"text":"本局积分：","height":29,"fontSize":30,"font":"SimHei","color":"#7c7979","bold":true,"align":"center"}},{"type":"Text","props":{"y":575,"x":363,"width":128,"var":"txt_score","text":"1200","height":29,"fontSize":30,"font":"SimHei","color":"#7c7979","bold":true,"align":"center"}},{"type":"Box","props":{"y":960,"x":239,"var":"btn_restart"},"compId":10,"child":[{"type":"Button","props":{"y":0,"x":1,"width":240,"stateNum":2,"skin":"gameUI/btn_bg.png","sizeGrid":"10,10,10,10","height":80}},{"type":"Image","props":{"y":18,"x":41,"skin":"gameUI/restart.png"}}]}],"animations":[{"nodes":[{"target":10,"keyframes":{"y":[{"value":970,"tweenMethod":"elasticOut","tween":true,"target":10,"key":"y","index":0},{"value":960,"tweenMethod":"linearNone","tween":true,"target":10,"key":"y","index":8}]}}],"name":"ani_restart","id":1,"frameRate":24,"action":0}]};
		override protected function createChildren():void {
			View.regComponent("Text",Text);
			super.createChildren();
			createView(uiView);

		}

	}
}