/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package game.ui {
	import laya.ui.*;import laya.display.*; 

	public class ResultPlayerItemUI extends View {
		public var player_name_txt:Label;
		public var rank_txt:Label;
		public var score_txt:Label;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":212,"height":291},"compId":1,"child":[{"type":"Sprite","props":{"y":0,"x":0,"texture":"gameUI/result_frame_bg.png"},"compId":2},{"type":"Sprite","props":{"y":49,"x":48.5,"texture":"gameUI/result_head_bg.png"},"compId":3},{"type":"Label","props":{"y":178,"x":5,"width":203,"var":"player_name_txt","text":"玩家名字","styleSkin":"comp/label.png","strokeColor":"#000000","stroke":4,"height":35,"fontSize":24,"color":"#ffffff","align":"center"},"compId":6},{"type":"Label","props":{"y":13,"x":5,"width":203,"var":"rank_txt","text":"1","styleSkin":"comp/label.png","strokeColor":"#000000","stroke":4,"height":28,"fontSize":24,"color":"#ffffff","align":"center"},"compId":7},{"type":"Label","props":{"y":234,"x":4.5,"width":203,"var":"score_txt","text":"9999","styleSkin":"comp/label.png","strokeColor":"#000000","stroke":4,"height":28,"fontSize":24,"color":"#ffffff","align":"center"},"compId":8}],"loadList":["gameUI/result_frame_bg.png","gameUI/result_head_bg.png","comp/label.png"],"loadList3D":[],"components":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}