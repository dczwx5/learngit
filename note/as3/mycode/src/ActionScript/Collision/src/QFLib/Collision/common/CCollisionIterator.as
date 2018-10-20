//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/14.
//----------------------------------------------------------------------
package QFLib.Collision.common {

public class CCollisionIterator implements IIterator{

    public function CCollisionIterator( list : Array ) : void
    {
        m_list = list;
    }

    public function hasNext(): Boolean
    {
        return m_list && m_position < m_list.length;
    }

    public function next() : Object
    {
        return m_list[m_position++];
    }

    public function set list( value : Array ) : void
    {
        m_list = value;
    }

    public function set position( value : int ) : void
    {
        m_position = value;
    }

    private var m_list : Array;
    private var m_position : int = 0;
}
}
