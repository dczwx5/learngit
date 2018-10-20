package kof.game.loading {

import QFLib.Graphics.FX.utils.MathUtils;
import QFLib.Math.CMath;
import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.CSwfLoader;
import QFLib.ResourceLoader.ELoadingPriority;
import QFLib.Utils.PathUtil;

import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.Event;
import flash.utils.getTimer;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.table.DeskTips;
import kof.table.Level;
import kof.ui.CUISystem;
import kof.ui.Loading.SceneLoadingViewUI;
import kof.ui.components.KOFFrameClipProgressBar;
import kof.ui.components.KOFProgressBar;

import morn.core.components.FrameClip;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSceneLoadingViewHandler extends CViewHandler {

    public static const EVENT_PLAY_SWF_FINISH:String = "event_play_swf_finish";
    public static const EVENT_ADD:String = "event_add";
    public static const EVENT_END:String = "event_end";
    private var m_pUI : SceneLoadingViewUI;
    private var m_bShowing : Boolean;
    private var m_pMask : Shape;
    private var m_MC:MovieClip;
    private var m_pMCResource : CResource;
    private var m_first:Boolean;

    public function CSceneLoadingViewHandler() {
        super( true ); // load view by default to call onInitializeView
    }

    override public function dispose() : void {
        _disposeMC();
        _removeDisplay();
        super.dispose();
        m_pUI = null;
        m_pMask = null;
    }

    override public function get viewClass() : Array {
        return [ SceneLoadingViewUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["sceneLoading.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        m_pUI = m_pUI || new SceneLoadingViewUI();
        m_pMask = m_pMask || new Shape();
        return Boolean( m_pUI );
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        if ( ret ) {
            this._removeDisplay();
        }

        return ret;
    }

    override protected function updateData() : void {
        super.updateData();
    }

    override protected function updateDisplay() : void {
        super.updateDisplay();

        if ( !m_pUI ) {
            invalidateDisplay();
            return;
        }

        if ( m_pUI.parent && !m_bShowing ) {
            this._removeDisplay();
        } else if ( !m_pUI.parent && m_bShowing ) {
            this._addDisplay();
        }

        _updateSchedule();
    }

    public function show() : void {
        m_bShowing = true;
        invalidateDisplay();
    }

    private function _addDisplay() : void {
        var pUISystem : CUISystem = system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISystem ) {
            pUISystem.loadingLayer.addChildAt( m_pMask, 0 );
            pUISystem.loadingLayer.addChild( m_pUI );
            dispatchEvent(new Event(EVENT_ADD));

            system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
            isShow = !_forceHide;

            m_pUI.text_deskArtFont.visible = false;

            var levelManager:CLevelManager = system.stage.getSystem(CLevelSystem ).getHandler(CLevelManager) as CLevelManager;
            if(levelManager && levelManager.levelID && m_first){

                // loading bg image
                var loadingBgList:Array = levelManager.levelRecord.LoadingBg;
                var tempList:Array = new Array();
                for each (var loadingURL:String in loadingBgList) {
                    if (loadingURL && loadingURL.length > 0) {
                        tempList[tempList.length] = loadingURL;
                    }
                }
                var rndIndex:int = CMath.rand() * tempList.length;
                m_pUI.bg_img.url = tempList[rndIndex];

                // loading swf
                var loadingUrl:String = (levelManager.levelTable.findByPrimaryKey(levelManager.levelID ) as Level).loading;
                var isPassBool:Boolean = true;
                var id:int = (levelManager.levelTable.findByPrimaryKey(levelManager.levelID ) as Level).clearmissionid;
                if(id){
                    var instanceData:CChapterInstanceData = (system.stage.getSystem(CInstanceSystem ) as CInstanceSystem).getInstanceByID(id );
                    isPassBool = !instanceData.isCompleted;
                }
                if(loadingUrl && loadingUrl != "" && isPassBool)
                {
                    m_pUI.bg_img.visible = false;
                    m_pUI.text_deskTips.visible = true;
                    var url:String = getSWFPath(loadingUrl);
                    CResourceLoaders.instance().startLoadFile( url, swfOnLoadComplete, null, ELoadingPriority.CRITICAL );
                }
                else
                {
                    m_pUI.bg_img.visible = true;
                    m_pUI.text_deskTips.visible = true;
                }

                // 美术字
                if (levelManager.levelRecord && levelManager.levelRecord.Artword && levelManager.levelRecord.Artword.length > 0) {
                    m_pUI.text_deskArtFont.visible = true;
                    m_pUI.text_deskArtFont.url = levelManager.levelRecord.Artword;
                }
            }
            m_pUI.clip_loading.visible = false;

            m_first = true;
            _startTime = getTimer();
            schedule( 1 / 60, _onTick);
            _targetRate = 90;
            _virtualLoadingRate = 0;
//            redrawMask();
            _onStageResize();


            var deskTipsTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.DESKTIPS );
            if(deskTipsTable){
                if (levelManager && levelManager.levelRecord && levelManager.levelRecord.Programword > 0) {
                    // 关卡随机显示文本
                    var filterTipsList:Array = deskTipsTable.findByProperty("groupid", levelManager.levelRecord.Programword);
                    if (filterTipsList && filterTipsList.length > 0) {
                        _filterTipsList = filterTipsList;
                        _lastUpdateTipsTime = getTimer();
                        m_pUI.text_deskTips.text = (filterTipsList[0] as DeskTips).tips;
                        _lastTipsIndex = 0;
                        m_pUI.text_deskTips.visible = true;
                    }
                } else {
                    m_pUI.text_deskTips.visible = false;
                }
            }
        }
    }

    private function swfOnLoadComplete( pLoader : CSwfLoader, idError : int ):void {
        if ( 0 == idError ) {
            m_pMCResource = pLoader.createResource();
            m_MC = m_pMCResource.theObject as MovieClip;
            m_MC.addFrameScript( m_MC.totalFrames - 1, _onPlayFinish );
            m_pUI.mc_loading.addChild( m_MC );
            m_MC.gotoAndPlay( 0 );
            m_MC.x = -m_MC.width/2;//m_pUI.stage.stageWidth;
            m_MC.y = -m_MC.height/2;//m_pUI.stage.stageHeight;

            _isPlayLoadingMc = true;
        }
    }

    private function _disposeMC():void{
        if(m_MC){
            m_MC.stop();
            m_MC.parent.removeChild( m_MC );
            m_MC = null;
            if ( m_pMCResource ) {
                m_pMCResource.dispose();
            }
        }
    }

    private function _onPlayFinish():void{
        var levelManager:CLevelManager = system.stage.getSystem(CLevelSystem ).getHandler(CLevelManager) as CLevelManager;
        var loop:Boolean = (levelManager.levelTable.findByPrimaryKey(levelManager.levelID ) as Level).loadingloop;
        _isPlayLoadingMc = false;
        dispatchEvent(new Event(EVENT_PLAY_SWF_FINISH));
        if(!loop && m_MC){
            m_MC.stop();
        }
    }

    public static function getSWFPath(videoName:String) : String {
        var url:String = "assets/video/swf/" + videoName+".swf";

        return PathUtil.getVUrl(url);
    }

    private function _onTick(delta:Number) : void {
        var curTime:int = getTimer();
        var duringTime:int = curTime - _startTime;

        // 关卡随机显示文本
        if (_filterTipsList && _filterTipsList.length > 1) {
            if (curTime - _lastUpdateTipsTime > 5000) {
                _lastUpdateTipsTime = curTime;
                _lastTipsIndex++;
                if (_lastTipsIndex >= _filterTipsList.length) {
                    _lastTipsIndex = 0;
                }
                m_pUI.text_deskTips.text = (_filterTipsList[_lastTipsIndex] as DeskTips).tips;
            }
        }

        if ( m_bShowing || _bWaitOtherStop ) {
            var p : Number = duringTime / ( 50000 );
            p = Math.min( p, 1 );
            p = Math.sqrt( 1 - ( p = p - 1 ) * p );

            var fRatioTotal : Number = p * 0.9999;
            if ( fRatioTotal > 0.9999 )
                fRatioTotal = 0.9999;

            _virtualLoadingRate = fRatioTotal;
        } else {
            _virtualLoadingRate += delta * 0.35;
            if (_virtualLoadingRate < 0.90) {
                _virtualLoadingRate = 0.90;
            }
        }

        if (_targetRate >= 100) {

        }

        _updateSchedule();

        if (m_bShowing == false && _virtualLoadingRate >= 1.1) {
            unschedule(_onTick);
            _removeB();
        }
    }
//
//    // ran : 0 ~ 0.005 即1%
//    // +0.005 , 即结果为0.5%~1.5%
//    private function _randomAddRate() : Number {
//        return (Math.random() * 100 / 10000 + 0.0005);
//    }
    private function _updateSchedule() : void {
        if (_loadingBar) {
            var value:int = (int)(100*_virtualLoadingRate); // 1%是第1帧, index = 0
            value--;
            if (value < 0) {
                value = 0;
            }
            if (value > 99) {
                value = 99;
            }
            m_pUI.loading_BarLabel.text = value+"%";
            _loadingBar.value = value*0.01;
        }
    }

    private function _onStageResize( event : Event = null ) : void {
        this.redrawMask();

        m_pUI.centerX = 0;
        m_pUI.centerY = 0;

        var stageHeight:int = system.stage.flashStage.stageHeight;
        if(m_pUI.height <= stageHeight)
        {
            m_pUI.box_bottom.bottom = 50;
        }
        else
        {
            var diff:int = m_pUI.height - stageHeight >> 1;
            m_pUI.box_bottom.bottom = 50 + diff;
        }
    }

    private function redrawMask() : void {
        if ( !m_pMask )
            return;
        m_pMask.graphics.clear();
        m_pMask.graphics.beginFill( 0x0 );
        m_pMask.graphics.drawRect( 0, 0, system.stage.flashStage.stageWidth, system.stage.flashStage.stageHeight );
        m_pMask.graphics.endFill();
    }

    public function remove() : void {
        if ( m_bShowing == false ) return;
        if (m_MC && _isPlayLoadingMc) return;
        m_bShowing = false;
        _targetRate = 100;
    }

    private function _removeB() : void {
        invalidateDisplay();
    }

    private function _removeDisplay() : void {
        _filterTipsList = null;
        _lastTipsIndex = 0;
        _lastUpdateTipsTime = 0;

        if(m_MC){
            m_MC.stop();
            m_MC.parent.removeChild( m_MC );
            m_MC = null;
            if ( m_pMCResource ) {
                m_pMCResource.dispose();
            }
        }


        if ( m_pUI && m_pUI.parent )
            m_pUI.parent.removeChild( m_pUI );
        if ( m_pMask && m_pMask.parent )
            m_pMask.parent.removeChild( m_pMask );
        unschedule(_onTick);

        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
        dispatchEvent(new Event(EVENT_END));

    }

    private function get _loadingBar() : KOFProgressBar {
        if (m_pUI)
            return m_pUI.loading_Bar;
        return null;
    }

    private var _virtualLoadingRate:Number;
    private var _targetRate:Number;

    private var _startTime:int;

    private var _isPlayLoadingMc:Boolean;

    public function get isPlayLoadingSWF():Boolean{
        return _isPlayLoadingMc;
    }

    public function get isViewShow():Boolean
    {
        return m_pUI && m_pUI.parent;
    }

    public function set isShow(value:Boolean):void
    {
        if(m_pUI)
        {
            m_pUI.visible = value;
        }
    }

    public function get forceHide():Boolean {
        return _forceHide;
    }
    public function set forceHide(value:Boolean):void {
        _forceHide = value;
        if(_forceHide)
        {
            isShow = !_forceHide;
        }
    }
    private var _forceHide:Boolean = false;

    public function get waitOtherStop():Boolean {
        return _bWaitOtherStop;
    }
    public function set waitOtherStop(value:Boolean):void {
        _bWaitOtherStop = value;
    }
    private var _bWaitOtherStop:Boolean = false;


    private var _filterTipsList:Array;
    private var _lastUpdateTipsTime:int;
    private var _lastTipsIndex:int;
}
}
