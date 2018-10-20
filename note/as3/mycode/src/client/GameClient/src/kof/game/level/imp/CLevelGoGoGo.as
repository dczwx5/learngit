//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/8/31.
 */
package kof.game.level.imp {
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.game.level.CLevelManager;
import kof.ui.CUISystem;
import kof.ui.CGlobalViewHandler;

public class CLevelGoGoGo implements IDisposable, IUpdatable{
    public function CLevelGoGoGo(levelManager:CLevelManager) {
        _levelManager = levelManager;
        _showGoTime = STATE_NONE_GO;

    }

    public function dispose() : void {
        clear();
        _levelManager = null;
    }
    public function clear() : void {
        _showGoTime = STATE_NONE_GO;
        if (_levelManager && _levelManager.system && _levelManager.system.stage) {
            var uisystem:CUISystem = _levelManager.system.stage.getSystem(CUISystem) as CUISystem;
            if (uisystem) {
                var view:CGlobalViewHandler = uisystem.getBean(CGlobalViewHandler) as CGlobalViewHandler;
                if (view) view.hideGo();
            }
        }
    }
    public function update(delta:Number) : void {
        if (STATE_NONE_GO == _showGoTime) return ;
        if (_levelManager.isStart == false) return ;

        if (_levelManager.isPlayingScenario) {
            if (_showGoTime == STATE_PLAYING_GO) {
                _showGoTime = STATE_WAIT_SCENARIO;
                (_levelManager.system.stage.getSystem(CUISystem).getBean(CGlobalViewHandler) as CGlobalViewHandler).hideGo();
            }
        } else {
            if (_showGoTime > STATE_NONE_GO) {
                _showGoTime += delta*1000;
                if (_showGoTime >= 1000) {
                    (_levelManager.system.stage.getSystem(CUISystem).getBean(CGlobalViewHandler) as CGlobalViewHandler).showGo(_isRight);
                    _showGoTime = STATE_PLAYING_GO;
                }
            } else if (STATE_WAIT_SCENARIO == _showGoTime) {
                (_levelManager.system.stage.getSystem(CUISystem).getBean(CGlobalViewHandler) as CGlobalViewHandler).showGo(_isRight);
                _showGoTime = STATE_PLAYING_GO;
            }
        }

    }

    public function show(isRight:Boolean) : void {
        _isRight = isRight;
        _showGoTime = STATE_START_GO;
    }
    public function hide() : void {
        _showGoTime = STATE_NONE_GO;
        (_levelManager.system.stage.getSystem(CUISystem).getBean(CGlobalViewHandler) as CGlobalViewHandler).hideGo();

    }
    private const STATE_START_GO:int = 0;
    private const STATE_NONE_GO:int = -1;
    private const STATE_PLAYING_GO:int = -2;
    private const STATE_WAIT_SCENARIO:int = -3;
    private var _showGoTime:int; // 显示gogog时间, -1 : 不显示gogogo, 大于等于0 : 等待显示gogogo, 大于1000 显示gogogo,
    private var _levelManager:CLevelManager;

    private var _isRight:Boolean;

}
}
