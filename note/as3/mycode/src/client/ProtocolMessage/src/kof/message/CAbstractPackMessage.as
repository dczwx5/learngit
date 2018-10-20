//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.message {


/**
 * 抽象的封包消息体
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAbstractPackMessage {

    //----------------------------------
    // Categories
    //----------------------------------

    public static const REQUEST : int = 0;
    public static const RESPONSE : int = 1;
    public static const EVENT : int = 2;

    /**
     * Creates a new AbstractPackMessage.
     */
    public function CAbstractPackMessage( idToken : Number = NaN, category : int = REQUEST ) {
        super();

        if ( !isNaN( idToken ) )
            this.m_idToken = idToken;

        if ( !(category == REQUEST || category == RESPONSE || category == EVENT) )
            throw new Error( "category invalid: " + category );

        this.m_category = category;
    }

    //----------------------------------
    // token in kof_message namespace
    // kof_message namespace 用来避免子类命名冲突
    //----------------------------------

    /** @private */
    private var m_idToken : uint;

    /** @private */
    kof_message function get token() : uint {
        return m_idToken;
    }

    /** @private */
    kof_message function set token( value : uint ) : void {
        m_idToken = value;
    }

    /** @private */
    private var m_category : int;

    /** @private */
    kof_message function get category() : int {
        return m_category;
    }

    /** @private */
    kof_message function set category( value : int ) : void {
        m_category = value;
    }

    public function decode( data : Array ) : void {
        // NOOP.
    }

    public function encode( data : Array ) : Array {
        // NOOP.
        return null;
    }

}
}
