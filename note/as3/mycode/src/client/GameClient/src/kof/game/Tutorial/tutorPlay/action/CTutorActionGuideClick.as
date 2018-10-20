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
import flash.geom.Point;

import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.ui.instance.InstanceNoteUI;
import kof.util.CAssertUtils;

import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.List;
import morn.core.components.Tab;
import morn.core.events.UIEvent;

public class CTutorActionGuideClick extends CTutorActionBase {

    public function CTutorActionGuideClick( actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    public override function dispose() : void {
        var comp : Component = this.holeTarget;
        super.dispose();

        if ( comp ) {
            comp.removeEventListener( MouseEvent.CLICK, _onClickInstanceNoteImageEventHandler );
            comp.removeEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler );
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
        } else if (comp is InstanceNoteUI) {
            (comp as InstanceNoteUI).bg_img.addEventListener( MouseEvent.CLICK, _onClickInstanceNoteImageEventHandler, false, CEventPriority.BINDING, true );
            this.holeTarget =  (comp as InstanceNoteUI).bg_img;
            return ;
        }

//        Foundation.Log.logErrorMsg( "开始显示新手引导指引，指向目标UI组件：" + comp.tag[ CUIComponentTutorHandler.TAG_KEY ] );



        comp.addEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler, false, CEventPriority.BINDING, true );
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
            child.addEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler, false, CEventPriority.BINDING, true );
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
            child.addEventListener(MouseEvent.CLICK, _comp_onMouseClickEventHandler, false, CEventPriority.BINDING, true);
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

    private function _onClickInstanceNoteImageEventHandler( event : MouseEvent ) : void {
        var img:Image = event.currentTarget as  Image;
        // 点的是头像的图片
        // 模拟发的事件没有stageXY
        if (!isNaN(event.stageX) && !isNaN(event.stageY)) {
            if (false == _hitTestItem(img, event.stageX, event.stageY)) {
                return ;
            }
        }


        img.removeEventListener( event.type, _onClickInstanceNoteImageEventHandler );
        _actionValue = true;
        this.holeTarget = null;
    }
    private function _hitTestItem(image:Image, stageX:Number, stageY:Number) : Boolean {
        if (image && image.bitmap && image.bitmap.bitmapData) {
            // 点的是头像的图片
            var p1:Point = new Point(0, 0);
            var p2:Point = new Point(stageX, stageY);
            p2 = image.globalToLocal(p2);

            var isHit:Boolean = image.bitmap.bitmapData.hitTest(p1, 0, p2);
            return isHit;
        }
        return false;
    }

    private function _comp_onMouseClickEventHandler( event : MouseEvent ) : void {
        event.currentTarget.removeEventListener( event.type, _comp_onMouseClickEventHandler );
        _actionValue = true;
        this.holeTarget = null;
    }

    public override function autoPassProcess() : Boolean {
        if (!(super.autoPassProcess())) {
            return false;
        }

        var target:Component = holeTarget;
        if (target) {
            target.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            return true;
        }
        return true;
    }
}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
