package {
	import laya.net.Loader;
	import laya.net.ResourceVersion;
	import laya.utils.Handler;
	import laya.wx.mini.MiniAdpter;
	import laya.webgl.WebGL;
	import game.CGameStage;
	import game.CGameStageStart;
	import laya.utils.Stat;
	import laya.display.Stage;
	import core.CBaseDataCodeBuilder;
	import game.CPathUtils;
	import laya.utils.ClassUtils;
	import laya.debug.tools.ClassTool;
	import table.Chapter;
	import table.Instance;
	import core.framework.CAppStage;
	
	// sequntialProceudreManager不能只有一条线
	public class LayaUISample {
		
		public function LayaUISample() {
			//初始化微信小游戏
			MiniAdpter.init();

			//初始化引擎，建议增加WebGl模式
			// Laya.init(720, 1280,WebGL);
			Laya.init(1136, 640,WebGL);


			Stat.show();
			//全屏不等比缩放模式
			Laya.stage.scaleMode = Stage.SCALE_EXACTFIT;
			
			//激活资源版本控制
            ResourceVersion.enable("version.json", Handler.create(this, _onStart), ResourceVersion.FILENAME_VERSION); 
		}

		private function _onStart() : void {
			new CGameStageStart();
		}
	 
		
		private function beginLoad():void {
			//加载引擎需要的资源
			// Laya.loader.load("res/atlas/comp.atlas", Handler.create(this, onLoaded));
		}
		
		private function onLoaded():void {
			//实例UI界面
			// var testView:TestView = new TestView();
			// Laya.stage.addChild(testView);
		}
	}
}
 