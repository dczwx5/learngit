//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/4/9
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import flash.display.Stage;
    import flash.events.MouseEvent;

    //
    //
    //
    public class CMouse
    {
        public function CMouse( stage : flash.display.Stage )
        {
            m_theStage = stage;
            m_fLastX = stage.mouseX;
            m_fLastY = stage.mouseY;

            stage.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, _onMouseDown, false, 0, true );
            stage.addEventListener( flash.events.MouseEvent.MOUSE_UP, _onMouseUp, false, 0, true );
            stage.addEventListener( flash.events.MouseEvent.CLICK, _onMouseClick, false, 0, true );
            stage.addEventListener( flash.events.MouseEvent.DOUBLE_CLICK, _onMouseDoubleClick, false, 0, true );
            stage.addEventListener( flash.events.MouseEvent.MOUSE_MOVE, _onMouseMove, false, 0, true );
            stage.addEventListener( flash.events.MouseEvent.MOUSE_WHEEL, _onMouseWheel, false, 0, true );
            stage.addEventListener( flash.events.MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true );
            stage.addEventListener( flash.events.MouseEvent.MOUSE_OUT, _onMouseOut, false, 0, true );
        }

        public virtual function dispose() : void
        {
            // since add listener using weak ref, the following codes should not be needed, however, add them here just for reference
            m_theStage.removeEventListener( flash.events.MouseEvent.MOUSE_DOWN, _onMouseDown );
            m_theStage.removeEventListener( flash.events.MouseEvent.MOUSE_UP, _onMouseUp );
            m_theStage.removeEventListener( flash.events.MouseEvent.CLICK, _onMouseClick );
            m_theStage.removeEventListener( flash.events.MouseEvent.DOUBLE_CLICK, _onMouseDoubleClick );
            m_theStage.removeEventListener( flash.events.MouseEvent.MOUSE_MOVE, _onMouseMove );
            m_theStage.removeEventListener( flash.events.MouseEvent.MOUSE_WHEEL, _onMouseWheel );
            m_theStage.removeEventListener( flash.events.MouseEvent.MOUSE_OVER, _onMouseOver );
            m_theStage.removeEventListener( flash.events.MouseEvent.MOUSE_OUT, _onMouseOut );
        }

        //
        //
        public function get x() : Number
        {
            return m_theStage.mouseX;
        }
        public function get y() : Number
        {
            return m_theStage.mouseY;
        }
        public function get lastX() : Number
        {
            return m_fLastX;
        }
        public function get lastY() : Number
        {
            return m_fLastY;
        }
        public function get target() : Object
        {
            return m_theTarget;
        }
        public function get localX() : Number
        {
            return m_fLocalX;
        }
        public function get localY() : Number
        {
            return m_fLocalY;
        }

        public function get enabled() : Boolean
        {
            return m_bEnabled;
        }
        public function set enabled( value : Boolean ) : void
        {
            m_bEnabled = value;
        }

        //
        // return whether a key has been pressed
        //
        public function isMousePressed() : Boolean
        {
            return m_aBtnPressed[ MOUSE_BTN_DEFAULT ];
        }

        //
        // default method to register callbacks, all key codes call to this 'func : function'
        //
        public function register( sEvent : String, func : Function ) : void
        {
            var vectFunctions : Vector.<Function> = _getFunctionVector( sEvent );
            if( vectFunctions == null )
            {
                vectFunctions = new Vector.<Function>;
                _setFunctionVector( sEvent, vectFunctions );
            }

            if( vectFunctions.indexOf( func ) == -1 ) vectFunctions.push( func );
        }

        //
        // default method to unregister callbacks
        //
        public function unregister( sEvent : String, func : Function ) : void
        {
            var vectFunctions : Vector.<Function> = _getFunctionVector( sEvent );
            if( vectFunctions != null )
            {
                var iIdx : int = vectFunctions.indexOf( func );
                if( iIdx != -1 ) vectFunctions.splice( iIdx, 1 );

                if( vectFunctions.length == 0 )
                {
                    _setFunctionVector( sEvent, null );
                }
            }
        }


        //
        // sending mouse events for simulating user input
        //
        public function sendMouseDownEvent( x : Number, y : Number ) : void
        {
            var mouseEvent : flash.events.MouseEvent = new MouseEvent( flash.events.MouseEvent.MOUSE_DOWN, true, false, x, y );
            _onMouseDown( mouseEvent, true );
        }
        public function sendMouseUpEvent( x : Number, y : Number ) : void
        {
            var mouseEvent : flash.events.MouseEvent = new MouseEvent( flash.events.MouseEvent.MOUSE_UP, true, false, x, y );
            _onMouseUp( mouseEvent, true );
        }
        public function sendMouseClickEvent( x : Number, y : Number ) : void
        {
            var mouseEvent : flash.events.MouseEvent = new MouseEvent( flash.events.MouseEvent.CLICK, true, false, x, y );
            _onMouseClick( mouseEvent, true );
        }
        public function sendMouseDoubleClickEvent( x : Number, y : Number ) : void
        {
            var mouseEvent : flash.events.MouseEvent = new MouseEvent( flash.events.MouseEvent.DOUBLE_CLICK, true, false, x, y );
            _onMouseDoubleClick( mouseEvent, true );
        }
        public function sendMouseMoveEvent( x : Number, y : Number ) : void
        {
            var mouseEvent : flash.events.MouseEvent = new MouseEvent( flash.events.MouseEvent.MOUSE_MOVE, true, false, x, y );
            _onMouseMove( mouseEvent, true );
        }
        public function sendMouseWheelEvent( iDelta : int ) : void
        {
            var mouseEvent : flash.events.MouseEvent = new MouseEvent( flash.events.MouseEvent.MOUSE_WHEEL, true, false, 0, 0, null, false, false, false, false, iDelta );
            _onMouseWheel( mouseEvent, true );
        }
        public function sendMouseOverEvent( x : Number, y : Number ) : void
        {
            var mouseEvent : flash.events.MouseEvent = new MouseEvent( flash.events.MouseEvent.MOUSE_OVER, true, false, x, y );
            _onMouseOver( mouseEvent, true );
        }
        public function sendMouseOutEvent( x : Number, y : Number ) : void
        {
            var mouseEvent : flash.events.MouseEvent = new MouseEvent( flash.events.MouseEvent.MOUSE_OUT, true, false, x, y );
            _onMouseOut( mouseEvent, true );
        }

        //
        //
        //
        private function _onMouseDown( e : flash.events.MouseEvent, bSendEventCalled : Boolean = false ) : void
        {
            if( m_aBtnPressed[ MOUSE_BTN_DEFAULT ] ) return; // already pressed
            m_aBtnPressed[ MOUSE_BTN_DEFAULT ] = true;

            if( m_bEnabled == false ) return;

            if( m_vectMouseDownFunctions )
            {
                if( bSendEventCalled )
                {
                    for each( var fn1 : Function in m_vectMouseDownFunctions ) fn1( e.localX, e.localY );
                }
                else
                {
                    for each( var fn2 : Function in m_vectMouseDownFunctions ) fn2( e.stageX, e.stageY );
                }
            }
        }

        private function _onMouseUp( e : flash.events.MouseEvent, bSendEventCalled : Boolean = false ) : void
        {
            m_aBtnPressed[ MOUSE_BTN_DEFAULT ] = false;
            if( m_bEnabled == false ) return;

            if( m_vectMouseUpFunctions )
            {
                if( bSendEventCalled )
                {
                    for each( var fn1 : Function in m_vectMouseUpFunctions ) fn1( e.localX, e.localY );
                }
                else
                {
                    for each( var fn2 : Function in m_vectMouseUpFunctions ) fn2( e.stageX, e.stageY );
                }
            }
        }

        private function _onMouseClick( e : MouseEvent, bSendEventCalled : Boolean = false ) : void
        {
            if( m_bEnabled == false ) return;

            if( m_vectMouseClickFunctions )
            {
                if( bSendEventCalled )
                {
                    for each( var fn1 : Function in m_vectMouseClickFunctions ) fn1( e.localX, e.localY );
                }
                else
                {
                    for each( var fn2 : Function in m_vectMouseClickFunctions ) fn2( e.stageX, e.stageY );
                }
            }
        }

        private function _onMouseDoubleClick( e : MouseEvent, bSendEventCalled : Boolean = false ) : void
        {
            if( m_bEnabled == false ) return;

            if( m_vectMouseDoubleClickFunctions )
            {
                if( bSendEventCalled )
                {
                    for each( var fn1 : Function in m_vectMouseDoubleClickFunctions ) fn1( e.localX, e.localY );
                }
                else
                {
                    for each( var fn2 : Function in m_vectMouseDoubleClickFunctions ) fn2( e.stageX, e.stageY );
                }
            }
        }

        private function _onMouseMove( e : flash.events.MouseEvent, bSendEventCalled : Boolean = false ) : void
        {
            // local xy would still be a problem when calling sendMouseMoveEvent()
            m_fLocalX = e.localX;
            m_fLocalY = e.localY;

            if( m_bEnabled == false ) return;

            if( m_vectMouseMoveFunctions )
            {
                if( bSendEventCalled )
                {
                    for each( var fn1 : Function in m_vectMouseMoveFunctions ) fn1( e.localX, e.localY );
                }
                else
                {
                    for each( var fn2 : Function in m_vectMouseMoveFunctions ) fn2( e.stageX, e.stageY );
                }
            }

            if( bSendEventCalled )
            {
                m_fLastX = e.localX;
                m_fLastY = e.localY;
            }
            else
            {
                m_fLastX = m_theStage.mouseX;
                m_fLastY = m_theStage.mouseY;
            }
        }

        private function _onMouseWheel( e : flash.events.MouseEvent, bSendEventCalled : Boolean = false ) : void
        {
            if( m_bEnabled == false ) return;

            if( m_vectMouseWheelFunctions )
            {
                for each( var fn : Function in m_vectMouseWheelFunctions ) fn( e.delta );
            }
        }

        private function _onMouseOver( e : flash.events.MouseEvent, bSendEventCalled : Boolean = false ) : void
        {
            m_theTarget = e.target;

            if( m_bEnabled == false ) return;

            if( m_vectMouseOverFunctions )
            {
                if( bSendEventCalled )
                {
                    for each( var fn1 : Function in m_vectMouseOverFunctions ) fn1( e.localX, e.localY );
                }
                else
                {
                    for each( var fn2 : Function in m_vectMouseOverFunctions ) fn2( e.stageX, e.stageY );
                }
            }
        }

        private function _onMouseOut( e : flash.events.MouseEvent, bSendEventCalled : Boolean = false ) : void
        {
            m_theTarget = null;

            if( m_bEnabled == false ) return;

            if( m_vectMouseOutFunctions )
            {
                if( bSendEventCalled )
                {
                    for each( var fn1 : Function in m_vectMouseOutFunctions ) fn1( e.localX, e.localY );
                }
                else
                {
                    for each( var fn2 : Function in m_vectMouseOutFunctions ) fn2( e.stageX, e.stageY );
                }
            }
        }

        private function _getFunctionVector( sEvent : String ) : Vector.<Function>
        {
            if( sEvent == flash.events.MouseEvent.MOUSE_DOWN ) return m_vectMouseDownFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_UP ) return m_vectMouseUpFunctions;
            else if( sEvent == flash.events.MouseEvent.CLICK ) return m_vectMouseClickFunctions;
            else if( sEvent == flash.events.MouseEvent.DOUBLE_CLICK ) return m_vectMouseDoubleClickFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_MOVE ) return m_vectMouseMoveFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_WHEEL ) return m_vectMouseWheelFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_OVER ) return m_vectMouseOverFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_OUT ) return m_vectMouseOutFunctions;
            return null;
        }
        private function _setFunctionVector( sEvent : String, vectFunctions : Vector.<Function> ) : void
        {
            if( sEvent == flash.events.MouseEvent.MOUSE_DOWN ) m_vectMouseDownFunctions = vectFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_UP ) m_vectMouseUpFunctions = vectFunctions;
            else if( sEvent == flash.events.MouseEvent.CLICK ) m_vectMouseClickFunctions = vectFunctions;
            else if( sEvent == flash.events.MouseEvent.DOUBLE_CLICK ) m_vectMouseDoubleClickFunctions = vectFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_MOVE ) m_vectMouseMoveFunctions = vectFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_WHEEL ) m_vectMouseWheelFunctions = vectFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_OVER ) m_vectMouseOverFunctions = vectFunctions;
            else if( sEvent == flash.events.MouseEvent.MOUSE_OUT ) m_vectMouseOutFunctions = vectFunctions;
        }

        //
        //
        private const MOUSE_BTN_DEFAULT : int = 0;

        private var m_aBtnPressed : Array = [];
        private var m_theTarget : Object = null;
        private var m_fLastX : Number = 0;
        private var m_fLastY : Number = 0;
        private var m_fLocalX : Number = 0;
        private var m_fLocalY : Number = 0;

        private var m_vectMouseDownFunctions : Vector.<Function> = null;
        private var m_vectMouseUpFunctions : Vector.<Function> = null;
        private var m_vectMouseClickFunctions : Vector.<Function> = null;
        private var m_vectMouseDoubleClickFunctions : Vector.<Function> = null;
        private var m_vectMouseMoveFunctions : Vector.<Function> = null;
        private var m_vectMouseWheelFunctions : Vector.<Function> = null;
        private var m_vectMouseOverFunctions : Vector.<Function> = null;
        private var m_vectMouseOutFunctions : Vector.<Function> = null;

        private var m_theStage : flash.display.Stage;
        private var m_bEnabled : Boolean = true;

    }

}