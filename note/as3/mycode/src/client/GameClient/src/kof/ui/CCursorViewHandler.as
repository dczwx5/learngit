//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import flash.display.BitmapData;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.ui.MouseCursorData;

import kof.framework.CAppSystem;
import kof.framework.CViewHandler;

/**
 * 鼠标样式控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCursorViewHandler extends CViewHandler {

    public function CCursorViewHandler() {
        super( true ); // load view by default to call onInitializeView
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        var ret : Boolean = super.onInitializeView();
        if ( ret ) {
            if ( !Mouse.supportsCursor )
                return false;

            var pData : MouseCursorData = new MouseCursorData();
            pData.data = new Vector.<BitmapData>( 1, true );
            pData.data[ 0 ] = App.asset.getBitmapData( "png.common.mouse.normal" ) as BitmapData;
            pData.frameRate = 1;

            Mouse.registerCursor( MouseCursor.ARROW, pData );
            Mouse.registerCursor( MouseCursor.BUTTON, pData );
        }

        return ret;
    }

    override protected function get additionalAssets() : Array {
        return [ "common.swf" ];
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        Mouse.unregisterCursor( MouseCursor.ARROW );

        return ret;
    }

    override protected virtual function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );

        Mouse.cursor = MouseCursor.ARROW;
    }

}
}
