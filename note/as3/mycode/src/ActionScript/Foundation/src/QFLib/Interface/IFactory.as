//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Interface {

/**
 * A abstract interface describe a factory design pattern.
 * 
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IFactory {
    
    function create():*;
    
    function destroy(obj:Object):void;
    
}
}
