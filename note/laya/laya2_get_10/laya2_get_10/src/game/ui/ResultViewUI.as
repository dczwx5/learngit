/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package game.ui {
	import laya.ui.*;import laya.display.*; 

	public class ResultViewUI extends Dialog {
		public var list:List;
		public var top_score_txt:Label;
		public var reset_btn:Sprite;
		public var alive_cost_txt:Label;
		public var numberView:NumberViewUI;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"Dialog","props":{"y":0,"x":0,"width":750,"height":1000,"autoDestroyAtClosed":false},"compId":1,"child":[{"type":"Image","props":{"y":148,"x":24,"width":702,"skin":"comp/img_bg.png","name":"bg","height":596,"sizeGrid":"29,6,7,5"},"compId":8},{"type":"Label","props":{"y":334,"x":175,"width":281,"text":"历史最高分 :","styleSkin":"comp/label.png","strokeColor":"#5b0900 ","stroke":3,"height":67,"fontSize":48,"color":"#ff0400","align":"center"},"compId":6},{"type":"Sprite","props":{"y":-65,"x":147,"width":470,"texture":"gameUI/score_title.png","height":258},"compId":10},{"type":"Sprite","props":{"y":73,"x":250,"texture":"gameUI/cur_score.png"},"compId":13},{"type":"List","props":{"y":418,"x":58,"width":648,"var":"list","spaceX":2,"repeatY":1,"repeatX":3,"height":297},"compId":18,"child":[{"type":"ResultPlayerItem","props":{"name":"render","runtime":"game.ui.ResultPlayerItemUI"},"compId":17}],"components":[]},{"type":"Label","props":{"y":335,"x":463.5,"width":220,"var":"top_score_txt","text":"89999","styleSkin":"comp/label.png","strokeColor":"#000000","stroke":4,"name":"top_score_txt","height":67,"fontSize":48,"color":"#ff0400","align":"left"},"compId":21},{"type":"Label","props":{"y":883,"x":329,"width":106,"text":"跳过","styleSkin":"comp/label.png","strokeColor":"#5b0900 ","stroke":4,"name":"top_score_txt","height":55,"fontSize":48,"color":"#ffffff","align":"center"},"compId":22},{"type":"Box","props":{"y":748,"x":250},"compId":24,"child":[{"type":"Sprite","props":{"var":"reset_btn","texture":"gameUI/live.png","name":"reset_btn"},"compId":14},{"type":"Sprite","props":{"y":46,"x":77,"texture":"gameUI/coin_gold.png"},"compId":15},{"type":"Label","props":{"y":52,"x":123,"width":76,"var":"alive_cost_txt","text":"x 30","strokeColor":"#000000","stroke":5,"rotation":0,"presetID":1,"height":28,"fontSize":24,"color":"#ffffff","styleSkin":"comp/label.png","isPresetRoot":true},"compId":16}],"components":[]},{"type":"NumberView","props":{"y":193,"x":273.5,"var":"numberView","name":"numberView","runtime":"game.ui.NumberViewUI"},"compId":25}],"loadList":["comp/img_bg.png","comp/label.png","gameUI/score_title.png","gameUI/cur_score.png","ResultPlayerItem.scene","gameUI/live.png","gameUI/coin_gold.png","prefab/Label.prefab","NumberView.scene"],"loadList3D":[],"components":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}