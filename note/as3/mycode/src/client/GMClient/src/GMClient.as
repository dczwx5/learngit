//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/6/2.
 */
package {

import flash.display.Sprite;

import kof.framework.CAppStage;
import kof.game.gm.CGmSystem;

public class GMClient extends Sprite{
    public function GMClient() {
    }

    public function startFun(stage:CAppStage):void{
        stage.addSystem( new CGmSystem() );
    }
}
}
