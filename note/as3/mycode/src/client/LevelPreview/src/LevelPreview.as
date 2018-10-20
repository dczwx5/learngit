package {

import QFLib.ResourceLoader.CResourceLoaders;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import kof.framework.CNetworkApp;
import kof.framework.CStandaloneApp;
import kof.game.CGameStage;
import kof.game.Tutorial.CTutorSystem;
import kof.game.levelCommon.CLevelConfig;

import preview.game.CLevelStage;

[SWF(frameRate="60", backgroundColor="#000000", width="1500", height="900")]
public class LevelPreview extends Sprite {

    // private var _renderer:CRenderer;
//    private var _exeParam:CExeParam;
    private var _levelApp:CStandaloneApp;
    private var _sParam:Object;
    public function LevelPreview() {
        if (stage) {
            addedToStage();
        } else {
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }
    }

    private function addedToStage(event:Event = null):void {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        _onParseExeParams();
        // _renderer = new CRenderer(stage);
        // _renderer.initialize(_onParseExeParams);
    }

    private function _onParseExeParams() : void {
        _sParam = this.loaderInfo.parameters;
        if (_sParam == null || _sParam.length == 0) {
            _sParam.push("fbname:3333"); //  other:abcd
        }
        _onStart();
    }

    private function _onStart() : void {
        CResourceLoaders.instance().createAssetVersion("assets/asset_version.txt");
//        if(_exeParam.isLevelEditor) {
//            CLevelPath.LEVEL_RES_PATH = "assets/level/tempfile/";
//        }
        CLevelConfig.IS_LOG = isLog;
        CLevelConfig.IS_LEVELE_PREVIEW = true;//_exeParam.isLevelEditor;
//        var levelStage:CLevelStage;
        var levelStage:CGameStage;
        if (!_levelApp) {
            _levelApp = new CNetworkApp(stage);
            if (_levelApp.initialize()) {
                _levelApp.configuration.setConfig("CdnURI", CdnURI);
                levelStage = new CGameStage();
                CLevelConfig.stage = levelStage;
                CTutorSystem.forceNeverCloseKeyPress = true;
                _levelApp.runWithStage(new this.stageClass);
            }
//            (levelStage.getSystem(CTutorSystem) as CTutorSystem).forceNeverCloseKeyPress = true;
            this.stage.addChild(new CUILayer(levelStage));
        }
    }

    public function get isLog() : Boolean {
        if(_getValueByKey("log")){
            return _getValueByKey("log").toLowerCase() == "true";
        }
        return false;
    }

    public function get CdnURI() : String {
        if(_getValueByKey("CdnURI")){
            return _getValueByKey("CdnURI").toString().replace("|",":");
        }
        return "F:\\KOF_PG_Client\\trunk\\runtime\\client";
    }

    private function _getValueByKey(key:String) : String {
        if(_sParam && _sParam[key]){
            return _sParam[key];
        }
        return null;
    }

    protected function get stageClass() : Class {
        return CLevelStage;
    }

}
}
