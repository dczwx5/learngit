//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/11/3.
 */
package kof.game.artifact.view {

import QFLib.Graphics.RenderCore.starling.utils.DisplayUtil;
import QFLib.Utils.FileType;
import QFLib.Utils.HtmlUtil;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.artifact.*;
import kof.game.artifact.data.CArtifactData;
import kof.game.artifact.data.CArtifactSoulData;
import kof.game.common.CLang;
import kof.table.ArtifactBasics;
import kof.table.ArtifactColour;
import kof.table.ArtifactQuality;
import kof.table.ArtifactSoulInfo;
import kof.ui.master.Artifact.ArtifactSoulUI;

import morn.core.handlers.Handler;

public class CSoulItem {
    private var _system:CArtifactSystem;
    private var _ui:ArtifactSoulUI;
    private var _data:CArtifactSoulData;
    private var _m_pArtifactData:CArtifactData;
    private var _showViewFun:Function;
    private var m_tipsView : CArtifactSoulTipsView = null;
    public function CSoulItem( system:CArtifactSystem, view:ArtifactSoulUI, data:CArtifactSoulData, showViewFun:Function) {
        _system = system;
        _ui = view;
        _showViewFun = showViewFun;
        m_tipsView = new CArtifactSoulTipsView();
        _addEventListeners();
        _ui.uiFrameClipCanUnlock.autoPlay = false;
        _ui.uiFrameClipCanUnlock.stop();
        _ui.uiFrameClipCanUnlock.visible = false;

        _ui.uiFrameClipUnlockSuccess.autoPlay = false;
        _ui.uiFrameClipUnlockSuccess.stop();
        DisplayUtil.removeFromParent(_ui.uiFrameClipUnlockSuccess);

        update(data);
    }

    public function dispose():void {
        _ui.removeEventListener(MouseEvent.CLICK, clickFun);
        _system.removeEventListener(CArtifactEvent.ARTIFACTUPDATE, artifactUpdateFun);
        _system.removeEventListener(CArtifactEvent.ARTIFACT_SOUL_UNLOCK_SUCCESS, _onSoulUnLockSuccess);
        _ui.toolTip = null;
        _ui.uiFrameClipUnlockSuccess.stop();
        _ui.uiFrameClipCanUnlock.stop();
    }

    private function _addEventListeners():void {
        _ui.addEventListener(MouseEvent.CLICK, clickFun, false, 0, true);
        _system.addEventListener(CArtifactEvent.ARTIFACTUPDATE, artifactUpdateFun);
        _system.addEventListener(CArtifactEvent.ARTIFACT_SOUL_UNLOCK_SUCCESS, _onSoulUnLockSuccess);
    }

    private function _onSoulUnLockSuccess( event : CArtifactEvent ) : void {
        if (event.data == _data.artifactSoulID) {
            _playUnLockSuccessEffect();
        }
    }

    private function artifactUpdateFun(e:Event):void{
        _data = (_system.getHandler(CArtifactManager) as CArtifactManager).getSoulData(_data.artifactID,_data.artifactSoulID);
        update(_data);
    }

    public function update(data:CArtifactSoulData):void{
        if (_data != null && _data.artifactID != data.artifactID) {
            _ui.uiFrameClipUnlockSuccess.stop();
            DisplayUtil.removeFromParent(_ui.uiFrameClipUnlockSuccess);
        }
        _data = data;
        _m_pArtifactData = _m_pManager.getArtifactByID(_data.artifactID);
        var isCanUnlock:Boolean = _m_pArtifactData.getIsSoulCanUnLock(_data.artifactSoulID);
        _ui.img.disabled = _data.isLock;
        var soulInfo:ArtifactSoulInfo = data.soulCfg;
        _ui.img.url =_getSoulURL(soulInfo.iconSource);
        if (data.isLock) {
            if (isCanUnlock) {
                _ui.toolTip = CLang.Get("tips_artifact_soul_can_unlock");
            } else {
                var qualityTable : IDataTable = (_system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable( KOFTableConstants.ARTIFACTQUALITY );
                var qualityCfg:ArtifactQuality = qualityTable.findByPrimaryKey(soulInfo.unlockArtifactQuality) as ArtifactQuality;
                var colorCfg:ArtifactColour = _m_pManager.getColorCfg(int(qualityCfg.qualityColour) + 1);
                var obj:Object = {};
                obj.name1 = _m_pArtifactData.htmlName;
                obj.name2 = _m_pArtifactData.baseCfg.artifactName + qualityCfg.qualityName;
                obj.name2 = HtmlUtil.color(obj.name2, colorCfg.colour.replace("0x", "#"));
                _ui.toolTip = CLang.Get("tips_artifact_soul_lock", obj);
            }
        } else {
            _ui.toolTip = new Handler(_onShowTipsFun,[data]);
        }
        _isPlayCanUnLockEffect = _m_pArtifactData.getIsSoulCanUnLock(data.artifactSoulID);
        _ui.uiClipQuality.index = _data.quality;
    }

    private function clickFun(e:MouseEvent):void {
        if(_data.isLock){
            var isCanUnlock:Boolean = _m_pArtifactData.getIsSoulCanUnLock(_data.artifactSoulID);
            if (isCanUnlock) {//可以解锁
                _m_pHandler.artifactSoulUnLock(_data.artifactID, _data.artifactSoulID);
            }
            return;
        }
        if(_showViewFun){
            _showViewFun(_data);
        }
    }

    private function _getSoulURL( sName : String ) : String
    {
        if ( !sName || !sName.length )
            return null;

        return "icon/artifact/soulinfo/" + sName + "." + FileType.PNG;
    }

    private function _onShowTipsFun(data:CArtifactSoulData):void{
        m_tipsView.showTips(data,_system);
    }

    private function set _isPlayCanUnLockEffect(value:Boolean):void {
        _ui.uiFrameClipCanUnlock.visible = value;
        if (value) {
            _ui.uiFrameClipCanUnlock.play();
        } else {
            _ui.uiFrameClipCanUnlock.stop();
        }
    }

    private function _playUnLockSuccessEffect():void {
        _ui.addChild(_ui.uiFrameClipUnlockSuccess);
        _ui.uiFrameClipUnlockSuccess.playFromTo(0, null, new Handler(function():void {
            _ui.uiFrameClipUnlockSuccess.stop();
            DisplayUtil.removeFromParent(_ui.uiFrameClipUnlockSuccess);
        }));
    }


    private function get _m_pManager():CArtifactManager {
        return (_system.getBean(CArtifactManager) as CArtifactManager);
    }

    private function get _m_pHandler():CArtifactHandler {
        return (_system.getHandler(CArtifactHandler) as CArtifactHandler);
    }

    public function get ui() : ArtifactSoulUI {
        return _ui;
    }
}
}
