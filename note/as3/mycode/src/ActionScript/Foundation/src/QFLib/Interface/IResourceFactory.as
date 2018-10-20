//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Interface
{

    /**
     * A abstract interface describe a factory design pattern for the resource pool.
     */
    public interface IResourceFactory
    {

        function create( sName : String ) : Object;

    }

}
