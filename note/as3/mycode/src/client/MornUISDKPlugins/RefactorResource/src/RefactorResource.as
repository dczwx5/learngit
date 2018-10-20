package
{

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.filesystem.File;
import flash.ui.Keyboard;

import morn.core.components.Button;
import morn.core.components.Dialog;
import morn.core.components.TextInput;
import morn.editor.Plugin;
import morn.editor.PluginDialog;
import morn.editor.pluginui.test.TestPageUI;

import util.Util;

public class RefactorResource extends Plugin
{

    private static var inited : Boolean;
    private static var resTree : *;
//    private static var auto : AutoComplete;
    private static var window : PluginDialog;
    // private static var replace:ReplaceResource;
    private static var input : TextInput;

    private static const NAME : String = "移动资源";
    private static var fileFrom : File;
    private static var fileTo : File;
    private static var progress : *;
    private static var ok : Button;

    public function RefactorResource()
    {
    }

    override public function start() : void
    {
        if ( initialize() )
        {
            fileFrom = null;
            fileTo = null;

//            var item : Object = resTree.selectedItem;
//            log( "Structure: " );
//            for ( var key : String in item )
//            {
//                log( key + " = " + item[key] );
//            }

            log( "ResTree scrollBar skin: " + resTree.list.scrollBar.skin );

//            if ( selectedResource )
//            {
            // window.title = NAME + ":" + selectedResource;
//                auto.dataProvider = new XMLListCollection( resTree.dataProvider.source..dir );

            if ( window )
            {
                dialog.popup( window, true );
            }
            else
            {
                log( "window is null" );
            }

            builderStage.addEventListener( KeyboardEvent.KEY_UP, handleKey );

            // input.text = getResourceName( selectedResource );
//                auto.setFocus();
//            }

        }
        else
        {
            alert( NAME, "Plugin started failed." )
        }
    }

    private static function initialize() : Boolean
    {
        if ( inited )
            return Boolean( resTree );
        inited = true;

        // finder.dumpLog( builderMain );

        resTree = finder.search( Util.resTreePath, builderMain );

//        auto = new AutoComplete();
//        auto.percentWidth = 100;
//        auto.matchType = "anyPart";
//        auto.focusEnabled = true;
//
//        auto.graphics.lineStyle( 1, 0x696969 );
//        auto.graphics.drawRect( 0, 0, 229, 20 );

//        var dialogClass : Class = getClass( "@+::Dialog" );

//        window = new dialogClass();
        window = new TestPageUI();
        window.addEventListener( Event.CLOSE, remove );

        return Boolean( resTree );
    }

    private static function handleKey( event : KeyboardEvent ) : void
    {
        if ( event.keyCode == Keyboard.ESCAPE )
            remove();
    }

    private static function remove( event : Event = null ) : void
    {
//        resTree.removeEventListener( CollectionEvent.COLLECTION_CHANGE, onResourceRefreshed );
        builderStage.removeEventListener( KeyboardEvent.KEY_UP, handleKey );
//        PopUpManager.removePopUp( window );
//        dialog.close( window );
        window.close( Dialog.CLOSE );
//        auto.clear();
    }

//    private static function onResourceRefreshed( event : CollectionEvent ) : void
//    {
//        if ( fileTo )
//        {
//            // var resource : String = getResourceFromPath( fileTo.nativePath );
//            var resource : String = fileTo.nativePath;
//            var item : XML = XML( resTree.dataProvider.source..item.(@asset == resource ) );
//            Util.expandParents( resTree, item );
//            resTree.validateNow();
//            resTree.selectedItem = item;
//            resTree.scrollToIndex( resTree.selectedIndex );
//        }
//    }

    private static function get selectedResource() : String
    {
        var resource : String;
        if ( selectedXmls && selectedXmls.length > 0 )
        {
            resource = Util.getResource( selectedXmls[0].xml );
        }
        else if ( resTree && resTree.selectedItem )
        {
            resource = resTree.selectedItem.asset;
        }
        return resource;
    }
}
}

