//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/31.
 * Time: 9:46
 */
package kof.game.sign {

    import kof.SYSTEM_ID;
    import kof.game.KOFSysTags;
    import kof.game.bundle.CBundleSystem;
    import kof.game.bundle.ISystemBundleContext;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/31
     */
    public class CSignSystem extends CBundleSystem {
        private var _signHandler : CSignHandler = null;
        private var _signViewHandler : CSignViewHandler = null;

        private var _bIsInitialize : Boolean = false;

        public function CSignSystem() {
            super();
        }

        override public function get bundleID() : * {
            return SYSTEM_ID( KOFSysTags.SIGN );
        }

        public override function dispose() : void {
            super.dispose();
            _signHandler = null;
            _signViewHandler = null;
        }

        override public function initialize() : Boolean {
            if ( !super.initialize() )
                return false;
            if ( !_bIsInitialize ) {
                _bIsInitialize = true;
                addBean( _signViewHandler = new CSignViewHandler() );
                addBean( _signHandler = new CSignHandler() );
                this._initialize();
            }
            return _bIsInitialize;
        }

        override protected function onActivated( value : Boolean ) : void {
            super.onActivated( value );
            if ( value ) {
                _signViewHandler.show();
            } else {
                _signViewHandler.close();
            }
        }

        private function _initialize() : void {
            this._signViewHandler = getBean( CSignViewHandler );
            _signViewHandler.closeHandler = new Handler( _closeView );
        }

        private function _closeView() : void {
            this.setActivated( false );
        }

        public function updateSystemRedPoint(bool:Boolean) : void {
            var pSystemBundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                if ( bool ) {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, true );
                } else {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, false );
                }
            }
        }
    }
}
