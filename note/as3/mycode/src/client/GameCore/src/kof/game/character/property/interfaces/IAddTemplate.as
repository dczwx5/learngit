//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/13.
 */
package kof.game.character.property.interfaces {

import kof.table.MonsterProperty;

public interface IAddTemplate {
    function addBaseTemplate(baseTemplate:MonsterProperty) : void ;
    function addGrowTemplate(growTemplate:MonsterProperty, difficulty:Number) : void ;
}
}
