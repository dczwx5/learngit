//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 10:12
 */
package kof.game.talent.talentFacade.talentSystem.mediator {

    import kof.game.talent.talentFacade.talentSystem.view.CAbstractTalentView;

    public class CAbstractTalentMediator {
    public function CAbstractTalentMediator() {
    }

    public function contact(tanleView:CAbstractTalentView,type:String,data:Object=null):void
    {
        throw new Error("没有实现此方法");
    }
}
}
