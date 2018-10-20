//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/1.
 */
package kof.game.common.view.component {

import kof.framework.CAppSystem;
import kof.game.audio.IAudio;
import kof.game.common.view.CViewBase;

public class CPlayAudioCompoent extends CUICompoentBase {
    public function CPlayAudioCompoent(view:CViewBase, system:CAppSystem) {
        super(view);
        _system = system;
    }
    public override function dispose() : void {
        super.dispose();
        _system = null;
    }

    public function play(soundPath:String) : void {
        var audio:IAudio = _system.stage.getSystem( IAudio ) as IAudio;
        audio.playAudioByPath(soundPath, 1, 0);
    }

    private var _system:CAppSystem;
}
}
