//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFormat;

import kof.framework.CViewHandler;

import morn.core.components.Box;
import morn.core.components.Image;
import morn.core.components.Styles;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CDefaultTipViewHandler extends CViewHandler {

    private var _tipBox : Box;
    private var _tipBg : Image;
    private var _tipText : TextField;
    private static const DEFAULT_BG_URL : String = "png.common.tip.default_scale_bg";

    public function CDefaultTipViewHandler() {
        super( true );
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function get additionalAssets() : Array {
        return [
            "common.swf"
        ];
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        App.tip.defaultTipHandler = this._defaultTipHandler;

        _tipBox = new Box();
        _tipBox.addChild( _tipText = new TextField() );
        _tipBox.addChildAt( _tipBg = new Image( DEFAULT_BG_URL ), 0 );

        var pTextFormat : TextFormat = new TextFormat();
        pTextFormat.font = Styles.fontName;
        pTextFormat.size = Styles.fontSize;
        pTextFormat.color = 0xFEFEFE;

        _tipText.defaultTextFormat = pTextFormat;
        _tipText.autoSize = "left";
        _tipText.filters = [ new GlowFilter( 0x0, 1.0, 2.0, 2.0, 1000 ) ];
        _tipText.multiline = true;
        _tipText.x = _tipText.y = 5;
        _tipBg.sizeGrid = "8,8,8,8";
        _tipBg.left = _tipBg.right = _tipBg.top = _tipBg.bottom = 0;

        return true;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        App.tip.defaultTipHandler = null;

        return ret;
    }


    private function _defaultTipHandler( text : String ) : void {
        _tipText.htmlText = text;

        _tipBg.width = _tipText.width + 10;
        _tipBg.height = _tipText.height + 10;

        App.tip.addChild( _tipBox );

        var x:int = _tipBox.stage.mouseX + 10;
        var y:int = _tipBox.stage.mouseY + 15;
        if (x < 0) {
            x = 0;
        } else if (x > _tipBox.stage.stageWidth - App.tip.width) {
            x = _tipBox.stage.stageWidth - App.tip.width;
        }
        if (y < 0) {
            y = 0;
        } else if (y > _tipBox.stage.stageHeight - App.tip.height) {
            y = _tipBox.stage.stageHeight - App.tip.height;
        }

        App.tip.x = x;
        App.tip.y = y;
    }

}
}
