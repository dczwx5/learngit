//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial {

import QFLib.Interface.IUpdatable;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.Tutorial.battleTutorPlay.CTutorBattleManager;
import kof.game.Tutorial.data.CTutorData;
import kof.game.Tutorial.event.CTutorEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CAppSystemImp;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.util.CSystemIDBinder;


public class CTutorSystem extends CAppSystemImp implements IUpdatable{
    public function CTutorSystem() {
        super()
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.TUTOR);
    }
    public override function dispose() : void {
        super.dispose();

        var pInstance:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstance) {
            pInstance.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstance);
        }
    }
    override public function initialize():Boolean {
        CSystemIDBinder.bind(KOFSysTags.TUTOR, -4);

        var ret:Boolean = super.initialize();

        ret = ret && this.addBean(_battleManager = new CTutorBattleManager()); // todo : 条件创建, 并非一定会创建, 或后续删除

        ret = ret && this.addBean(_manager = new CTutorManager());
        ret = ret && this.addBean(_uiHandler = new CTutorUIHandler());
        ret = ret && this.addBean(_handler = new CTutorHandler());



        this.registerEventType(CTutorEvent.DATA_EVENT);

        this.registerEventType(CTutorEvent.NET_EVENT_START_BATTLE_TUTOR);
        var pInstance:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstance) {
            pInstance.addEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstance);
        }

        return ret;
    }
    private function _onEnterInstance(e:CInstanceEvent) : void {
        if (manager) {
            manager.hideTutorView();
        }
    }

    override protected function onBundleStart( ctx : ISystemBundleContext ) : void {
        (getHandler( CTutorHandler ) as CTutorHandler).onBundleStart( ctx );
    }

    // ===========================show/hide===========================

    public function update(delta:Number) : void {
        if (netHandler) {
            netHandler.update(delta);
        }
        if (manager) {
            manager.update(delta);
        }
    }

    public function startBattleTutor(battleTutorID:int = 1001) : void {
        // for test
        netHandler.onStartBattleTutor(battleTutorID);
    }
    public function get isPlaying() : Boolean {
        return _manager.isPlaying;
    }
    [Inline]
    public function get isPlayingBattleGuide() : Boolean {
        if (_battleManager) {
            return _battleManager.isPlaying;
        }
        return false;
    }
    // ===========================get/set=============================
    [Inline]
    public function get manager() : CTutorManager { return _manager; }
    [Inline]
    public function get uiHandler() : CTutorUIHandler { return _uiHandler; }
    [Inline]
    public function get netHandler() : CTutorHandler { return _handler; }
    [Inline]
    public function get tutorData() : CTutorData { return _manager.tutorData; }


    private var _battleManager:CTutorBattleManager;

    private var _manager:CTutorManager;
    private var _handler:CTutorHandler;
    private var _uiHandler:CTutorUIHandler;

    private static var _forceNeverCloseKeyPress:Boolean = false;

    [Inline]
    public static function get forceNeverCloseKeyPress():Boolean {
        return _forceNeverCloseKeyPress;
    }
    [Inline]
    public static function set forceNeverCloseKeyPress(value:Boolean):void {
        _forceNeverCloseKeyPress = value;
    }
}
}
