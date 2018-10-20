//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

/**
 * UserProfile contains account information and the settings.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CUserProfile extends CAppSystem {

    /**
     * Creates a CUserProfile instance.
     */
    public function CUserProfile() {
        super();
    }

    private var _data:Object;

    public function get account():String {
        return _data.account;
    }

    public function get uid():uint {
        return _data.uid;
    }

    override protected function doStart():Boolean {
        this.addBean(_data, DEFAULT);
        return super.doStart();
    }

    override protected function doStop():Boolean {
        this.removeBean(_data);
        return super.doStop();
    }
}
}

