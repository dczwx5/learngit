//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/11/4.
 * Time: 14:36
 */
package kof.game.clubBoss.view {

import kof.ui.master.clubBoss.RuleDescUI;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/11/4
 */
public class CCBRuleView {
    private var _mainView : CCBMainView = null;
    private var _ruleUI : RuleDescUI = null;

    public function CCBRuleView( mainView : CCBMainView ) {
        this._mainView = mainView;
        this._ruleUI = new RuleDescUI();
        _init();
    }

    private function _init() : void {

    }

    public function show() : void {
        this._mainView.uiContainer.addPopupDialog( this._ruleUI );
    }
}
}
