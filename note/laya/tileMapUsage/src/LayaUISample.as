package {
import laya.net.Loader;
import laya.net.ResourceVersion;
import laya.utils.Handler;
import laya.wx.mini.MiniAdpter;
import laya.webgl.WebGL;
import laya.map.TiledMap;
import laya.maths.Rectangle;
import laya.utils.Browser;
import laya.display.Sprite;
import laya.display.Stage;

public class LayaUISample {
	
	public function LayaUISample() {
		//初始化微信小游戏
		MiniAdpter.init();

		//初始化引擎
		Laya.init(600, 400,WebGL);
		Laya.stage.scaleMode = Stage.SCALE_EXACTFIT;

		//激活资源版本控制
		ResourceVersion.enable("version.json", Handler.create(this, beginLoad), ResourceVersion.FILENAME_VERSION);
	}
	private var tMap:CMap;
	private function beginLoad():void {
		tMap = new CMap();
	}
	
}
}



