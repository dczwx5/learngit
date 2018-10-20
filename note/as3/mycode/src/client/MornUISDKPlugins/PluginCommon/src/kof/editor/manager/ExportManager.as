package kof.editor.manager
{
import flash.desktop.NativeApplication;
import flash.filesystem.File;
import flash.utils.ByteArray;
import flash.utils.Endian;

import morn.editor.Plugin;
import morn.editor.PluginBase;

/**
 *
 */
public class ExportManager
{

    private static var s_pInstance : ExportManager;

    public static function get instance() : ExportManager
    {
        if ( !s_pInstance )
            s_pInstance = new ExportManager();
        return s_pInstance;
    }

    /** Creates a new ExportManager. */
    public function ExportManager()
    {
        super();
        if ( s_pInstance )
            throw new Error( "ExportManager is a singleton." );

        init();
    }

    private static var s_pAssetsInfo : Object;

    private var m_pExportDelegate : Function;
    private var m_pForceExportDelegate : Function;

    public function get mornUIEditorExportClass() : Class
    {
        return PluginBase.getClass( "morn.editor.manager.0'" );
    }

    private function init() : Boolean
    {
        if ( null == m_pExportDelegate && null == m_pForceExportDelegate )
        {
            m_pExportDelegate = mornUIEditorExportClass['export'];
            m_pForceExportDelegate = mornUIEditorExportClass['forceExport'];
        }

        return inited;
    }

    public function get inited() : Boolean
    {
        return null != m_pExportDelegate && null != m_pForceExportDelegate;
    }

    public function export( forced : Boolean = false, prompt : Boolean = true ) : void
    {
//        if ( forced )
//        {
//            PluginBase.alert( "ExportManager", "Not implementation!!!" );
//            return;
//        }

        function doPublish( type : int = 1 ) : void
        {
            // Now, we execute the export action.
            if ( type == 1 )
                exportAll( forced );
        }

        if ( prompt )
            PluginBase.confirm( "KOF技术团队", "我们修改过发布流程，当你看到这个确认框时表示您的操作是正确的！请继续……", doPublish );
        else
            doPublish();

    }

    protected function exportAll( forced : Boolean = false ) : void
    {
        try
        {
            // execute export delegater.
            if ( forced )
                m_pForceExportDelegate();
            else
                m_pExportDelegate();
        } catch (e:Error) {
            getMessageManager().show( "exportAll failed: " + e.errorID + ", " + e.text );
            NativeApplication.nativeApplication.exit( 1 );
        }
    }

    public function exportDependItems() : void {
        try
        {
            var pageDepends : Object = {};
            visitByDir( new File( getPagesDir() ), pageDepends );

            // System.setClipboard( _logStr );

            s_pAssetsInfo = visitAssetsForDependencies();
//        System.setClipboard( JSON.stringify( s_pAssetsInfo ) );

            var dependContens : Object = {};

            for ( var pageDef : String in pageDepends )
            {
                var depends : Array = [];
                var skins : Object = pageDepends[pageDef];
                for ( var s : String in skins )
                {
                    if ( s in s_pAssetsInfo )
                    {
                        var loc : String = s_pAssetsInfo[s].location;
                        if ( depends.indexOf( loc ) > -1 )
                            continue;
                        depends.push( loc );
                    }
                }
                dependContens[pageDef] = {
                    deps : depends
                };
            }

//        System.setClipboard( JSON.stringify( dependContens ) );

            outputDependBytes( dependContens );
        } catch (e:Error) {
            getMessageManager().show( "exportDependItems failed: " + e.errorID + ", " + e.text );
            NativeApplication.nativeApplication.exit( 1 );
        }
    }

    protected function outputDependBytes( content : Object ) : void
    {
        if ( !content )
            return;

        var ba : ByteArray = new ByteArray();
        ba.endian = Endian.LITTLE_ENDIAN;
        ba.writeObject( content );
        ba.position = 0;
        ba.compress();

        var outputPath : String = PluginBase.getPath( PluginBase.workPath, Plugin.resExportPath + "/dep.bin" );
        PluginBase.writeByte( outputPath, ba );

        outputPath = PluginBase.getPath( PluginBase.workPath, Plugin.resExportPath + "/dep.json" );
        PluginBase.writeTxt( outputPath, JSON.stringify( content ) );
    }

    public static function getPagesDir() : String
    {
        return PluginBase.getClass( "morn.editor.config.,0" )["&'"];
    }

    protected static function visitByDir( file : File, result : Object ) : void
    {
        var fileList : Array = file.getDirectoryListing();
        for each ( var f : File in fileList )
        {
            if ( f.isDirectory )
            {
                var ignored : Boolean = f.name.indexOf( '.svn' ) == 0 || f.name.indexOf( '.git' ) == 0;
                if ( ignored )
                    continue;
                visitByDir( f, result );
            }
            else
            {
                if ( f.extension == 'xml' )
                {
                    var nativePath : String = f.nativePath;
                    XML.ignoreComments = true;
                    try
                    {
                        parseXMLRefs( nativePath, result );
                    }
                    catch ( e : Error )
                    {
                        throw e;
                    }
                }
            }
        }
    }

    protected static function parseUIXml( xml : XML, map : Object, skins : Object ) : void
    {
        var xmlName : String = xml.name();
        if ( xmlName == "UIView" )
        {
            var sourcePath : String = xml.@source;
            sourcePath = PluginBase.getPath( Plugin.viewPagePath, sourcePath );
            delete xml.@source;
            var fileName : String = Plugin.getFileName( sourcePath );
            xml.setName( fileName );
            var runtimeXML : String = xml.@runtime;
            if ( !runtimeXML )
            {
                var runtimeClass : String = ((Plugin.getPackage( sourcePath ) + ".") + fileName) + "UI";
                xml.@runtime = runtimeClass;
                runtimeXML = runtimeClass;
            }
            map[runtimeXML] = runtimeXML;
        }

        if ( xmlName != "View" && xmlName != "Dialog" )
        {
            if ( xmlName != "UIView" )
            {
                var skinLabelField : String = Plugin.getCompProp( xmlName, "skinLabel" ) || "styleSkin";
                var skin : String = xml.@[skinLabelField];
                if ( skin )
                {
                    var resProps : Array = Plugin.getResProps( skin ).split( "\n" );
                    setDefaultValue( xml, resProps );
                    skins[skin] = xml;
                }
            }
            else
            {
                var source : String = xml.@source;
                if ( source )
                {
                    resProps = Plugin.getPageProps( source ).split( "\n" );
                    setDefaultValue( xml, resProps );
                }
            }
        }

        delete xml.@layers;
        delete xml.@layer;
        delete xml.@sceneWidth;
        delete xml.@sceneHeight;
        delete xml.@sceneColor;
        delete xml.@sceneBg;
        delete xml.@styleSkin;

        for ( var xi : int = 0, xl : int = xml.children().length(); xi < xl; xi++ )
        {
            parseUIXml( xml.children()[xi], map, skins );
        }
    }

    protected static function setDefaultValue( xml : XML, props : Array ) : void
    {
        for each ( var prop : String in props )
        {
            var pair : Array = prop.split( "=" );
            if ( pair.length == 2 )
            {
                var key : String = pair[0];
                var value : String = pair[1];
                if ( !xml.hasOwnProperty( "@" + key ) )
                {
                    xml.@[key] = value;
                }
            }
        }
    }

    private static var _map : Object = {};
//    private static var _logStr : String = "";

    protected static function parseXMLRefs( nativePath : String, result : Object ) : void
    {
        var xmlContent : XML = new XML( PluginBase.readTxt( nativePath ) );
        // log( "Parsing XML reference: " + nativePath );
        var skins : Object = {};
        parseUIXml( xmlContent, _map, skins );

        var fqName4Page : String = Plugin.getPackage( nativePath ) + '.' + Plugin.getFileName( nativePath ) + 'UI';
        result[fqName4Page] = skins;
//
//        var str : String = PluginBase.getRelativePath( Plugin.viewPagePath, nativePath );
//        str += '\n[ ' + fqName4Page + ' ]';
//        for ( var s : String in skins )
//        {
//            str += "\n\t" + s;
//        }
//        PluginBase.log( str );
//        _logStr += str + "\n";
    }

    public static function getResLinkName( pFile : File ) : String
    {
        var assetPath : String = Plugin.assetPath;
        if ( Plugin.projectConfig.shareResPath )
        {
            var shareResPath : String = PluginBase.getRelativePath( PluginBase.workPath, Plugin.projectConfig.shareResPath );
            if ( pFile.nativePath.indexOf( shareResPath ) > -1 )
                assetPath = shareResPath;
        }
        return pFile.extension + '.' + PluginBase.getRelativePath( assetPath, pFile.nativePath )
                        .replace( "." + pFile.extension, "" ).replace( /[\/|\\]/g, "." );
    }

    public static function getResLocation( pFile : File ) : String
    {
        var sLinkName : String = getResLinkName( pFile );

        var arr : Array = sLinkName.split( '.', 2 );
        arr.shift(); // extension.
        return arr[0] + ".swf";
    }

    private function visitAssetsForDependencies() : Object
    {
        var findFiles : Function = function ( sPathToFind : String, map : Object ) : Object
        {
            var pDirToFind : File;
            var sLabelName : String;
            var vFileList : Array;
            var sAssetName : String;

            if ( sPathToFind )
            {
                pDirToFind = new File( sPathToFind );

                if ( pDirToFind.exists )
                {
                    vFileList = pDirToFind.getDirectoryListing();

                    for each ( var pFile : File in vFileList )
                    {
                        if ( ((pFile.isDirectory) && (pFile.name.indexOf( ".svn" ) == -1)) )
                        {
                            findFiles( pFile.nativePath, map );
                        }
                    }

                    for each ( pFile in vFileList )
                    {
                        if ( pFile.isDirectory == false )
                        {
                            if ( Plugin.isResType( pFile.extension ) )
                            {
                                sLabelName = pFile.name.replace( ("." + pFile.extension), "" );
                                sAssetName = getResLinkName( pFile );

                                if ( sAssetName.indexOf( '$' ) == -1 )
                                {
                                    map[sAssetName] = {
                                        label : sLabelName,
                                        location : getResLocation( pFile )
                                    };
                                }
                            }
                            else
                            {
                                if ( pFile.extension == "swf" )
                                {
                                    // createSwfNode( pFile );
                                    visitSwfAssets( pFile, map );
                                }
                            }
                        }
                    }
                }
            }

            return null; // failed
        };

        var detailMap : Object = {};
        findFiles( Plugin.assetPath, detailMap ); // getRelativePath(workPath, "morn/assets")

        if ( Plugin.projectConfig.shareResPath )
        {
            findFiles( PluginBase.getRelativePath( PluginBase.workPath, Plugin.projectConfig.shareResPath ), detailMap );
        }
        return detailMap;
    }

    public function visitSwfAssets( pFile : File, map : Object ) : void
    {
        var iSwfTagCnt : int;
        var iSwfTagID : int;
        var iSwfTagIdx : int;
        var sAssetTagName : String;
        var sAssetLabelName : String;
        var sLabelName : String = pFile.name.replace( ".swf", "" );
//        PluginBase.log( "Read byte array from path: " + pFile.nativePath );
//        var baSwfContent : ByteArray = PluginBase.getClass( "morn.editor.manager.&%" ).readByteFile( pFile.nativePath );
        var baSwfContent : ByteArray = PluginBase.readByte( pFile.nativePath );
//        PluginBase.log( "SwfContent's length: " + baSwfContent.length );
        baSwfContent.endian = "littleEndian";
        baSwfContent.writeBytes( baSwfContent, 8 );
        baSwfContent.uncompress();
        baSwfContent.position = (Math.ceil( ((((baSwfContent[0] >>> 3) * 4) + 5) / 8) ) + 4);
//        PluginBase.log( "SwfContent begin at pos: " + baSwfContent.position );
        while ( baSwfContent.bytesAvailable > 2 )
        {
            iSwfTagCnt = baSwfContent.readUnsignedShort();
            iSwfTagID = (iSwfTagCnt & 0x3F);
            if ( iSwfTagID == 63 )
            {
                iSwfTagID = baSwfContent.readInt();
            }
            if ( (iSwfTagCnt >> 6) != 76 )
            {
//                PluginBase.log( "Set SwfContent's position: SwfContent.position(" + baSwfContent.position + ") + iSwfTagID(" + iSwfTagID + ") = " + (baSwfContent.position + iSwfTagID) );
                baSwfContent.position = (baSwfContent.position + iSwfTagID);
            }
            else
            {
                iSwfTagCnt = baSwfContent.readShort();
                iSwfTagIdx = 0;
//                PluginBase.log( "iSwfTagCnt: " + iSwfTagCnt );
                while ( iSwfTagIdx < iSwfTagCnt )
                {
                    baSwfContent.readShort();
                    var iStartPos : uint = baSwfContent.position;
                    do {
                    } while ( baSwfContent.readByte() != 0 );
                    iSwfTagID = baSwfContent.position - iStartPos;
                    baSwfContent.position = iStartPos;
                    sAssetTagName = baSwfContent.readUTFBytes( iSwfTagID );
//                    PluginBase.log( sAssetTagName );
                    var str : String = sAssetTagName.replace( (("png." + sLabelName) + "."), "" ).replace( (("jpg." + sLabelName) + "."), "" );
                    if ( str.indexOf( "$" ) == -1 )
                    {
                        var arr : Array = str.split( "." );
                        sAssetLabelName = arr[(arr.length - 1)];

                        map[sAssetTagName] = {
                            label : sAssetLabelName,
                            location : Plugin.getFileName( pFile.nativePath ) + ".swf"
                        };

//                        PluginBase.log("map[" + sAssetLabelName + "] => { label: " + sAssetLabelName + ", location: " + map[sAssetTagName].location + " }");
                    }
                    iSwfTagIdx++;
                }
            }
        }
    }

    protected function calculateAssetsReferences() : Object // Datatable for assets.
    {
        return null;
    }

    protected static function getMessageManager() : *
    {
        var msgManagerClass : Class = PluginBase.getClass( "morn.editor.manager.MessageManager" );
        return msgManagerClass['instance'];
    }

}
}

// vim:ft=as3 tw=0
