//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/29.
 */
package kof.game.reciprocation {

import QFLib.Utils.StringUtil;

import kof.SYSTEM_ID;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.player.CPlayerSystem;
import kof.ui.CMsgBoxHandler;

/**
 * 花费绑钻不足确认框
 * @author Maniac (maniac@qifun.com)
 */
public class CCostBdDiamondViewHandler extends CViewHandler {

    private var _completeBackFunc : Function;

    public function CCostBdDiamondViewHandler() {
        super( false ); // load view by default to call onInitializeView
    }

    override public function dispose() : void {
        super.dispose();
    }

    public function show( costNum:int, completeBackFunc : Function = null ) : void {

        _completeBackFunc = completeBackFunc;
        //绑钻
        var purpleDiamond:int = playSystem.playerData.currency.purpleDiamond;
        if(costNum > purpleDiamond){
            var haveDiamond:int = playSystem.playerData.currency.purpleDiamond + playSystem.playerData.currency.blueDiamond;
            if(costNum > haveDiamond){
                reciSystem.showMsgAlert(CLang.Get("bangzuan_lanzuan_notEnough"));

                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                return;
            }
            var viewHandler : CMsgBoxHandler = system.getBean( CMsgBoxHandler ) as CMsgBoxHandler;
            viewHandler.show(StringUtil.format(CLang.LANG_00014,costNum,(costNum-purpleDiamond)),completeBackFunc,null,true,null,null,true,"COST_BIND&DIMOND");
        }else{
            if(_completeBackFunc){
                _completeBackFunc();
            }
        }
    }

    private function get playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get reciSystem() : CReciprocalSystem {
        return (system as CReciprocalSystem);
    }

}
}
