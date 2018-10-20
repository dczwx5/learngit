//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/20.
 */
package {

import QFLib.Foundation.CMap;

import action.EKeyCode;

import com.greensock.TweenLite;

import config.CTutorConfig;

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import kof.game.KOFSysTags;

import kof.game.Tutorial.CTutorSystem;

import kof.game.core.ITransform;
import kof.game.instance.mainInstance.data.CChapterInstanceData;

import kof.game.instance.mainInstance.data.CInstanceData;
import kof.game.instance.event.CInstanceEvent;
import kof.game.player.data.CPlayerData;
import kof.game.scene.CSceneEvent;
import kof.game.scene.ISceneFacade;
import kof.game.switching.CSwitchingSystem;
import kof.table.InstanceContent;
import kof.util.CAssertUtils;

public class CInstanceProcess {
    public function CInstanceProcess(battleTutor:CBattleTutor) {
        _pBattleTutor = battleTutor;
    }

    public function dispose():void {
        _pBattleTutor.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
        _pBattleTutor.stage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
        var pSceneFacade:ISceneFacade = _pBattleTutor.system.stage.getSystem(ISceneFacade) as ISceneFacade;
        pSceneFacade.removeEventListener(CSceneEvent.HERO_READY, _onHeroReady);
    }

    public function initialize():void {
        _pBattleTutor.stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, false, 9999);
        _pBattleTutor.stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp, false, 9999);
        var pSceneFacade:ISceneFacade = _pBattleTutor.system.stage.getSystem(ISceneFacade) as ISceneFacade;
        pSceneFacade.addEventListener(CSceneEvent.HERO_READY, _onHeroReady);
//        _pBattleTutor.actorHelper.hero.addEventListener()
        _initialValidKey();
        _updateKey();

        _pBattleTutor.systemHelper.instanceSystem.listenEvent(_onInstanceEvent);
    }

    private function _onHeroReady(evt:CSceneEvent):void {
        if (_pBattleTutor.systemHelper.instanceSystem.isMainCity) {
            return ;
        }
        log("|--------------- HERO READY");
        // 进副本之后, fightUI会在收到heroReady之后才处理, 这个时候, 对fightUI内部item的隐藏是没意义的
        // 所以在进副本时, 先把fightUI隐藏, 然后等heroReady过一段时间之后, 再显示fightUI
        TweenLite.delayedCall(1, function () : void {
            updateView();
            _pBattleTutor.viewHelper.showFightUI();
        });
    }

    private function _initialValidKey():void {
        _invalidKeyList = new CMap();
        _preludeInvalidKeyList = new CMap();

        // 序章
        _preludeInvalidKeyList.add(Keyboard.ESCAPE, Keyboard.ESCAPE);

        // 其他
        _invalidKeyList.add(Keyboard.L, Keyboard.L);
        _invalidKeyList.add(Keyboard.W, Keyboard.W);
        _invalidKeyList.add(Keyboard.A, Keyboard.A);
        _invalidKeyList.add(Keyboard.S, Keyboard.S);
        _invalidKeyList.add(Keyboard.D, Keyboard.D);
        _invalidKeyList.add(Keyboard.U, Keyboard.U);
        _invalidKeyList.add(Keyboard.I, Keyboard.I);
        _invalidKeyList.add(Keyboard.O, Keyboard.O);
        _invalidKeyList.add(Keyboard.J, Keyboard.J);
        _invalidKeyList.add(Keyboard.K, Keyboard.K);
        _invalidKeyList.add(Keyboard.SPACE, Keyboard.SPACE);
//        _invalidKeyList.add(Keyboard.Q, Keyboard.Q);
//        _invalidKeyList.add(Keyboard.E, Keyboard.E);
    }

    private function _updateKey():void {
        // 这时副本数据已经有了
        var instanceData:CInstanceData = _pBattleTutor.systemHelper.instanceSystem.instanceData;
        CAssertUtils.assertNotNull(instanceData);

// 受身不处理
//        var playerData:CPlayerData = _pBattleTutor.systemHelper.playerSystem.playerData;
        // 初始可操作按键
//        if (instanceData.eliteInstancePassCount > 0 || playerData.teamData.level >= CTutorConfig.L_OPEN_LEVEL) {
//            _invalidKeyList.remove(Keyboard.L); // 通过精英第一关
//        }

        var pSwitchSystem:CSwitchingSystem = _pBattleTutor.system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
        if (pSwitchSystem) {
            var isTeachingOpen:Boolean = pSwitchSystem.isSystemOpen(KOFSysTags.TEACHING);
            if (isTeachingOpen) {
                _invalidKeyList.remove(Keyboard.L); // 教学开启
            }
        }

        // 剧情副本
        if (instanceData.scenarioInstancePassCount > 0) {// 通过第一关
            _invalidKeyList.remove(Keyboard.W);
            _invalidKeyList.remove(Keyboard.A);
            _invalidKeyList.remove(Keyboard.S);
            _invalidKeyList.remove(Keyboard.D);
            _invalidKeyList.remove(Keyboard.U);
            _invalidKeyList.remove(Keyboard.I);
            _invalidKeyList.remove(Keyboard.O);
            _invalidKeyList.remove(Keyboard.J);
            _invalidKeyList.remove(Keyboard.SPACE);


        }
        if (instanceData.scenarioInstancePassCount > 1) { // 通过第二关
            _invalidKeyList.remove(Keyboard.K);

//            _invalidKeyList.remove(Keyboard.K);

        }
        if (instanceData.scenarioInstancePassCount > 2) { // 通过第三关

        }
        if (instanceData.scenarioInstancePassCount > 3) { // 通过第四关

        }
        if (instanceData.scenarioInstancePassCount > 4) { // 通过第五关

        }
//        if (instanceData.scenarioInstancePassCount > 5) { // 二章第一关
//            _invalidKeyList.remove(Keyboard.Q);
//            _invalidKeyList.remove(Keyboard.E);
//        }
    }

    public function updateView():Boolean {
        if (_pBattleTutor.systemHelper.instanceSystem.isInInstance
                && _pBattleTutor.systemHelper.instanceSystem.isMainCity == false
                && _pBattleTutor.systemHelper.instanceSystem.currentIsPrelude == false
                && _pBattleTutor.systemHelper.instanceSystem.isArena == false) {

                _pBattleTutor.viewHelper.showAllSkillItem();

                for each (var keyCode:uint in _invalidKeyList) {
                    var key:String = EKeyCode.getKeyByKeyCode(keyCode);
                    _pBattleTutor.viewHelper.setSkillItemVisible(key, false);
                }
            _pBattleTutor.viewHelper.instanceProcessViewHandler.otherForceHide = needShowTutor; // 设置
        }

        return true;
    }

    private function _onInstanceEvent(e:CInstanceEvent):void {
        switch (e.type) {
            case CInstanceEvent.EXIT_INSTANCE :
                if (_pBattleTutor.playing()) {
                    _pBattleTutor.stop();
                }
                break;
            case CInstanceEvent.ENTER_INSTANCE :
                _pBattleTutor.viewHelper.setFightUIVisible(false);

                _updateKey();
                updateView();
                break;
        }
    }

    private function _onKeyDown(e:KeyboardEvent):void {
        if (CTutorSystem.forceNeverCloseKeyPress) {
            return ;
        }

        if (_lockAllKey) {
            e.stopImmediatePropagation();
            return ;
        }

        if (_pBattleTutor.systemHelper.instanceSystem.isMainCity) {
            // 不屏蔽操作
        } else if (_pBattleTutor.systemHelper.instanceSystem.currentIsPrelude) {
            // 序章
            if (e.keyCode in _preludeInvalidKeyList) {
                e.stopImmediatePropagation();
            }
        } else if (_pBattleTutor.systemHelper.scenarioSystem.isPlaying) {
            // 不屏蔽操作, 不能放在序章前面, 序章不能按esc
        } else {
            // 其他
            if (e.keyCode in _invalidKeyList) {
                e.stopImmediatePropagation();
            }
        }

        CONFIG::debug {
            if (e.keyCode == Keyboard.M) {
                var transform:ITransform = _pBattleTutor.actorHelper.hero.transform;
                log("|-------hero3Dposition : ", transform.x, transform.y, transform.z);
            }
        }
    }

    private function _onKeyUp(e:KeyboardEvent):void {

    }

    public function removeVaildKeyList(keyList:Array):Boolean {
        for each (var keyCode:uint in keyList) {
            removeVaildKey(keyCode);
        }
        return true;
    }
    public function removeVaildKey(keyCode:uint):Boolean {
        var obj:Object = _invalidKeyList.find(keyCode);
        if (!obj) {
            _invalidKeyList.add(keyCode, keyCode);
        }
        return true;
    }

    // key : Keyboard
    public function addVaildKeyList(keyList:Array):Boolean {
        for each (var keyCode:uint in keyList) {
            addVaildKey(keyCode);
        }
        return true;
    }
    // key : Keyboard
    public function addVaildKey(keyCode:uint):Boolean {
        _invalidKeyList.remove(keyCode);
        return true;
    }

    public function lockAllKey() : Boolean {
        _lockAllKey = true;
        return true;
    }
    public function unLockAllKey() : Boolean {
        _lockAllKey = false;
        return true;
    }

    public function get needShowTutor() : Boolean {
        var instanceData:CInstanceData = _pBattleTutor.systemHelper.instanceSystem.instanceData;
        var record:InstanceContent = _pBattleTutor.systemHelper.instanceSystem.instanceManager.instanceContentRecord;
        if (record) {
            var data:CChapterInstanceData = instanceData.instanceList.getByID(record.ID);
            if (data.isCompleted) {
                return false;
            }
        }

        return isTutorInstance;
    }
    public function get isTutorInstance() : Boolean {
        if (_pBattleTutor.systemHelper.instanceSystem.isMainCity) {
            // 不屏蔽操作
            return false;
        } else if (_pBattleTutor.systemHelper.instanceSystem.currentIsPrelude) {
            // 序章
            return false;
        } else {
            // 其他
            var record:InstanceContent = _pBattleTutor.systemHelper.instanceSystem.instanceManager.instanceContentRecord;
            if (record) {
                var isExist:Boolean = _tutorInstanceID.indexOf(record.ID) != -1;
                return isExist;
            }
        }
        return false;
    }

    private var _tutorInstanceID:Array = [10001, 10002, 10003, 10004, 10005, 10006, 20001];

    private var _pBattleTutor:CBattleTutor;

    private var _invalidKeyList:CMap; // 通用按键黑名单

    private var _preludeInvalidKeyList:CMap; // 序章按键黑名单
    private var _lockAllKey:Boolean = false;
}
}
