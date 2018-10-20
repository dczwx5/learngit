// =================================================================================================
//
//	Starling Framework
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package QFLib.Graphics.RenderCore.starling.core
{
    import flash.display.Sprite;
    import flash.system.System;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import QFLib.Graphics.RenderCore.manager.FontManager;
    
    import QFLib.Graphics.RenderCore.starling.display.Sprite;
    import QFLib.Graphics.RenderCore.starling.events.EnterFrameEvent;
    import QFLib.Graphics.RenderCore.starling.events.Event;
    
    /** A small, lightweight box that displays the current framerate, memory consumption and
     *  the number of draw calls per frame. The display is updated automatically once per frame. */
    internal class StatsDisplay extends QFLib.Graphics.RenderCore.starling.display.Sprite
    {
        private const UPDATE_INTERVAL:Number = 0.5;
        
        private var mFrameCount:int = 0;
        private var mTotalTime:Number = 0;
        
        private var mFps:Number = 0;
        private var mMemory:Number = 0;
        private var mDrawCount:int = 0;
        
        /** Creates a new Statistics Box. */
		
		private var _container:flash.display.Sprite;
		private var _text:flash.text.TextField;
		
		private const _textHandlerList:Array = [];
		
        public function StatsDisplay()
        {
			_container = new flash.display.Sprite();
			
			_text = new flash.text.TextField();
			FontManager.applyGameFont(_text);
			
			var tf:TextFormat = _text.defaultTextFormat;
			tf.size = 12;
			tf.color = 0xffffff;
			_text.defaultTextFormat = tf;
			_text.setTextFormat(tf);
			_text.multiline = true;
			_text.wordWrap = true;
			_text.width = 80;
			_text.height = 40;
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.background = true;
			_text.backgroundColor = 0;
			_container.addChild(_text);
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        }
		
		public function addTextHandler(handler:Function):void
		{
			if (_textHandlerList.indexOf(handler) == -1)
			{
				_textHandlerList.push(handler);
			}
		}
		
		public function removeTextHandler(handler:Function = null):void
		{
			var idx:int = _textHandlerList.indexOf(handler);
			if (idx != -1) _textHandlerList.splice(idx, 1);
		}
        
        private function onAddedToStage():void
        {
			Starling.current.nativeStage.addChild(_container);
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            mTotalTime = mFrameCount = 0;
            update();
        }
        
        private function onRemovedFromStage():void
        {
			Starling.current.nativeStage.removeChild(_container);
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(event:EnterFrameEvent):void
        {
            mTotalTime += event.passedTime;
            mFrameCount++;
            
            if (mTotalTime > UPDATE_INTERVAL)
            {
                update();
                mFrameCount = mTotalTime = 0;
            }
        }
        
        /** Updates the displayed values. */
        public function update():void
        {
            mFps = mTotalTime > 0 ? mFrameCount / mTotalTime : 0;
            mMemory = System.totalMemory * 0.000000954; // 1.0 / (1024*1024) to convert to MB
            
			var text:String = "FPS: " + mFps.toFixed(mFps < 100 ? 1 : 0) + 
                            "\nMEM: " + mMemory.toFixed(mMemory < 100 ? 1 : 0) +
                            "\nDRW: " + (mTotalTime > 0 ? mDrawCount : mDrawCount); // ignore self 
			
			for each (var handle:Function in _textHandlerList)
			{
				text += handle(text);
			}
			
			_text.text = text;
        }
        
        public override function render(support:RenderSupport, parentAlpha:Number):void
        {
            // The display should always be rendered with two draw calls, so that we can
            // always reduce the draw count by that number to get the number produced by the 
            // actual content.
            
            support.finishQuadBatch();
            super.render(support, parentAlpha);
        }
        
        /** The number of Stage3D draw calls per second. */
        public function get drawCount():int { return mDrawCount; }
        public function set drawCount(value:int):void { mDrawCount = value; }
        
        /** The current frames per second (updated twice per second). */
        public function get fps():Number { return mFps; }
        public function set fps(value:Number):void { mFps = value; }
        
        /** The currently required system memory in MB. */
        public function get memory():Number { return mMemory; }
        public function set memory(value:Number):void { mMemory = value; }
    }
}