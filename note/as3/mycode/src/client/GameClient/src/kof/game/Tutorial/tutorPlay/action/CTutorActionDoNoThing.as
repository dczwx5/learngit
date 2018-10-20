//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/5.
 */
package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.util.CAssertUtils;

import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.List;
import morn.core.components.Tab;
import morn.core.events.UIEvent;

public class CTutorActionDoNoThing extends CTutorActionBase {

    public function CTutorActionDoNoThing( actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    public override function dispose() : void {
        var comp : Component = this.holeTarget;
        super.dispose();

        if ( comp ) {
            comp.removeEventListener( UIEvent.IMAGE_LOADED, _img_onLoadedEventHandler );
        }
    }

    override protected function startByUIComponent( comp : Component ) : void {
        CAssertUtils.assertNotNull( comp );

        if ( comp is Tab ) {
            startByTab( comp as Tab );
            return;
        } else if ( comp is List ) {
            startByList( comp as List );
            return;
        } else if ( comp is Image ) {
            var img : Image = comp as Image;
            if ( !img.bitmapData ) {
                img.addEventListener( UIEvent.IMAGE_LOADED, _img_onLoadedEventHandler, false, CEventPriority.DEFAULT_HANDLER, true );
            }
        }

        this.holeTarget = comp;
    }

    protected function queryParamAsIdx() : int {
        // resolve the params as idx.
        var idx : int = 0;
        for each( var sParam : String in this._info.actionParams ) {
            if ( !sParam )
                continue;
            idx = parseInt(sParam);
            break;
        }
        return idx;
    }

    protected function startByTab( pTab : Tab ) : void {
        if ( !pTab )
            return;

        var idx : int = this.queryParamAsIdx();

        var child : Component = pTab.getChildByName("item" + idx) as Component;
        if ( child ) {
            this.holeTarget = child;
        } else {
            Foundation.Log.logWarningMsg("默认引导点击配置项" + this._info.ID + "作为Tab并不能找到下标为" +
                    idx + "的UI对象" );
        }
    }

    protected function startByList( pList : List ) : void {
        if ( !pList )
            return;

        var idx : int = this.queryParamAsIdx();

        var child : Component = pList.getCell( idx ) as Component;
        if ( child ) {
            this.holeTarget = child;
        } else {
            Foundation.Log.logWarningMsg("默认引导点击配置项" + this._info.ID + "作为List并不能找到下标为" +
                    idx + "的UI对象" );
        }
    }

    final private function _img_onLoadedEventHandler( event : Event ) : void {
        var pImg : Image = event.currentTarget as Image;
        CAssertUtils.assertNotNull( pImg );
        if ( pImg.url && pImg.bitmapData ) {
            event.currentTarget.removeEventListener( event.type, _img_onLoadedEventHandler );
            this.holeTarget = event.currentTarget as Image;
        }
    }
}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab


