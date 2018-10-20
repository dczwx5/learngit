//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.core {

import QFLib.Memory.CSmartObject;

import flash.events.IEventDispatcher;

import flexunit.framework.Assert;

import kof.game.character.movement.CMovement;

import org.hamcrest.core.isA;
import org.hamcrest.number.isNumber;

/**
 * Test case of CGameObject default functions.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CGameObjectTester {

    public function CGameObjectTester() {
    }

    private var m_pObj : CGameObject;

    [Before]
    public function runBeforeEveryTest() : void {
        m_pObj = new CGameObject();
    }

    [After]
    public function runAfterEveryTest() : void {
        if ( m_pObj )
            m_pObj.dispose();
    }

    [Test]
    public function testConstruct() : void {
        var obj : CGameObject = m_pObj;

        Assert.assertTrue( obj is IEventDispatcher );
        Assert.assertTrue( obj is CSmartObject );

        Assert.assertNull( obj.data );
        Assert.assertFalse( obj.isRunning );
        Assert.assertTrue( obj.components.length == 0 );
    }

    [Test]
    public function testConstructByMapObject() : void {
        var obj : CGameObject = new CGameObject( {
            id : 1,
            name : "MapObject",
            level : 100
        } );

        Assert.assertNotNull( obj.data );
        Assert.assertFalse( obj.isRunning );
        Assert.assertTrue( obj.components.length == 0 );

        Assert.assertTrue( isNumber().matches( obj.data.id ) );
        Assert.assertTrue( isA( String ).matches( obj.data.name ) );
        Assert.assertTrue( isNumber().matches( obj.data.level ) );

        Assert.assertEquals( 1, obj.data.id );
        Assert.assertEquals( "MapObject", obj.data.name );
        Assert.assertEquals( 100, obj.data.level );
    }

    [Test]
    public function testConstructByTypeObject() : void {
        var typeObj : TestTypeObject = new TestTypeObject( 1 );
        typeObj.name = "TypeObject";
        typeObj.level = 100;

        var obj : CGameObject = new CGameObject( typeObj );

        Assert.assertTrue( isNumber().matches( obj.data.id ) );
        Assert.assertTrue( isA( String ).matches( obj.data.name ) );
        Assert.assertTrue( isNumber().matches( obj.data.level ) );

        Assert.assertEquals( 1, obj.data.id );
        Assert.assertEquals( "TypeObject", obj.data.name );
        Assert.assertEquals( 100, obj.data.level );

        Assert.assertStrictlyEquals( typeObj, obj.data );
    }

    [Test]
    public function testDestructAtNotRunning() : void {
        var obj : CGameObject = new CGameObject( {
            id : 1
        } );

        Assert.assertNotNull( obj.data );
        Assert.assertFalse( obj.isRunning );

        obj.dispose();

        Assert.assertNull( obj.data );
        Assert.assertNull( obj.components );
        Assert.assertNull( obj.classToComponentMap );
    }

    [Test]
    public function testAddComponent() : void {
        var typeObj : TestTypeObject = new TestTypeObject( 1, "TypeObject#1", 100 );

        var obj : CGameObject = new CGameObject( typeObj );

        Assert.assertNotNull( obj.data );
        Assert.assertFalse( obj.isRunning );
        Assert.assertNull( obj.transform );
        Assert.assertNotNull( obj.classToComponentMap );

        obj.addComponent( new CTransform() );

        Assert.assertNotNull( obj.transform );

        var pTransform : ITransform = obj.getComponentByClass( ITransform, false ) as ITransform;

        Assert.assertEquals( pTransform, obj.transform );

        var pTransformImpl : CTransform = obj.getComponentByClass( CTransform, false ) as CTransform;

        Assert.assertEquals( pTransformImpl, obj.transform );
        Assert.assertEquals( pTransformImpl, pTransform );
    }

    [Test]
    public function testAddComponent2() : void {
        var obj : CGameObject = new CGameObject();
        obj.addComponent( new CTransform() );
        obj.addComponent( new CMovement() );

        var pMovement : CMovement = obj.getComponentByClass( CMovement, false ) as CMovement;

        Assert.assertNotNull( pMovement );
    }

    [Test]
    public function testGetAndFindComponent() : void {
        var obj : CGameObject = new CGameObject();
        obj.addComponent( new CTransform() );

        Assert.assertEquals( obj.findComponent( obj.transform ), obj.transform );
        Assert.assertEquals( obj.getComponentByClass( ITransform, false ), obj.transform );
    }

    private function getComponentCacheSize( obj : CGameObject ) : uint {
        var nSize : uint = 0;
        if ( obj.classToComponentMap )
            for each ( var c : IGameComponent in obj.classToComponentMap ) {
                nSize++;
            }
        return nSize;
    }

    [Test]
    public function testGetComponentByCaching() : void {
        var obj : CGameObject = new CGameObject();
        var pTransform : ITransform = new CTransform();
        obj.addComponent( pTransform );

        obj.findComponentByClass( ITransform );
        var nSize : uint = this.getComponentCacheSize( obj );

        Assert.assertEquals( 0, nSize );

        obj.findComponent( pTransform );
        nSize = this.getComponentCacheSize( obj );

        Assert.assertEquals( 0, nSize );

        obj.getComponentByClass( ITransform, true );
        nSize = this.getComponentCacheSize( obj );

        Assert.assertEquals( 1, nSize );

        obj.getComponentByClass( CTransform, true );
        nSize = this.getComponentCacheSize( obj );

        Assert.assertEquals( 2, nSize );

        obj.dispose();

        nSize = this.getComponentCacheSize( obj );
        Assert.assertEquals( 0, nSize );
    }

    [Test]
    public function testRemoveComponent() : void {

    }

}
}

class TestTypeObject {

    public var id : Number;
    public var name : String;

    //----------------------------------
    // Level
    //----------------------------------

    private var m_iLevel : uint;

    public function get level() : uint {
        return m_iLevel;
    }

    public function set level( value : uint ) : void {
        m_iLevel = value;
    }

    function TestTypeObject( id : Number, name : String = null, level : uint = 0 ) {
        super();
        this.id = id;
        this.name = name;
        this.m_iLevel = level;
    }
}

