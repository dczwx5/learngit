//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.network.impl {

import kof.framework.network.INetworkMessageBindingKey;

[ExcludeClass]
/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSimpleNetworkMessageBindingKey implements INetworkMessageBindingKey {

    public function CSimpleNetworkMessageBindingKey(forClass:Class = null,
                                                    forNamed:String = null,
                                                    forToken:* = null) {
        super();
        this._forClass = forClass;
        this._forNamed = forNamed;
    }

    internal var _forClass:Class;

    public function get forClass():Class {
        return _forClass;
    }

    internal var _forNamed:String;

    public function get forNamed():String {
        return _forNamed;
    }

    internal var _forToken:*;

    public function get forToken():* {
        return _forToken;
    }

    public function equals(key:INetworkMessageBindingKey):Boolean {
        if (!key)
            return false;
        if (key == this)
            return true;

        return (key.forClass == this.forClass) && (key.forNamed == this.forNamed) && (key.forToken == this.forToken);
    }

} // class CSimpleNetworkMessageBindingKey
}
