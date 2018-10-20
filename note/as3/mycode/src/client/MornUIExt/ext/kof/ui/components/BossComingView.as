//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/9/22.
 */
package kof.ui.components {

import morn.core.components.View;

public class BossComingView extends View {
    public function BossComingView() {
        super();
    }

    public function get tags() : int {
        return _tags;
    }
    public function set tags(v:int) : void {
        _tags = v;
    }

    public function updata():void{
        
    }

    private var _tags:int;

}
}
