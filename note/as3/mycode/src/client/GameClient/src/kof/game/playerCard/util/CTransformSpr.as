//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.playerCard.util
{

import QFLib.Interface.IDisposable;

import flash.display.DisplayObject;
import flash.display.Sprite;

import kof.game.common.CUIFactory;

/**
	 * 用来处理注册点在左上角的显示对象的变换(位移、缩放、旋转等)
	 * @author sprite
	 * 
	 */	
	public class CTransformSpr extends Sprite implements IDisposable
	{
		protected var _objWidth:Number;
		protected var _objHeight:Number;
		
		protected var _transformObj:DisplayObject;
		
		public function CTransformSpr()
		{
			super();
		}
		
		/**
		 * 设置需要变换的显示对象
		 * @param obj
		 * 
		 */		
		public function set transformObj(obj:DisplayObject):void
		{
			if(obj == null)
			{
				return;
			}

			_transformObj = obj;
			
			this.x = obj.x + objWidth / 2;
			this.y = obj.y + objHeight / 2;

			obj.x = -objWidth/2;
			obj.y = -objHeight/2;
			this.addChild(obj);
		}
		
		public function set objWidth(value:Number):void
		{
			_objWidth = value;
		}
		
		public function get objWidth():Number
		{
			if(_transformObj && _transformObj.width != 0)
			{
				return _transformObj.width;
			}
			
			return _objWidth;
		}
		
		public function set objHeight(value:Number):void
		{
			_objHeight = value;
		}
		
		public function get objHeight():Number
		{
			if(_transformObj && _transformObj.height != 0)
			{
				return _transformObj.height;
			}
			
			return _objHeight;
		}

        /**缩放比例(等同于同时设置scaleX，scaleY)*/
        public function set scale(value:Number):void
        {
            scaleX = scaleY = value;
        }

        public function get scale():Number
        {
            return scaleX;
        }

		public function clear():void
		{
			_transformObj = null;
			_objWidth = 0;
			_objHeight = 0;
		}

		public function dispose():void
		{
			if(_transformObj && _transformObj.parent)
			{
				_transformObj.parent.removeChild(_transformObj);
			}

			_transformObj = null;
			_objWidth = 0;
			_objHeight = 0;

			CUIFactory.disposeDisplayObj(this);
		}
	}
}