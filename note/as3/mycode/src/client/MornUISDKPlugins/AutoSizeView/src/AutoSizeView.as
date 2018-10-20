package
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;

import morn.editor.PluginBase;

/**
 * MornUI 编辑器插件
 */
public class AutoSizeView extends PluginBase
{

    static private var labels : Array = ["text", "label", "labels"];

    public function AutoSizeView()
    {
        log( "AutoSizeView plugin creation." );
    }

    /** @inheritDoc */
    override public function start() : void
    {
        var viewXML : XML = viewXml.copy();

        var root : DisplayObjectContainer;
        var rect : Rectangle;

        for ( var i : int = 0; i < int.MAX_VALUE; ++i )
        {
            var comp : DisplayObject = getCompById( i );
            if ( comp )
            {
                if ( !root )
                {
                    root = comp.parent;
                    rect = new Rectangle();
                }

                rect = rect.union( comp.getRect( root ) );
            }
            else if ( i >= 100 )
            {
                break;
            }
        }

        viewXML.@sceneWidth = Math.ceil( rect.right );
        viewXML.@sceneHeight = Math.ceil( rect.bottom );

        changeViewXml( viewXML, true );
    }

}
}
