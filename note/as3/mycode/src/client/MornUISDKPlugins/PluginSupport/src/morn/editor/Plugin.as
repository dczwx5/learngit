package morn.editor
{

import flash.filesystem.File;

import morn.core.managers.DialogManager;

import util.DisplayObjectFinder;

public class Plugin extends PluginBase
{

//    static protected var resTree : Tree;
    static protected var finder : DisplayObjectFinder;
    public static var dialog : DialogManager;

    protected var pluginConfig : XML;
    protected var pluginName : String;

    public function Plugin()
    {
        pluginName = String( this ).slice( "[object ".length, -1 );
        pluginConfig = new XML( readTxt( pluginPath + "/" + pluginName + "/config.xml" ) );
//        if ( pluginConfig.plugin.autostart == "true" )
//        {
//            log( "自动启动：" + pluginName );
//            setTimeout( start, 1000 );
//        }

        if ( !finder ) finder = new DisplayObjectFinder();

        if ( !dialog )
            dialog = new DialogManager();

        if ( !dialog.parent )
        {
            builderMain.addChild( dialog );
        }
    }

    static public function getResourceNativePath( resource : String ) : String
    {
        var arr : Array = resource.split( "." );
        var extension : String = arr.shift();
        var relative : String = arr.join( "/" ) + "." + extension;
        return getPath( workPath + "/morn/assets/", relative );
    }

    static public function getResourceFileName( resource : String, newName : String = null ) : String
    {
        var arr : Array = resource.split( "." );
        var extension : String = arr.shift();
        return (newName ? newName : arr[arr.length - 1]) + "." + extension;
    }

    static public function getDirNativePath( dir : XML ) : String
    {
        var relative : String = dir.@name;
        while ( dir = dir.parent() )
        {
            if ( String( dir.@name ) )
            {
                relative = dir.@name + "/" + relative;
            }
        }
        // return PluginBase.getPath( PluginBase.workPath + "/morn/assets/", relative );
        return getPath( getRelativePath( workPath, assetPath ), relative );
    }

    public static function getResourceName( resource : String ) : String
    {
        var arr : Array = resource.split( "." );
        return arr[arr.length - 1];
    }

    public static function getResourceFromPath( filePath : String ) : String
    {
        var base : String = (workPath + "\\morn\\assets\\");
        var relative : String = filePath.slice( base.length );
        var arr : Array = relative.split( "\\" );
        var file : Array = arr.pop().split( "." );
        return file[1] + "." + arr.join( "." ) + (arr.length ? "." : "") + file[0];
    }

    public static function getFileName( filePath : String ) : String
    {
        if ( null == filePath )
            return null;
        var arr : Array = filePath.split( '\\' );
        var subject : String = arr[arr.length - 1];
        arr = subject.split( '.' );
        return arr[0];
    }

    public static function getPackage( filePath : String ) : String
    {
        if ( null == filePath )
            return null;
        filePath = new File( viewPagePath ).getRelativePath( new File( filePath ) );
        filePath = filePath.substring( 0, filePath.lastIndexOf( "/" ) ).replace( /\//g, "." );
        var exportPath : String = codeExportPath;
        if ( exportPath.charAt( exportPath.length - 1 ) != "/" )
        {
            exportPath = exportPath + "/";
        }
        var idx : int = exportPath.indexOf( "src/" ) > -1 ? (exportPath.indexOf( "src/" ) + 4) : (exportPath.indexOf( "/" ) + 1);
        exportPath = exportPath.substring( idx, exportPath.length - 1 ).replace( /\//g, "." );
        return exportPath + ((filePath != "") ? ("." + filePath) : "");
    }

    public static function get viewPagePath() : String
    {
        return projectPathConfig["&'"];
    }

    public static function get assetPath() : String
    {
        return projectPathConfig["4$"];
    }

    public static function get codeExportPath() : String
    {
        return projectConfig.codeExportPath;
    }

    public static function get resExportPath() : String
    {
        return projectConfig.resExportPath;
    }

    public static function getPageProps( pageName : String ) : String
    {
        return getClass( "morn.editor.manager.80" ).getPageProps( pageName );
    }

    public static function getCompProp( compName : String, labelName : String ) : String
    {
        return getClass( "morn.editor.manager.&#" ).getCompProp( compName, labelName );
    }

    public static function getResProps( resName : String ) : String
    {
        return getClass( "morn.editor.manager.;-" ).getResProps( resName );
    }

    public static function get isInEditor() : Boolean
    {
        return App.asset is BuilderResManager;
    }

    public static function isResType( extension : String ) : Boolean
    {
        return projectConfig.resTypes.indexOf( extension.toLocaleLowerCase() ) > -1;
    }

    public static function get projectConfig() : Class
    {
        return getClass( "morn.editor.config.&\"" ); // _SafeStr_20
    }

    public static function get projectPathConfig() : Class
    {
        return getClass( "morn.editor.config.,0" ); // _SafeStr_5
    }

}
}

// vim:ft=as3 tw=0
