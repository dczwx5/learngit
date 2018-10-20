//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/5/8.
 */
package kof.game.teaching {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;

//教学入口
public class CTeachingMainInletSystem extends CBundleSystem{
    public function CTeachingMainInletSystem() {
        super(  );
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.TEACHING_ZHUJIEMIAN );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CTeachingInstanceViewHandler = (stage.getSystem(CTeachingInstanceSystem) as CTeachingInstanceSystem).getHandler( CTeachingInstanceViewHandler ) as CTeachingInstanceViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CTeachingInstanceViewHandler isn't instance." );
            return;
        }
        
        var bundleCtx:ISystemBundleContext = this.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.TEACHING));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, value);
    }

    override public function initialize() : Boolean {
        _addListeners();
        return super.initialize();
    }

    private function _addListeners():void
    {
        this.stage.getSystem(CBagSystem).addEventListener(CBagEvent.BAG_UPDATE, updateSystem);
        this.stage.getSystem(CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,updateSystem);
    }

    private function _removeListeners():void
    {
        this.stage.getSystem(CBagSystem).removeEventListener(CBagEvent.BAG_UPDATE, updateSystem);
        this.removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,updateSystem);
    }

    private function updateSystem(e:Event = null):void{
        var level:int = (this.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.level;
        var manager:CTeachingInstanceManager = (this.stage.getSystem(CTeachingInstanceSystem).getHandler(CTeachingInstanceManager) as CTeachingInstanceManager);
        var arr:Array = manager.getTeachingType(2);
        var date:Object = manager.getTeachingDataByID(arr[arr.length - 1].ID);
        if(level > 35 || (date && date.isReward)){
            _removeListeners();
            ctx.unregisterSystemBundle(this);
            return;
        }
        onRedPoint();
    }

    override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        super.onBundleStart( pCtx );
        updateSystem();
    }

    public function onRedPoint( ):void {
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext ) {
            var manager:CTeachingInstanceManager = (this.stage.getSystem(CTeachingInstanceSystem).getHandler(CTeachingInstanceManager) as CTeachingInstanceManager);
            var bool:Boolean = manager.showRedPoint(1) || manager.showRedPoint(2);
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, bool);
        }
    }
}
}
