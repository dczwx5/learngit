//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/4/8
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    //
    //
    //
    public class CKeyboard
    {
        public function CKeyboard( stage : flash.display.Stage )
        {
            m_theStage = stage;

            if( s_setKeyboards.count == 0 )
            {
                m_theStage.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, CKeyboard._onKeyboardDown, false, 0, true );
                m_theStage.addEventListener( flash.events.KeyboardEvent.KEY_UP, CKeyboard._onKeyboardUp, false, 0, true );
                m_theStage.addEventListener( Event.DEACTIVATE, CKeyboard._onStageDeactivate, false, 0, true );
            }
            s_setKeyboards.add( this );
        }

        public virtual function dispose() : void
        {
            s_setKeyboards.remove( this );
            if( s_setKeyboards.count == 0 )
            {
                // since add listener using weak ref, the following codes should not be needed, however, add them here just for reference
                m_theStage.removeEventListener( flash.events.KeyboardEvent.KEY_DOWN, CKeyboard._onKeyboardDown );
                m_theStage.removeEventListener( flash.events.KeyboardEvent.KEY_UP, CKeyboard._onKeyboardUp );
                m_theStage.removeEventListener( Event.DEACTIVATE, CKeyboard._onStageDeactivate );
            }
        }

        //
        //
        [Inline]
        final public function get enabled() : Boolean
        {
            return m_bEnabled;
        }
        [Inline]
        final public function set enabled( value : Boolean ) : void
        {
            m_bEnabled = value;
            _cleanUpKeyPressedStates();
        }

        [Inline]
        final public function get exclusive() : Boolean
        {
            return ( s_theExclusiveKeyboard == this ) ? true : false;
        }
        [Inline]
        final public function set exclusive( bActive : Boolean ) : void
        {
            if( bActive )
            {
                _setActiveKeyboard( this );
            }
            else
            {
                _setActiveKeyboard( null );
            }
        }

        //
        // return whether a key has been pressed
        //
        [Inline]
        final public function isKeyPressed( nKeyCode : uint ) : Boolean // key code: Keyboard.XXX
        {
            return m_aKeyPressedState[ nKeyCode ];
        }

        //
        // default method to register callbacks, all key codes call to this 'func : function'
        // callback format: onKeyDown( keyCode : int ) : void
        //
        public function register( bKeyDown : Boolean, func : Function ) : void
        {
            var vectFunctions : Vector.<Function> = bKeyDown ? m_vectDefaultKeyDownFunctions : m_vectDefaultKeyUpFunctions;
            if( vectFunctions == null )
            {
                vectFunctions = new Vector.<Function>;
                if( bKeyDown ) m_vectDefaultKeyDownFunctions = vectFunctions;
                else m_vectDefaultKeyUpFunctions = vectFunctions;
            }

            if( vectFunctions.indexOf( func ) == -1 ) vectFunctions.push( func );
        }

        //
        // default method to unregister callbacks
        //
        public function unregister( bKeyDown : Boolean, func : Function ) : void
        {
            var vectFunctions : Vector.<Function> = bKeyDown ? m_vectDefaultKeyDownFunctions : m_vectDefaultKeyUpFunctions;
            if( vectFunctions != null )
            {
                var iIdx : int = vectFunctions.indexOf( func );
                if( iIdx != -1 ) vectFunctions.splice( iIdx, 1 );

                if( vectFunctions.length == 0 )
                {
                    if( bKeyDown ) m_vectDefaultKeyDownFunctions = null;
                    else m_vectDefaultKeyUpFunctions = null;
                }
            }
        }

        //
        // method to register a specified key code to a callback
        // callback format: onKeyDown( keyCode : int ) : void
        //
        public function registerKeyCode( bKeyDown : Boolean, nKeyCode : uint, func : Function ) : void
        {
            var theMap : CMap = bKeyDown ? m_mapKeyDownFunctions : m_mapKeyUpFunctions;
            var vectFunctions : Vector.<Function> = theMap.find( nKeyCode ) as Vector.<Function>;

            if( vectFunctions == null )
            {
                vectFunctions = new Vector.<Function>;
                theMap.add( nKeyCode, vectFunctions );
            }

            if( vectFunctions.indexOf( func ) == -1 ) vectFunctions.push( func );
        }

        //
        // method to unregister a specified key code to a callback
        //
        public function unregisterKeyCode( bKeyDown : Boolean, nKeyCode : uint, func : Function ) : void
        {
            var theMap : CMap = bKeyDown ? m_mapKeyDownFunctions : m_mapKeyUpFunctions;
            var vectFunctions : Vector.<Function> = theMap.find( nKeyCode );

            if( vectFunctions != null )
            {
                var iIdx : int = vectFunctions.indexOf( func );
                if( iIdx != -1 ) vectFunctions.splice( iIdx, 1 );
            }
        }

        //
        private function _onKeyDown( e:flash.events.KeyboardEvent ) : void
        {
            if( m_bEnabled == false ) return;

            var nCode : uint = e.keyCode;
            if( m_aKeyPressedState[ nCode ] ) return; // already pressed
            m_aKeyPressedState[ nCode ] = true;

            var vectFunctions : Vector.<Function> = m_mapKeyDownFunctions.find( nCode );
            if( vectFunctions != null )
            {
                for each( var fn1 : Function in vectFunctions ) fn1( nCode );
            }

            if( m_vectDefaultKeyDownFunctions )
            {
                for each( var fn2 : Function in m_vectDefaultKeyDownFunctions ) fn2( nCode );
            }
        }

        private function _onKeyUp( e:flash.events.KeyboardEvent ) : void
        {
            if( m_bEnabled == false ) return;

            var nCode : uint = e.keyCode;
            if( m_aKeyPressedState[ nCode ] == false ) return; // already unpressed
            m_aKeyPressedState[ nCode ] = false;

            var vectFunctions : Vector.<Function> = m_mapKeyUpFunctions.find( nCode );
            if( vectFunctions != null )
            {
                for each( var fn1 : Function in vectFunctions ) fn1( nCode );
            }

            if( m_vectDefaultKeyUpFunctions )
            {
                for each( var fn2 : Function in m_vectDefaultKeyUpFunctions ) fn2( nCode );
            }
        }

        private function _cleanUpKeyPressedStates() : void
        {
            // send all key up event
            for( var nKeyCode : uint = 0; nKeyCode < m_aKeyPressedState.length; nKeyCode++ )
            {
                if( m_aKeyPressedState[ nKeyCode ] )
                {
                    sendKeyUpEvent( nKeyCode );
                }
            }
        }

        //
        // static functions
        //
        [Inline]
        public static function isKeyPressed( nKeyCode : uint ) : Boolean // key code: Keyboard.XXX
        {
            return m_aKeyPressed[ nKeyCode ];
        }

        //
        // sending key events for simulating user input ( key down and up )
        //
        //[Inline]
        public static function sendKeyStrokeEvent( nKeyCode : uint, nCharCode : uint = 0,
                                                   bCtrl : Boolean = false, bAlt : Boolean = false, bShift : Boolean = false ) : void
        {
            _onKeyboardDown( new flash.events.KeyboardEvent( KeyboardEvent.KEY_DOWN, true, false, nCharCode, nKeyCode, 0, bCtrl, bAlt, bShift ) );
            _onKeyboardUp( new flash.events.KeyboardEvent( KeyboardEvent.KEY_UP, true, false, nCharCode, nKeyCode, 0, bCtrl, bAlt, bShift ) );
        }
        //[Inline]
        public static function sendKeyDownEvent( nKeyCode : uint, nCharCode : uint = 0,
                                                 bCtrl : Boolean = false, bAlt : Boolean = false, bShift : Boolean = false ) : void
        {
            _onKeyboardDown( new flash.events.KeyboardEvent( KeyboardEvent.KEY_DOWN, true, false, nCharCode, nKeyCode, 0, bCtrl, bAlt, bShift ) );
        }
        //[Inline]
        public static function sendKeyUpEvent( nKeyCode : uint, nCharCode : uint = 0,
                                               bCtrl : Boolean = false, bAlt : Boolean = false, bShift : Boolean = false ) : void
        {
            _onKeyboardUp( new flash.events.KeyboardEvent( KeyboardEvent.KEY_UP, true, false, nCharCode, nKeyCode, 0, bCtrl, bAlt, bShift ) );
        }

        [Inline]
        public static function get activeKeyboard() : CKeyboard
        {
            return s_theExclusiveKeyboard;
        }

        //
        private static function _onKeyboardDown( e:flash.events.KeyboardEvent ) : void
        {
            var nCode : uint = e.keyCode;
            if( m_aKeyPressed[ nCode ] ) return; // already pressed
            m_aKeyPressed[ nCode ] = true;

            if( s_theExclusiveKeyboard != null )
            {
                s_theExclusiveKeyboard._onKeyDown( e );
            }
            else
            {
                for each( var kb : CKeyboard in s_setKeyboards )
                {
                    kb._onKeyDown( e );
                }
            }
        }

        private static function _onKeyboardUp( e:flash.events.KeyboardEvent ) : void
        {
            var nCode : uint = e.keyCode;
            if( m_aKeyPressed[ nCode ] == false ) return; // already unpressed
            m_aKeyPressed[ nCode ] = false;

            if( s_theExclusiveKeyboard != null )
            {
                s_theExclusiveKeyboard._onKeyUp( e );
            }
            else
            {
                for each( var kb : CKeyboard in s_setKeyboards )
                {
                    kb._onKeyUp( e );
                }
            }
        }

        private static function _onStageDeactivate( e:Event ) : void
        {
            for each( var kb : CKeyboard in s_setKeyboards )
            {
                kb._cleanUpKeyPressedStates();
            }
        }

        private static function _setActiveKeyboard( toKeyboard : CKeyboard ) : void
        {
            if( s_theExclusiveKeyboard == toKeyboard ) return ;

            if( s_theExclusiveKeyboard != null ) s_theExclusiveKeyboard._cleanUpKeyPressedStates();
            s_theExclusiveKeyboard = toKeyboard;
            if( s_theExclusiveKeyboard != null ) s_theExclusiveKeyboard._cleanUpKeyPressedStates();

            for each( var kb : CKeyboard in s_setKeyboards )
            {
                kb._cleanUpKeyPressedStates();
            }
        }


        //
        //
        private static var s_theExclusiveKeyboard : CKeyboard = null;
        private static var s_setKeyboards : CSet = new CSet();
        private static var m_aKeyPressed : Array = [];

        private var m_aKeyPressedState : Array = [];
        private var m_mapKeyDownFunctions : CMap = new CMap();
        private var m_mapKeyUpFunctions : CMap = new CMap();

        private var m_vectDefaultKeyDownFunctions : Vector.<Function> = null;
        private var m_vectDefaultKeyUpFunctions : Vector.<Function> = null;

        private var m_theStage : flash.display.Stage;
        private var m_bEnabled : Boolean = true;

    }

}