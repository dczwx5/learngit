//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

/**
 * A interface describes a property changed from a value to a value in any object.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IPropertyChangeDescriptor {

    /**
     * The name of the property changed.
     */
    function get propertyName() : String;

    /**
     * A value before modified.
     */
    function get oldValue() : *;

    /**
     * A value after modified.
     */
    function get newValue() : *;

}
}
