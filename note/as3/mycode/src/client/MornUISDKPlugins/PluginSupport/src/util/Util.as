package util
{
import morn.core.components.Tree;

public class Util
{

    public static const pagePanelPath : String = "PagePanel";
    public static const resPanelPath : String = "ResPanel";
    public static const pageTreePath : String = "PagePanel..Tree";
    public static const resTreePath : String = "ResPanel..Tree";
    public static const uiMgrPath : String = "..UIManager";

    static public function expandParents( resTree : Tree, node : XML ) : void
    {
//        if ( node && !resTree.isItemOpen( node ) )
//        {
//            resTree.expandItem( node, true );
//            expandParents( resTree, node.parent() );
//        }
    }

    static public function getResource( node : XML ) : String
    {
        var result : *;
        for each ( var attr : XML in node.attributes() )
        {
            if ( result = /(png|jpg|jpeg)\.(\w+\.)*[^\s"]+/ig.exec( attr.toString() ) )
            {
                return result[0];
            }
            else if ( result = /frameclip_(\w+)*[^\s"]+/ig.exec( attr.toString() ) )
            {
                return result[0];
            }
        }

        return null;
    }

    static public function power2( value : uint ) : uint
    {
        var x : uint = 1;
        var i : uint = 0;
        while ( x < value )
        {
            x = (2 << ++i);
        }

        return i;
    }
}
}