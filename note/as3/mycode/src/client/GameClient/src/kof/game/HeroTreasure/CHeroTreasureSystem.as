//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-05-28.
 */
package kof.game.HeroTreasure {

import kof.SYSTEM_ID;
import kof.game.HeroTreasure.enum.EHeroTreasureActivityState;
import kof.game.KOFSysTags;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.bundle.CBundleSystem;
import kof.message.Activity.ActivityChangeResponse;

import morn.core.handlers.Handler;

/**
 *@author Demi.Liu
 *@data 2018-05-28
 */
public class CHeroTreasureSystem extends CBundleSystem {
    private var m_bInitialized : Boolean;

    private var _pHeroTreasureManager : CHeroTreasureManager;

    private var _pHeroTreasureHandler : CHeroTreasureHandler;

    private var _pHeroTreasureViewHandler : CHeroTreasureViewHandler;

    public function CHeroTreasureSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }

    override public function dispose() : void {
        super.dispose();
        _pHeroTreasureManager = null;
        _pHeroTreasureHandler = null;
        _pHeroTreasureViewHandler = null;
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pHeroTreasureManager = new CHeroTreasureManager() );
            this.addBean( _pHeroTreasureHandler = new CHeroTreasureHandler() );
            this.addBean( _pHeroTreasureViewHandler = new CHeroTreasureViewHandler() );
        }

        _pHeroTreasureViewHandler.closeHandler = new Handler( _onViewClosed );

        //this._addEventListener();
        return m_bInitialized;
    }

//    private function _addEventListener() : void {
//        stage.getSystem(CActivityHallSystem).addEventListener(CActivityHallEvent.ActivityStateChanged, _onActivityStateRespone);
//    }

//    private function _onActivityStateRespone(event:CActivityHallEvent):void{
//        var response:ActivityChangeResponse = event.data as ActivityChangeResponse;
//        if(!response) return;
//        if(response.activityID == 24)
//        {
//            //1准备中2进行中3已完成4已结束5已关闭/
//            _pHeroTreasureManager.curActivityId = response.activityID;
//            _pHeroTreasureManager.curActivityState = response.state;
//
//            if(response.state >= EHeroTreasureActivityState.ACTIVITY_STATE_PREPARE && response.state < EHeroTreasureActivityState.ACTIVITY_STATE_END){
//                _pHeroTreasureManager.openHeroTreasureActivity();
//            }else if(response.state == EHeroTreasureActivityState.ACTIVITY_STATE_CLOSE || response.state == EHeroTreasureActivityState.ACTIVITY_STATE_END){
//                _pHeroTreasureManager.closeHeroTreasureActivity();
//                _pHeroTreasureManager.curActivityId = 0;
//            }
//        }
//    }

    public function onViewClosed() : void {
        this.setActivated( false );
    }

    public function closeHeroTreasureActivity() : void {
        this.ctx.stopBundle(this);
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CHeroTreasureViewHandler = this.getHandler( CHeroTreasureViewHandler ) as CHeroTreasureViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CHeroTreasureViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.HERO_TREASURE );
    }

}
}
